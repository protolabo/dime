const supabase = require('../../supabaseClient');

const getProducts = async (_req, res) => {
  const { data, error } = await supabase.from('product').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json({ products: data });
};

const createProduct = async (req, res) => {
  const { name, bar_code, description, category, image_url, qr_code, created_by } = req.body;

  const { data, error } = await supabase
    .from('product')
    .insert([{ name, bar_code, description, category, image_url, qr_code, created_by }])
    .select();

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json({ success: true, product: data[0] });
};

module.exports = { getProducts, createProduct };
