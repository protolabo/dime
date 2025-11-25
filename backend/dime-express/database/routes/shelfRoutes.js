const express = require('express');
const router = express.Router();
const {
    getShelves,
    createShelf,
    updateShelf,
    deleteShelf,
    updateShelfImage
} = require('../controllers/shelfController');

const multer = require('multer');
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB max
});

// GET /shelves
router.get('/', getShelves);
// POST /shelves
router.post('/', createShelf);
router.put('/:shelf_id', updateShelf);
// DELETE /shelves/:shelf_id
router.delete('/:shelf_id', deleteShelf);
// PUT /shelves/:shelf_id
router.put('/:shelf_id/image', upload.single('image'), updateShelfImage);

module.exports = router;