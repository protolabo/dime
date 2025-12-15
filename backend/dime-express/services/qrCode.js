const path = require('path');
const fs = require('fs');
const FormData = require('form-data');
const QRCode = require('qrcode');
const axios = require('axios');
const qrBaseDir = path.join(__dirname, '../QR-CODE-GENERATOR/public/qr');
const type = {
    PRODUCT: 'product',
    SHELF: 'shelf'
}

async function getStoreName(store_id) {
    const url = `http://localhost:3001/stores/?store_id=${store_id}`;
    const { data } = await axios.get(url);
    const store = data.favorites?.[0] || data.stores?.[0];
    if (!store || !store.name) throw new Error('Nom du magasin introuvable');
    return store.name;
}

async function generateAndSaveQRToCloudflare(type, id, store_id) {
    const rawStoreName = await getStoreName(store_id);
    const storeName = rawStoreName
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '');
    const qrPayload = JSON.stringify({ type, [`${type}_id`]: id });
    const fileName = `${type}-${id}.png`;

    const qrBuffer = await QRCode.toBuffer(qrPayload);

    const cloudflareAccountId = '18867c89dfbd402b3e2af59050d8caf6';
    const cloudflareApiToken = 'LY1FpNIpblhnz_PO_q-L0cclpxLHt3cnDdSkdkxe';
    const url = `https://api.cloudflare.com/client/v4/accounts/${cloudflareAccountId}/images/v1`;

    const formData = new FormData();
    formData.append('file', qrBuffer, { filename: fileName, contentType: 'image/png' });

    const response = await axios.post(url, formData, {
        headers: {
            'Authorization': `Bearer ${cloudflareApiToken}`,
            ...formData.getHeaders()
        }
    });

    const imageUrl = response.data.result.variants[0];
    return { imageUrl, fileName };
}

module.exports = { generateAndSaveQRToCloudflare,type };
