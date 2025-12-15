const express = require('express');
const router = express.Router();
const {
  getStores,
  createStores,
  updateStore,
  deleteStore,
  updateStoreLogo,
  upload
} = require('../controllers/storeController');

// PUT /stores/:store_id/logo
router.put('/:store_id/logo', upload.single('image'), updateStoreLogo);

// GET /stores (avec ou sans store_id)
router.get('/', getStores);

// POST /stores
router.post('/', createStores);

// PUT /stores/:id
router.put('/:store_id', updateStore);

// DELETE /stores/:id
router.delete('/:store_id', deleteStore);

module.exports = router;