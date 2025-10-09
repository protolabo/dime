const supabase = require('../../supabaseClient');

// GET /priced-products
const getPricedProducts = async (req, res) => {
    try {
        let { store_id, product_id } = req.query;
        let query = supabase.from('priced_product').select('*');
        if (store_id) query = query.eq('store_id', store_id);

        if (product_id) {
            if (Array.isArray(product_id)) {
                query = query.in('product_id', product_id.map(Number));
            } else {
                query = query.eq('product_id', Number(product_id));
            }
        }

        const { data, error } = await query;
        if (error) return res.status(500).json({ error: error.message });

        res.status(200).json({ pricedProducts: data });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
};


// POST /priced-products
const createPricedProduct = async (req, res) => {
    const {
        store_id,
        product_id,
        amount,
        currency,
        pricing_unit,
        available,
        promotion_id,
        created_by,
    } = req.body;

    const { data, error } = await supabase
        .from('priced_product')
        .insert([
            {
                store_id,
                product_id,
                amount,
                currency,
                pricing_unit,
                available,
                promotion_id,
                created_by,
            },
        ])
        .select();

    if (error) return res.status(500).json({ error: error.message });

    res.status(201).json({ success: true, pricedProduct: data[0] });
};

// PUT /priced-products
const updatePricedProduct = async (req, res) => {
    const { store_id, product_id } = req.body;
    const {
        amount,
        currency,
        pricing_unit,
        available,
        promotion_id,
        last_updated_by,
    } = req.body;

    const { data, error } = await supabase
        .from('priced_product')
        .update({
            amount,
            currency,
            pricing_unit,
            available,
            promotion_id,
            last_updated_by,
        })
        .eq('store_id', store_id)
        .eq('product_id', product_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data.length) return res.status(404).json({ error: 'Priced product not found' });

    res.status(200).json({ success: true, pricedProduct: data[0] });
};

// DELETE /priced-products
const deletePricedProduct = async (req, res) => {
    const { store_id, product_id } = req.body;

    const { data, error } = await supabase
        .from('priced_product')
        .delete()
        .eq('store_id', store_id)
        .eq('product_id', product_id)
        .select();

    if (error) return res.status(500).json({ error: error.message });
    if (!data || !data.length) return res.status(404).json({ error: 'Priced product not found' });
    res.status(200).json({ success: true, message: 'Priced product deleted successfully' });
};

module.exports = {
    getPricedProducts,
    createPricedProduct,
    updatePricedProduct,
    deletePricedProduct,
};