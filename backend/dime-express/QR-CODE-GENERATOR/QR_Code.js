// QR_Code.js
const express   = require('express');
const path      = require('path');
const fs        = require('fs');
const QRCode    = require('qrcode');
require('dotenv').config();
const supabase  = require('../supabaseClient');

const app   = express();
const port  = process.env.PORT || 3000;

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'view'));

const qrDir = path.join(__dirname, 'public', 'qr');
fs.mkdirSync(qrDir, { recursive: true });
app.use(express.static(path.join(__dirname, 'public')));

// ─── Routes GET ────────────────────────────────────────────────────────────────
// Redirect racine → form création item
app.get('/', (_req, res) => res.redirect('/item/new'));

// Formulaire création d’un item avec choix du store
app.get('/item/new', async (_req, res, next) => {
  try {
    const { data: stores, error } = await supabase
      .from('store')
      .select('store_id, name');
    if (error) throw error;
    res.render('newItem', { stores });
  } catch (err) {
    next(err);
  }
});

// Formulaire création d’une étagère (shelf) avec choix du store
app.get('/shelf/new', async (_req, res, next) => {
  try {
    const { data: stores, error } = await supabase
      .from('store')
      .select('store_id, name');
    if (error) throw error;
    res.render('newShelf', { stores });
  } catch (err) {
    next(err);
  }
});

// ─── Routes POST ───────────────────────────────────────────────────────────────
// Ajout d’un nouvel item
app.post('/item/new', async (req, res, next) => {
  try {
    const { name, barcode, price, description, store_id } = req.body;
    // 1️⃣ Insert produit
    const { data: prodRows, error: prodErr } = await supabase
      .from('product')
      .insert({
        name,
        description,
        category: 'default',
        bar_code: barcode,
        created_by: 'admin'
      })
      .select('product_id');
    if (prodErr) throw prodErr;
    const product_id = prodRows[0].product_id;

    // 2️⃣ Insert prix initial
    if (price) {
      const payload = {
        store_id: Number(store_id) || 1,
        product_id,
        amount: parseFloat(price),
        currency: 'CAD',
        pricing_unit: 'unit',
        created_by: 'admin',
        avaible: 1
      };
      const { error: priceErr } = await supabase
        .from('priced_product')
        .insert(payload);
      if (priceErr) console.error('❌ priced_product insert error:', priceErr);
    }

    // 3️⃣ Génération du QR code
    const qrPayload = JSON.stringify({ type: 'product', product_id });
    const fileName  = `product-${product_id}.png`;
    const filePath  = path.join(qrDir, fileName);
    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    // 4️⃣ Mise à jour du produit avec l’image QR
    const { error: updErr } = await supabase
      .from('product')
      .update({ qr_code: dataUrl })
      .eq('product_id', product_id);
    if (updErr) console.error('❌ product update error:', updErr);

    // Affichage du résultat
    res.render('qrResult', {
      dataUrl,
      fileName,
      meta: { name }
    });
  } catch (err) {
    console.error(err);
    next(err);
  }
});

// Ajout d’une nouvelle étagère (shelf)
app.post('/shelf/new', async (req, res, next) => {
  try {
    const { shelfName, store_id, location = '' } = req.body;
    // 1️⃣ Insert shelf
    const { data: shelfRows, error: shelfErr } = await supabase
      .from('shelf')
      .insert({
        store_id: Number(store_id) || 1,
        name: shelfName,
        location,
        created_by: 'admin'
      })
      .select('shelf_id');
    if (shelfErr) throw shelfErr;
    const shelf_id = shelfRows[0].shelf_id;

    // 2️⃣ Génération du QR code
    const qrPayload = JSON.stringify({ type: 'shelf', shelf_id });
    const fileName  = `shelf-${shelf_id}.png`;
    const filePath  = path.join(qrDir, fileName);
    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    // 3️⃣ Mise à jour de la shelf avec l’image QR
    const { error: updErr } = await supabase
      .from('shelf')
      .update({ qr_code: dataUrl })
      .eq('shelf_id', shelf_id);
    if (updErr) console.error('❌ shelf update error:', updErr);

    // Affichage du résultat
    res.render('qrResult', {
      dataUrl,
      fileName,
      meta: { name: shelfName }
    });
  } catch (err) {
    console.error(err);
    next(err);
  }
});

// ─── Démarrage du serveur (une seule fois) ────────────────────────────────────
app.listen(port, () =>
  console.log(`✅ QR backend running on http://localhost:${port}`)
);
