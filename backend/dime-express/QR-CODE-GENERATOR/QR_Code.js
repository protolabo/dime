/**
 * Générateur de QR – version fixée
 * - n’insère plus la colonne created_by dans priced_product
 * - loggue explicitement les éventuelles erreurs Supabase
 */
const express = require('express');
const path     = require('path');
const fs       = require('fs');
const QRCode   = require('qrcode');
require('dotenv').config();
const supabase = require('../supabaseClient');

const app  = express();
const port = process.env.PORT || 3000;

/* ---------- MIDDLEWARE ---------- */
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'view'));

// dossier public pour les PNG
const qrDir = path.join(__dirname, 'public', 'qr');
fs.mkdirSync(qrDir, { recursive: true });
app.use(express.static(path.join(__dirname, 'public')));

/* ---------- ROUTES ---------- */
app.get('/', (_req, res) => res.redirect('/item/new'));

/* === FORMULAIRES === */
app.get('/item/new',  (_req, res) => res.render('newItem'));
app.get('/shelf/new', (_req, res) => res.render('newShelf'));

/* === AJOUT ITEM === */
app.post('/item/new', async (req, res, next) => {
  try {
    const { name, barcode, price, description, store_id = 1 } = req.body;

    /* 1️⃣  Insère l’item */
    const { data: prodRows, error: prodErr } = await supabase
      .from('product')
      .insert({
        name,
        description,
        category: 'default',
        bar_code: barcode,
        created_by: 'admin'  // dans product c’est bien un varchar
      })
      .select('product_id');

    if (prodErr) throw prodErr;
    const product_id = prodRows[0].product_id;

    /* 2️⃣  Prix initial dans priced_product (sans created_by) */
   /* 2️⃣  Prix initial dans priced_product */
if (price) {
  const payload = {
    store_id: Number(store_id),
    product_id,
    amount: parseFloat(price),
    currency: 'CAD',
    pricing_unit: 'unit',
    created_by: 'admin',
    avaible: 1 // 1 = disponible, ajuste selon ta logique
  };
  

  // n’ajoute store_id que si présent ET non vide
  if (store_id) payload.store_id = Number(store_id);

  const { error: priceErr } = await supabase
    .from('priced_product')
    .insert(payload);

  if (priceErr) {
    // tu verras l’erreur FK, type, etc. directement dans le terminal
    console.error('❌ priced_product insert error:', priceErr);
  }
}


    /* 3️⃣  Génère le QR (ID only) */
    const qrPayload = JSON.stringify({ type: 'product', product_id });
    const fileName  = `product-${product_id}.png`;
    const filePath  = path.join(qrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    /* 4️⃣  Met à jour la ligne product avec l’image du QR */
    const { error: updErr } = await supabase
      .from('product')
      .update({ qr_code: dataUrl })
      .eq('product_id', product_id);

    if (updErr) console.error('❌ product update error:', updErr);

    res.render('qrResult', { dataUrl, fileName, meta: { name } });
  } catch (err) {
    console.error(err);
    next(err);
  }
});

/* === AJOUT SHELF (inchangé) === */
app.post('/shelf/new', async (req, res, next) => {
  try {
    const { shelfName, store_id = 1, location = '' } = req.body;

    const { data: shelfRows, error: shelfErr } = await supabase
      .from('shelf')
      .insert({
        store_id,
        name: shelfName,
        location,
        created_by: 'admin'
      })
      .select('shelf_id');

    if (shelfErr) throw shelfErr;
    const shelf_id = shelfRows[0].shelf_id;

    const qrPayload = JSON.stringify({ type: 'shelf', shelf_id });
    const fileName  = `shelf-${shelf_id}.png`;
    const filePath  = path.join(qrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    await supabase
      .from('shelf')
      .update({ qr_code: dataUrl })
      .eq('shelf_id', shelf_id);

    res.render('qrResult', { dataUrl, fileName, meta: { name: shelfName } });
  } catch (err) {
    console.error(err);
    next(err);
  }
});

/* ---------- LANCEMENT ---------- */
app.listen(port, () =>
  console.log(`✅ QR backend running on http://localhost:${port}`)
);
