const express = require('express');
const router = express.Router();
const {
    getPricedProducts,
    createPricedProduct,
    updatePricedProduct,
    deletePricedProduct,
} = require('../controllers/pricedProductController');

// GET /priced-products
router.get('/', getPricedProducts);

// POST /priced-products
router.post('/', createPricedProduct);

// PUT /priced-products
router.put('/', updatePricedProduct);

// DELETE /priced-products
router.delete('/', deletePricedProduct);

module.exports = router;