const supabase = require('../../supabaseClient');
const {generateAndSaveQR} = require("../qrCode");

// GET /shelves
const getShelves = async (_req, res) => {
    try {
        const {shelf_id,store_id} = _req.query;
        let query = supabase.from('shelf').select('*');

        if (shelf_id) query = query.eq('shelf_id', shelf_id);
        if (store_id) query = query.eq('store_id', store_id);
        const { data, error } = await query;
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
        const { dataUrl, fileName } = await generateAndSaveQR('shelf', shelf.shelf_id,storeId);
        await supabase
            .from('shelf')
            .update({ qr_code: dataUrl })
            .eq('shelf_id', shelf.shelf_id);
        shelf.qr_code = dataUrl;
        shelf.qr_png_url = `/qr/${fileName}`;
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

module.exports = { getShelves, createShelf, updateShelf, deleteShelf };