const supabase = require('../../supabaseClient');
const {generateAndSaveQRToCloudflare,type} = require("../qrCode");
// GET /shelves
const getShelves = async (_req, res) => {
    try {
        const {shelf_id, store_id, name, qr_code, location, queryCommercant} = _req.query;
        let sqlQuery = supabase.from('shelf').select('*');

        if (shelf_id) sqlQuery = sqlQuery.eq('shelf_id', shelf_id);
        if (store_id) sqlQuery = sqlQuery.eq('store_id', store_id);
        if (name) sqlQuery = sqlQuery.eq('name', name);
        if (qr_code) sqlQuery = sqlQuery.eq('qr_code', qr_code);
        if (location) sqlQuery = sqlQuery.eq('location', location);

        // Nouvelle logique de recherche textuelle
        if (queryCommercant) {
            const pattern = `%${queryCommercant}%`;
            sqlQuery = sqlQuery.or(`name.ilike.${pattern},location.ilike.${pattern}`);
        }

        const { data, error } = await sqlQuery;
        if (error) return res.status(500).json({ error: error.message });
        res.status(200).json({ reviews: data });
    }
    catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};


// POST /shelves
const createShelf = async (req, res) => {
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
    // 2) Generate QR code and update shelf
    const shelf = shelfRows[0];
    if (shelf && shelf.shelf_id) {
        const { imageUrl, fileName } = await generateAndSaveQRToCloudflare(type.SHELF, shelf.shelf_id,storeId);
        await supabase
            .from('shelf')
            .update({ qr_code: imageUrl })
            .eq('shelf_id', shelf.shelf_id);
        shelf.qr_code = imageUrl;
        shelf.qr_png_url = imageUrl;
    }
    return res.status(201).json({ ok: true, shelf });
};

// PUT /shelves/:shelf_id
const updateShelf = async (req, res) => {
    const { shelf_id } = req.params;
    const { name, location, qr_code, store_id, last_updated_by } = req.body;

    const { data, error } = await supabase
        .from('shelf')
        .update({ name, location, qr_code, store_id, last_updated_by })
        .eq('shelf_id', shelf_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Shelf not found' });

    res.status(200).json({ success: true, shelf: data[0] });
};

// DELETE /shelves/:shelf_id
const deleteShelf = async (req, res) => {
    const { shelf_id } = req.params;

    const { data, error } = await supabase
        .from('shelf')
        .delete()
        .eq('shelf_id', shelf_id);

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Shelf not found' });

    res.status(200).json({ success: true, message: 'Shelf deleted successfully' });
};

const updateShelfImage = async (req, res) => {
    const { shelf_id } = req.params;

    if (!req.file) {
        return res.status(400).json({ error: 'Aucune image fournie' });
    }

    try {
        const { uploadImageToCloudflare } = require('../cloudflareImageService');

        // Upload vers Cloudflare
        const image_url = await uploadImageToCloudflare(
            req.file.buffer,
            `shelf-${shelf_id}-${Date.now()}-${req.file.originalname}`
        );

        // Mise à jour dans Supabase
        const { data, error } = await supabase
            .from('shelf')
            .update({ image_url })
            .eq('shelf_id', shelf_id)
            .select('shelf_id, image_url')
            .single();

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        if (!data) {
            return res.status(404).json({ error: 'Étagère introuvable' });
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

module.exports = {
    getShelves,
    createShelf,
    updateShelf,
    deleteShelf,
    updateShelfImage
};