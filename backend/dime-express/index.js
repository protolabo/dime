const express = require('express');
const path    = require('path');
const fs      = require('fs');
const QRCode  = require('qrcode');
const { v4: uuidv4 } = require('uuid');

const app  = express();
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
app.get('/item/new', (_req, res)   => res.render('newItem'));
app.get('/shelf/new', (_req, res)  => res.render('newShelf'));

/* === Soumissions === */
app.post('/item/new', async (req, res, next) => {
  try {
    const { name, barcode, price, description } = req.body;

    // payload encodé dans le QR (JSON minifié)
    const qrPayload = JSON.stringify({
      type: 'item',
      name,
      barcode,
      price: parseFloat(price),
      description
    });

    const fileName = `item-${uuidv4()}.png`;
    const filePath = path.join(qrDir, fileName);

    // génère PNG + string base64
    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    res.render('qrResult', { dataUrl, fileName, meta: { name } });
  } catch (err) {
    next(err);
  }
});

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
