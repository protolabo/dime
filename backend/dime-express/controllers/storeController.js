const supabase = require('../supabaseClient');
const multer = require("multer");
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB max
});
// GET /stores (avec ou sans store_id)
const getStores = async (req, res) => {
    try {
        const { store_id,queryClient } = req.query;

        // Si on fournit store_id en query param, on filtre par store
        let query = supabase
            .from('store')
            .select('*')

        if (store_id) {
            if (Array.isArray(store_id)) {
                query = query.in('store_id', store_id.map(Number));
            } else {
                query = query.eq('store_id', Number(store_id));
            }
        }
        if (queryClient) {
            const pattern = `%${queryClient}%`;
            query = query.or(`name.ilike.${pattern},address.ilike.${pattern},city.ilike.${pattern},postal_code.ilike.${pattern},country.ilike.${pattern}`);
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

// PUT /stores/:store_id/logo
const updateStoreLogo = async (req, res) => {
    const { store_id } = req.params;
console.log('Mise à jour du logo pour le store_id:', store_id);
    if (!req.file) {
        return res.status(400).json({ error: 'Aucune image fournie' });
    }

    try {
        const { uploadImageToCloudflare } = require('../services/cloudflareImageService');

        const logo_url = await uploadImageToCloudflare(
            req.file.buffer,
            `store-${store_id}-${Date.now()}-${req.file.originalname}`
        );

        const { data, error } = await supabase
            .from('store')
            .update({ logo_url })
            .eq('store_id', store_id)
            .select('store_id, logo_url')
            .single();

        if (error) {
            console.log('Erreur mise à jour logo dans la BDD:', error);
            return res.status(500).json({ error: error.message });
        }

        if (!data) {
            console.log('Magasin non trouvé pour la mise à jour du logo');
            return res.status(404).json({ error: 'Magasin introuvable' });
        }

        res.status(200).json({
            success: true,
            logo_url: data.logo_url
        });

    } catch (error) {
        console.log('Erreur lors de l\'upload du logo:', error);
        console.error('Erreur upload logo:', error);
        res.status(500).json({ error: 'Échec de la mise à jour du logo' });
    }
};

module.exports = {
    getStores,
    createStores,
    updateStore,
    deleteStore,
    updateStoreLogo,
    upload
};

