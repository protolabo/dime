const express = require('express');
const router = express.Router();
const { getPromotions, createPromotion, updatePromotion, deletePromotion } = require('../controllers/promotionController');

// GET /promotions
router.get('/', getPromotions);

// POST /promotions
router.post('/', createPromotion);

// PUT /promotions/:id
router.put('/:promotion_id', updatePromotion);

// DELETE /promotions/:id
router.delete('/:promotion_id', deletePromotion);

module.exports = router;