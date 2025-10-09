const supabase = require('../../supabaseClient');
const {generateAndSaveQR,type} = require("../qrCode");

//GET /products
const getProducts = async (_req, res) => {
  try {
    const {product_id, queryClient,queryCommercant} = _req.query;
    let query = supabase.from('product').select('*');

    if (product_id) {
      if (Array.isArray(product_id)) {
        query = query.in('product_id', product_id.map(Number));
      } else {
        query = query.eq('product_id', Number(product_id));
      }
    }

    // Nouvelle logique de recherche textuelle pour les clients
    if (queryClient) {
      const pattern = `%${queryClient}%`;
      query = query.or(`name.ilike.${pattern},bar_code.ilike.${pattern}`);
    }
    // Nouvelle logique de recherche textuelle pour les commerçants
    if (queryCommercant) {
      const pattern = `%${queryCommercant}%`;
      query = query.or(`name.ilike.${pattern},category.ilike.${pattern},bar_code.ilike.${pattern}`);
    }

    const { data, error } = await query;
    if (error) return res.status(500).json({ error: error.message });
    res.status(200).json({ reviews: data });
  }
  catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
};

//POST /products
const createProduct = async (req, res) => {
  const {
    name,
    barcode,
    price,                 // optionnel
    description,
    store_id,              // attendu du VM
    created_by,            // attendu du VM (email ou actor)
    category = 'default',
    currency = 'CAD',
    pricing_unit = 'unit',
  } = req.body;

  if (!name || !barcode) {
    return res.status(400).json({ ok: false, error: 'name et barcode sont requis.' });
  }

  const auditCreatedBy = created_by || 'unknown';
  const storeId        = Number(store_id) || null;

  // 1) Insert product
  const { data: prodRows, error: prodErr } = await supabase
      .from('product')
      .insert({
        name,
        description: description ?? '',
        category,
        bar_code: barcode,
        created_by: auditCreatedBy,
      })
      .select('product_id')
      .limit(1);

  if (prodErr) {
    return res.status(500).json({ ok: false, error: `product insert: ${prodErr.message}` });
  }
  const product_id = prodRows?.[0]?.product_id;
  if (!product_id) {
    return res.status(500).json({ ok: false, error: 'product_id manquant après insertion.' });
  }

  // 2) Optionnel: priced_product si price fourni ET store_id fourni
  if (price != null && storeId != null) {
    const amount = parseFloat(price);
    if (!Number.isNaN(amount)) {
      const pricedPayload = {
        store_id: storeId,
        product_id,
        amount,
        currency,
        pricing_unit,
        created_by: auditCreatedBy,
        avaible: 1, // garde l’orthographe telle qu’en BD si c’est ce qui existe
      };
      const { error: priceErr } = await supabase.from('priced_product').insert(pricedPayload);
      if (priceErr) {
        // On log mais on ne bloque pas la création de l’item
        console.error('❌ priced_product insert error:', priceErr);
      }
    }
  }
  const product = prodRows[0];
  // Génère le QR code et met à jour le produit
  if (product && product.product_id) {
    const { dataUrl, fileName } = await generateAndSaveQR(type.PRODUCT, product.product_id, storeId);
    await supabase
        .from('product')
        .update({ qr_code: dataUrl })
        .eq('product_id', product.product_id);
    product.qr_code = dataUrl;
    product.qr_png_url = `/qr/${fileName}`;
  }

  res.status(201).json({ success: true, product });
};
//PUT /products/:product_id
const updateProduct = async (req, res) => {
  const { product_id } = req.params;
  const { name, bar_code, description, category, image_url, qr_code, updated_by } = req.body;

  const { data, error } = await supabase
      .from('product')
      .update({ name, bar_code, description, category, image_url, qr_code, updated_by })
      .eq('product_id', product_id)
      .select();

  if (error) return res.status(500).json({ error: error.message });
  if (!data.length) return res.status(404).json({ error: 'Product not found' });

  res.status(200).json({ success: true, product: data[0] });
};
//DELETE /products/:id
const deleteProduct = async (req, res) => {
  const { product_id } = req.params;

  const { data, error } = await supabase
      .from('product')
      .delete()
      .eq('product_id', product_id);

  if (error) return res.status(500).json({ error: error.message });
  if (!data.length) return res.status(404).json({ error: 'Product not found' });

  res.status(200).json({ success: true, message: 'Product deleted successfully' });
};

module.exports = { getProducts, createProduct, updateProduct, deleteProduct };
