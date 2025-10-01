const express = require('express');
const router = express.Router();
const { getShelves, createShelf, updateShelf, deleteShelf } = require('../controllers/shelfController');

// GET /shelves
router.get('/', getShelves);

// POST /shelves
router.post('/', createShelf);

// PUT /shelves/:shelf_id
router.put('/:shelf_id', updateShelf);

// DELETE /shelves/:shelf_id
router.delete('/:shelf_id', deleteShelf);

module.exports = router;