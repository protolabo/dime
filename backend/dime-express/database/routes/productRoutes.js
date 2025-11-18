const express = require('express');
const router = express.Router();
const { getProducts, createProduct, updateProduct, deleteProduct, upload } = require('../controllers/productController');

router.get('/', getProducts);
router.post('/', upload.single('image'), createProduct);
router.put('/:product_id', updateProduct);
router.delete('/:product_id', deleteProduct);

module.exports = router;

