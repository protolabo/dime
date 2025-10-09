// database/routes/favoriteProductRoutes.js

const express = require('express');
const router = express.Router();
const {
  getFavorites,
  createFavorite,deleteFavorite
} = require('../controllers/favoriteProductController');

// GET /favorite_products?actor_id=123
router.get('/', getFavorites);

// POST /favorite_products
router.post('/', createFavorite);

// DELETE /favorite_products
router.delete('/:actor_id/:product_id', deleteFavorite);
module.exports = router;
