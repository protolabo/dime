const supabase = require('../../supabaseClient');

// GET /shelf-places
const getShelfPlaces = async (req, res) => {
    try {
        const { shelf_id, product_id } = req.query;

        let query = supabase.from('shelf_place').select('*');
        if (shelf_id) query = query.eq('shelf_id', shelf_id);
        if (product_id) query = query.eq('product_id', product_id);

        const { data, error } = await query;
        if (error) return res.status(500).json({ error: error.message });

        res.status(200).json({ shelfPlaces: data });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};

// POST /shelf-places
const createShelfPlace = async (req, res) => {
    const payload = Array.isArray(req.body) ? req.body : [req.body];
    for (const item of payload) {
        if (!item.shelf_id || !item.product_id) {
            return res.status(400).json({ error: 'shelf_id ou product_id manquant' });
        }
    }

    const { data, error } = await supabase
        .from('shelf_place')
        .insert(payload)
        .select();

    if (error) return res.status(500).json({ error: error.message });

    res.status(201).json({ success: true, shelfPlaces: data });
};


// PUT /shelf-places
const updateShelfPlace = async (req, res) => {
    const { shelf_id, product_id , last_updated_by } = req.body;

    const { data, error } = await supabase
        .from('shelf_place')
        .update({ last_updated_by })
        .eq('shelf_id', shelf_id)
        .eq('product_id', product_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Shelf place not found' });

    res.status(200).json({ success: true, shelfPlace: data[0] });
};

// DELETE /shelf-places
const deleteShelfPlace = async (req, res) => {
    const { shelf_id, product_id } = req.body;

    const { data, error } = await supabase
        .from('shelf_place')
        .delete()
        .eq('shelf_id', shelf_id)
        .eq('product_id', product_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data || !data.length) return res.status(404).json({ error: 'Shelf place not found' });

    res.status(200).json({ success: true, message: 'Shelf place deleted successfully' });
};

module.exports = { getShelfPlaces, createShelfPlace, updateShelfPlace, deleteShelfPlace };