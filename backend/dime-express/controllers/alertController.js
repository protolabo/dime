const supabase = require('../supabaseClient');

// GET /alerts
const getAlerts = async (_req, res) => {
    const { data, error } = await supabase.from('alert').select('*');
    if (error) return res.status(500).json({ error: error.message });
    res.status(200).json({ alerts: data });
};

// POST /alerts
const createAlert = async (req, res) => {
    const { actor_id, product_id, store_id, message, is_seen, created_by } = req.body;

    const { data, error } = await supabase
        .from('alert')
        .insert([{ actor_id, product_id, store_id, message, is_seen, created_by }])
        .select();

    if (error) return res.status(500).json({ error: error.message });
    res.status(201).json({ success: true, alert: data[0] });
};

// PUT /alerts
const updateAlert = async (req, res) => {
    const { actor_id, product_id, store_id, message, is_seen, last_updated_by } = req.body;

    const { data, error } = await supabase
        .from('alert')
        .update({ message, is_seen, last_updated_by })
        .eq('actor_id', actor_id)
        .eq('product_id', product_id)
        .eq('store_id', store_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Alert not found' });

    res.status(200).json({ success: true, alert: data[0] });
};

// DELETE /alerts
const deleteAlert = async (req, res) => {
    const { actor_id, product_id, store_id } = req.body;

    const { data, error } = await supabase
        .from('alert')
        .delete()
        .eq('actor_id', actor_id)
        .eq('product_id', product_id)
        .eq('store_id', store_id);

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Alert not found' });

    res.status(200).json({ success: true, message: 'Alert deleted successfully' });
};

module.exports = { getAlerts, createAlert, updateAlert, deleteAlert };