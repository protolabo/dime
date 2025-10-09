const supabase = require('../../supabaseClient');

// GET /promotions
const getPromotions = async (_req, res) => {
    try {
        const {promotion_id} = _req.query;
        let query = supabase.from('promotion').select('*');
        if (promotion_id) {
            if (Array.isArray(promotion_id)) {
                query = query.in('promotion_id', promotion_id.map(Number));
            } else {
                query = query.eq('promotion_id', Number(promotion_id));
            }
        }

        const { data, error } = await query;
        if (error) return res.status(500).json({ error: error.message });
        res.status(200).json({ reviews: data });
    }
    catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};

// POST /promotions
const createPromotion = async (req, res) => {
    const { title,promotion_id, description, start_date, end_date, created_by, created_at } = req.body;

    const { data, error } = await supabase
        .from('promotion')
        .insert([{ title,promotion_id, description, start_date, end_date, created_by, created_at }])
        .select();

    if (error) return res.status(500).json({ error: error.message });
    res.status(201).json({ success: true, promotion: data[0] });
};

// PUT /promotions/:promotion_id
const updatePromotion = async (req, res) => {
    const { promotion_id } = req.params;
    const { title, description, start_date, end_date, last_updated_by, last_updated_at } = req.body;

    const { data, error } = await supabase
        .from('promotion')
        .update({ title, description, start_date, end_date, last_updated_by, last_updated_at })
        .eq('promotion_id', promotion_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Promotion not found' });

    res.status(200).json({ success: true, promotion: data[0] });
};

// DELETE /promotions/:promotion_id
const deletePromotion = async (req, res) => {
    const { promotion_id } = req.params;

    const { data, error } = await supabase
        .from('promotion')
        .delete()
        .eq('promotion_id', promotion_id);

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Promotion not found' });

    res.status(200).json({ success: true, message: 'Promotion deleted successfully' });
};

module.exports = { getPromotions, createPromotion, updatePromotion, deletePromotion };