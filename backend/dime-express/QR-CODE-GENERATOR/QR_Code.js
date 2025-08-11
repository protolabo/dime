const express   = require('express');
const path      = require('path');
const fs        = require('fs');
const QRCode    = require('qrcode');
require('dotenv').config();
const supabase  = require('../supabaseClient');

const app  = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'view'));

const qrDir = path.join(__dirname, 'public', 'qr');
fs.mkdirSync(qrDir, { recursive: true });
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (_req, res) => res.redirect('/item/new'));

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

// ───────── Item + QR
app.post('/item/new', async (req, res, next) => {
  try {
    const { name, barcode, price, description, store_id, created_by } = req.body;
    const auditCreatedBy = created_by || 'unknown';
    const storeId        = Number(store_id) || 1;

    const { data: prodRows, error: prodErr } = await supabase
      .from('product')
      .insert({
        name,
        description,
        category: 'default',
        bar_code: barcode,
        created_by: auditCreatedBy,
      })
      .select('product_id');
    if (prodErr) throw prodErr;

    const product_id = prodRows[0].product_id;

    if (price) {
      const payload = {
        store_id: storeId,
        product_id,
        amount: parseFloat(price),
        currency: 'CAD',
        pricing_unit: 'unit',
        created_by: auditCreatedBy,
        avaible: 1,
      };
      const { error: priceErr } = await supabase.from('priced_product').insert(payload);
      if (priceErr) console.error('❌ priced_product insert error:', priceErr);
    }

    const qrPayload = JSON.stringify({ type: 'product', product_id });
    const fileName  = `product-${product_id}.png`;
    const filePath  = path.join(qrDir, fileName);
    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    const { error: updErr } = await supabase
      .from('product')
      .update({ qr_code: dataUrl })
      .eq('product_id', product_id);
    if (updErr) console.error('❌ product update error:', updErr);

    res.render('qrResult', { dataUrl, fileName, meta: { name } });
  } catch (err) { console.error(err); next(err); }
});

// ───────── Shelf + QR (stocke shelf.qr_code)
app.post('/shelf/new', async (req, res, next) => {
  try {
    const { shelfName, store_id, location = '', created_by } = req.body;
    const auditCreatedBy = created_by || 'unknown';
    const storeId        = Number(store_id) || 1;

    const { data: shelfRows, error: shelfErr } = await supabase
      .from('shelf')
      .insert({
        store_id: storeId,
        name: shelfName,
        location,
        created_by: auditCreatedBy,
      })
      .select('shelf_id');
    if (shelfErr) throw shelfErr;

    const shelf_id = shelfRows[0].shelf_id;

    const qrPayload = JSON.stringify({ type: 'shelf', shelf_id });
    const fileName  = `shelf-${shelf_id}.png`;
    const filePath  = path.join(qrDir, fileName);
    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    const { error: updErr } = await supabase
      .from('shelf')
      .update({
        qr_code: dataUrl,
        last_updated_at: new Date(),
        last_updated_by: auditCreatedBy,
      })
      .eq('shelf_id', shelf_id);
    if (updErr) console.error('❌ shelf update error:', updErr);

    res.render('qrResult', { dataUrl, fileName, meta: { name: shelfName } });
  } catch (err) { console.error(err); next(err); }
});

app.listen(port, () =>
  console.log(`✅ QR backend running on http://localhost:${port}`)
);
