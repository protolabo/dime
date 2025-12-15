const supabase = require('../supabaseClient');

// GET /favorite-stores
const getFavoriteStores = async (req, res) => {
    try {
        const { actor_id,store_id } = req.query;

        let query = supabase.from('favorite_store').select('*,store(name)');
        if (actor_id) {
            query = query.eq('actor_id', actor_id);
        }
        if (store_id) {
            query = query.eq('store_id', store_id);
        }

        const { data, error } = await query;
        if (error) return res.status(500).json({ error: error.message });

        res.status(200).json({ favoriteStores: data });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};

// POST /favorite-stores
const createFavoriteStore = async (req, res) => {
    const { actor_id, store_id, created_by } = req.body;

    const { data, error } = await supabase
        .from('favorite_store')
        .insert([{ actor_id, store_id, created_by }])
        .select();

    if (error) return res.status(500).json({ error: error.message });

    res.status(201).json({ success: true, favoriteStore: data[0] });
};

// DELETE /favorite-stores/:actor_id/:store_id
const deleteFavoriteStore = async (req, res) => {
    const { actor_id, store_id } = req.params;

    const { data, error } = await supabase
        .from('favorite_store')
        .delete()
        .eq('actor_id', actor_id)
        .eq('store_id', store_id)
        .select();
    if (error) return res.status(500).json({ error: error.message });
    if (!data || !data.length) return res.status(404).json({ error: 'Favorite store not found' });
    res.status(200).json({ success: true, message: 'Favorite store deleted successfully' });
};


module.exports = { getFavoriteStores, createFavoriteStore, deleteFavoriteStore };