const express = require('express');
const router = express.Router();
const { getReviews, createReview, updateReview, deleteReview } = require('../controllers/reviewController');

// GET /reviews
router.get('/', getReviews);

// POST /reviews
router.post('/', createReview);

// PUT /reviews
router.put('/', updateReview);

// DELETE /reviews
router.delete('/', deleteReview);

module.exports = router;