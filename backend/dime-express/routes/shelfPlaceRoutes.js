const express = require('express');
const router = express.Router();
const {
    getShelfPlaces,
    createShelfPlace,
    updateShelfPlace,
    deleteShelfPlace,
} = require('../controllers/shelfPlaceController');

// GET /shelf-places
router.get('/', getShelfPlaces);

// POST /shelf-places
router.post('/', createShelfPlace);

// PUT /shelf-places
router.put('/', updateShelfPlace);

// DELETE /shelf-places
router.delete('/', deleteShelfPlace);

module.exports = router;