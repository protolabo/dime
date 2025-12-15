const supabase = require('../supabaseClient');

// GET /reviews
const getReviews = async (req, res) => {
    try {
        const { actor_id, product_id, store_id } = req.query;

        let query = supabase.from('review').select('*');
        if (actor_id) query = query.eq('actor_id', actor_id);
        if (product_id) query = query.eq('product_id', product_id);
        if (store_id) query = query.eq('store_id', store_id);

        const { data, error } = await query;
        if (error) return res.status(500).json({ error: error.message });

        res.status(200).json({ reviews: data });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};

// POST /reviews
const createReview = async (req, res) => {
    const { actor_id, product_id, store_id, rating, created_by } = req.body;

    const { data, error } = await supabase
        .from('review')
        .insert([{ actor_id, product_id, store_id, rating, created_by }])
        .select();

    if (error) return res.status(500).json({ error: error.message });

    res.status(201).json({ success: true, review: data[0] });
};

// PUT /reviews
const updateReview = async (req, res) => {
    const { review_id } = req.body;
    const { rating, last_updated_by } = req.body;

    const { data, error } = await supabase
        .from('review')
        .update({ rating, last_updated_by })
        .eq('review_id', review_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Review not found' });

    res.status(200).json({ success: true, review: data[0] });
};

// DELETE /reviews
const deleteReview = async (req, res) => {
    const { review_id } = req.body;

    const { data, error } = await supabase
        .from('review')
        .delete()
        .eq('review_id', review_id);

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Review not found' });

    res.status(200).json({ success: true, message: 'Review deleted successfully' });
};

module.exports = { getReviews, createReview, updateReview, deleteReview };