// database/routes/favoriteProductRoutes.js

const express = require('express');
const router = express.Router();
const {
  getFavorites,
  createFavorite,
} = require('../controllers/favoriteProductController');

// GET /favorite_products?actor_id=123
router.get('/', getFavorites);

// POST /favorite_products
// body: { actor_id, product_id, store_id, created_by }
router.post('/', createFavorite);

module.exports = router;
