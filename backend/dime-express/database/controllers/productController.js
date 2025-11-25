const supabase = require('../../supabaseClient');
const {generateAndSaveQRToCloudflare,type} = require("../qrCode");
const multer = require('multer');
const { uploadImageToCloudflare } = require('../cloudflareImageService');
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10 MB max
});

//GET /products
const getProducts = async (_req, res) => {
  try {
    const {product_id, queryClient,queryCommercant,bar_code} = _req.query;
    let query = supabase.from('product').select('*');

    if (product_id) {
      if (Array.isArray(product_id)) {
        query = query.in('product_id', product_id.map(Number));
      } else {
        query = query.eq('product_id', Number(product_id));
      }
    }
    if (bar_code) {
        query = query.eq('bar_code', bar_code);
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

// POST /products
const createProduct = async (req, res) => {
  const {
    name,
    barcode,
    price,
    description,
    store_id,
    created_by,
    category = 'default',
    currency = 'CAD',
    pricing_unit = 'unit',
  } = req.body;

  console.log('Requête création produit:', req.body);
  if (!name || !barcode) {
    return res.status(400).json({ ok: false, error: 'name et barcode sont requis.' });
  }

  const auditCreatedBy = created_by || 'unknown';
  const storeId = Number(store_id) || null;
  console.log('Valeurs reçues:', {
    price,
    store_id,
    storeId,
    'price != null': price != null,
    'storeId != null': storeId != null,
    'condition complete': price != null && storeId != null,
  });
  let image_url = null;

  // Upload de l'image si présente
  if (req.file) {
    try {
      image_url = await uploadImageToCloudflare(
          req.file.buffer,
          `product-${Date.now()}-${req.file.originalname}`
      );
    } catch (error) {
      console.error('Erreur upload image:', error);
      return res.status(500).json({ ok: false, error: 'Échec upload image' });
    }
  }

  // 1) Insert product
  const { data: prodRows, error: prodErr } = await supabase
      .from('product')
      .insert({
        name,
        description: description ?? '',
        category,
        bar_code: barcode,
        image_url,
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

  // 2) Priced product si nécessaire
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
        available: 1,
      };
      const { error: priceErr } = await supabase.from('priced_product').insert(pricedPayload);
      if (priceErr) {
        console.error('priced_product insert error:', priceErr);
      }
    }
  }

  const product = prodRows[0];

  // 3) Génération QR code
  if (product && product.product_id) {
    const { imageUrl } = await generateAndSaveQRToCloudflare(type.PRODUCT, product.product_id, storeId);
    await supabase
        .from('product')
        .update({ qr_code: imageUrl })
        .eq('product_id', product.product_id);
    product.qr_code = imageUrl;
    product.qr_png_url = imageUrl;
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

// PUT /products/:product_id/image
const updateProductImage = async (req, res) => {
  const { product_id } = req.params;

  if (!req.file) {
    return res.status(400).json({ error: 'Aucune image fournie' });
  }

  try {
    // Upload vers Cloudflare
    const image_url = await uploadImageToCloudflare(
        req.file.buffer,
        `product-${product_id}-${Date.now()}-${req.file.originalname}`
    );

    // Mise à jour dans Supabase
    const { data, error } = await supabase
        .from('product')
        .update({ image_url })
        .eq('product_id', product_id)
        .select('product_id, image_url')
        .single();

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    if (!data) {
      return res.status(404).json({ error: 'Produit introuvable' });
    }

    res.status(200).json({
      success: true,
      image_url: data.image_url
    });

  } catch (error) {
    console.error('Erreur upload image:', error);
    res.status(500).json({ error: 'Échec de la mise à jour de l\'image' });
  }
};


module.exports = { getProducts, createProduct, updateProduct, deleteProduct, upload ,updateProductImage};