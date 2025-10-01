const supabase = require('../../supabaseClient');

// GET /stores (avec ou sans store_id)
const getStores = async (req, res) => {
    try {
        const { store_id } = req.query;

        // Si on fournit store_id en query param, on filtre par store
        let query = supabase
            .from('store')
            .select('*')

        if (store_id) {
            query = query.eq('store_id', store_id);
        }

        const { data, error } = await query;
        if (error) {
            return res.status(500).json({ error: error.message });
        }

        res.status(200).json({ favorites: data });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};
// POST /stores
const createStores = async (req, res) => {
    const {store_id,actor_id,name,address,city,postal_code,country,product_id,created_at,created_by} = req.body;

    const { data, error } = await supabase
        .from('store')
        .insert([{store_id,actor_id,name,address,city,postal_code,country,product_id,created_at,created_by}])
        .select();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.status(201).json({ success: true, favorite: data[0] });
};
// PUT /stores/:store_id
const updateStore = async (req, res) => {
    const { store_id } = req.params;
    const { name, address, city, postal_code, country, product_id, updated_by } = req.body;

    try {
        const { data, error } = await supabase
            .from('store')
            .update({ name, address, city, postal_code, country, product_id, updated_by })
            .eq('store_id', store_id)
            .select();

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        res.status(200).json({ success: true, store: data[0] });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};

// DELETE /stores/:store_id
const deleteStore = async (req, res) => {
    const { store_id } = req.params;

    try {
        const { data, error } = await supabase
            .from('store')
            .delete()
            .eq('store_id', store_id);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        res.status(200).json({ success: true, message: 'Store deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};

module.exports = {
    getStores,
    createStores,
    updateStore,
    deleteStore,
};

