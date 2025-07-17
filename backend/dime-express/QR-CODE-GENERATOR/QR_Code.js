const express = require('express');
const path = require('path');
const fs = require('fs');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();
const supabase = require('../supabaseClient'); // ← Ajout ici


const app = express();
const port = process.env.PORT || 3000;

/* ---------- MIDDLEWARE ---------- */
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'view'));

// dossier public pour servir les PNG
app.use(express.static(path.join(__dirname, 'public')));

// s’assure que public/qr existe
const qrDir = path.join(__dirname, 'public', 'qr');
fs.mkdirSync(qrDir, { recursive: true });

/* ---------- ROUTES ---------- */

// page d’accueil (redirection simple)
app.get('/', (_req, res) => res.redirect('/item/new'));

/* === Formulaires === */
app.get('/item/new', (_req, res) => res.render('newItem'));
app.get('/shelf/new', (_req, res) => res.render('newShelf'));

/* === Soumission item === */
app.post('/item/new', async (req, res, next) => {
  try {
    const { name, barcode, price, description } = req.body;

    const qrPayload = JSON.stringify({
      type: 'item',
      name,
      barcode,
      price: parseFloat(price),
      description
    });

    const fileName = `item-${uuidv4()}.png`;
    const filePath = path.join(qrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    const { data, error } = await supabase
  .from('product')
  .insert([{
    name,
    description,
    category: 'default',
    image_url: null,
    qr_code: dataUrl,
    created_by: 'admin'
  }])                               // ← on a retiré bar_code et price
  .select();


  if (error) {
    console.error(' Supabase insert error:', error);
    throw error;
  }

    console.log(` The item "${name}" by "admin" has been successfully added to the database!`);

    res.render('qrResult', { dataUrl, fileName, meta: { name } });

  } catch (err) {
    next(err);
  }
});

/* === Soumission shelf === */
app.post('/shelf/new', async (req, res, next) => {
  try {
    const { shelfName } = req.body;

    const qrPayload = JSON.stringify({
      type: 'shelf',
      name: shelfName
    });

    const fileName = `shelf-${uuidv4()}.png`;
    const filePath = path.join(qrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    res.render('qrResult', { dataUrl, fileName, meta: { name: shelfName } });
  } catch (err) {
    next(err);
  }
});

/* ---------- LANCEMENT ---------- */
app.listen(port, () => console.log(`✅  Backend QR running on http://localhost:${port}`));
