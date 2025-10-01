// backend/dime-express/database/qrCode.js
const path = require('path');
const fs = require('fs');
const QRCode = require('qrcode');
const axios = require('axios');

const qrBaseDir = path.join(__dirname, '../QR-CODE-GENERATOR/public/qr');

async function getStoreName(store_id) {
    const url = `http://localhost:3001/stores/?store_id=${store_id}`;
    const { data } = await axios.get(url);
    const store = data.favorites?.[0] || data.stores?.[0];
    if (!store || !store.name) throw new Error('Nom du magasin introuvable');
    return store.name;
}

async function generateAndSaveQR(type, id, store_id) {
    const storeName = await getStoreName(store_id);
    const storeQrDir = path.join(qrBaseDir, storeName);
    if (!fs.existsSync(storeQrDir)) {
        fs.mkdirSync(storeQrDir, { recursive: true });
    }

    const qrPayload = JSON.stringify({ type, [`${type}_id`]: id });
    const fileName = `${type}-${id}.png`;
    const filePath = path.join(storeQrDir, fileName);

    await QRCode.toFile(filePath, qrPayload);
    const dataUrl = await QRCode.toDataURL(qrPayload);

    return { dataUrl, fileName, relativePath: `/qr/${storeName}/${fileName}` };
}

module.exports = { generateAndSaveQR };
