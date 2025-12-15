const https = require('https');
const FormData = require('form-data');

const CLOUDFLARE_ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLOUDFLARE_API_TOKEN = process.env.CLOUDFLARE_API_TOKEN;

async function uploadImageToCloudflare(imageBuffer, fileName) {
    return new Promise((resolve, reject) => {
        const formData = new FormData();
        formData.append('file', imageBuffer, fileName);

        const options = {
            hostname: 'api.cloudflare.com',
            path: `/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/images/v1`,
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`,
                ...formData.getHeaders(),
            },
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const result = JSON.parse(data);
                if (!result.success) {
                    return reject(new Error(`Cloudflare upload failed: ${JSON.stringify(result.errors)}`));
                }
                resolve(result.result.variants[0]);
            });
        });

        req.on('error', reject);
        formData.pipe(req);
    });
}

module.exports = { uploadImageToCloudflare };
