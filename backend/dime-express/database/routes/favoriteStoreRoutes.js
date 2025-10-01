const express = require('express');
const router = express.Router();
const { getFavoriteStores, createFavoriteStore, deleteFavoriteStore } = require('../controllers/favoriteStoreController');

// GET /favorite-stores
router.get('/', getFavoriteStores);

// POST /favorite-stores
router.post('/', createFavoriteStore);

// DELETE /favorite-stores
router.delete('/', deleteFavoriteStore);

module.exports = router;