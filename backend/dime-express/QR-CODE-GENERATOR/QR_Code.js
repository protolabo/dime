// QR_Code.js (sans EJS / views)
const express   = require('express');
const path      = require('path');
const fs        = require('fs');
const QRCode    = require('qrcode');
const cors      = require('cors');
require('dotenv').config();
const supabase  = require('../supabaseClient');

const app  = express();
const port = process.env.PORT || 3000;

// Middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cors({
  origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*',
}));

// Dossier pour exposer les PNG de QR codes
const publicDir = path.join(__dirname, 'public');
const qrDir     = path.join(publicDir, 'qr');
fs.mkdirSync(qrDir, { recursive: true });
app.use(express.static(publicDir));

// Healthcheck
app.get('/health', (_req, res) => res.json({ ok: true, service: 'qr', ts: Date.now() }));

// ───────── CREATION ITEM + QR
app.post('/item/new', async (req, res) => {
  try {
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

    // 3) Génère le QR (payload JSON minimal)
    const qrPayload = JSON.stringify({ type: 'product', product_id });
    const fileName  = `product-${product_id}.png`;
    const filePath  = path.join(qrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    // 4) Stocke le Data URL dans product.qr_code
    const { error: updErr } = await supabase
      .from('product')
      .update({ qr_code: dataUrl })
      .eq('product_id', product_id);

    if (updErr) {
      console.error('❌ product update error:', updErr);
      // on continue tout de même — on renvoie le dataUrl dans la réponse
    }

    return res.status(201).json({
      ok: true,
      product_id,
      qr_code_data_url: dataUrl,
      qr_png_url: `/qr/${fileName}`,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ ok: false, error: err.message || 'internal error' });
  }
});

// ───────── CREATION SHELF + QR (stocke shelf.qr_code)
app.post('/shelf/new', async (req, res) => {
  try {
    const {
      shelfName,             // requis
      store_id,              // attendu du VM
      location = '',
      created_by,            // attendu du VM (email ou actor)
    } = req.body;

    if (!shelfName || !store_id) {
      return res.status(400).json({ ok: false, error: 'shelfName et store_id sont requis.' });
    }

    const auditCreatedBy = created_by || 'unknown';
    const storeId        = Number(store_id);

    // 1) Insert shelf
    const { data: shelfRows, error: shelfErr } = await supabase
      .from('shelf')
      .insert({
        store_id: storeId,
        name: shelfName,
        location,
        created_by: auditCreatedBy,
        // created_at par défaut côté BD (trigger / default now())
      })
      .select('shelf_id')
      .limit(1);

    if (shelfErr) {
      return res.status(500).json({ ok: false, error: `shelf insert: ${shelfErr.message}` });
    }

    const shelf_id = shelfRows?.[0]?.shelf_id;
    if (!shelf_id) {
      return res.status(500).json({ ok: false, error: 'shelf_id manquant après insertion.' });
    }

    // 2) Génère le QR
    const qrPayload = JSON.stringify({ type: 'shelf', shelf_id });
    const fileName  = `shelf-${shelf_id}.png`;
    const filePath  = path.join(qrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    // 3) Met à jour shelf.qr_code (+ audit champs si tu les utilises)
    const { error: updErr } = await supabase
      .from('shelf')
      .update({
        qr_code: dataUrl,                // colonne TEXT recommandée
        last_updated_at: new Date(),
        last_updated_by: auditCreatedBy,
      })
      .eq('shelf_id', shelf_id);

    if (updErr) {
      console.error('❌ shelf update error:', updErr);
      // on continue — on renvoie tout de même dataUrl
    }

    return res.status(201).json({
      ok: true,
      shelf_id,
      qr_code_data_url: dataUrl,
      qr_png_url: `/qr/${fileName}`,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ ok: false, error: err.message || 'internal error' });
  }
});

app.listen(port, () => {
  console.log(`✅ QR backend (JSON) running on http://localhost:${port}`);
});
