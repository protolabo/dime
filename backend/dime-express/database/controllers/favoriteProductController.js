const supabase = require('../../supabaseClient');

const getFavorites = async (req, res) => {
  try {
    const { actor_id,product_id } = req.query;

    // Si on fournit actor_id en query param, on filtre par acteur
    let query = supabase
      .from('favorite_product')
        .select("*, product(name)")

    if (actor_id) {
      query = query.eq('actor_id', actor_id);
    }
    if (product_id) {
      query = query.eq('product_id', product_id);
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

const createFavorite = async (req, res) => {
  const { actor_id, product_id, store_id, created_by } = req.body;

  const { data, error } = await supabase
    .from('favorite_product')
    .insert([{ actor_id, product_id, store_id, created_by}])
    .select();

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.status(201).json({ success: true, favorite: data[0] });
};

const deleteFavorite = async (req, res) => {
  const { actor_id,product_id } = req.params;

  const { data, error } = await supabase
      .from('favorite_product')
      .delete()
      .eq('product_id', product_id)
      .eq('actor_id', actor_id);

  if (error) return res.status(500).json({ error: error.message });
  if (!data.length) return res.status(404).json({ error: 'Favorite product not found' });

  res.status(200).json({ success: true, message: 'Favorite product deleted successfully' });
};

module.exports = {
  getFavorites,
  createFavorite,
  deleteFavorite,
};
