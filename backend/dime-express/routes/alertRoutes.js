const express = require('express');
const router = express.Router();
const { getAlerts, createAlert, updateAlert, deleteAlert } = require('../controllers/alertController');

// GET /alerts
router.get('/', getAlerts);

// POST /alerts
router.post('/', createAlert);

// PUT /alerts
router.put('/', updateAlert);

// DELETE /alerts
router.delete('/', deleteAlert);

module.exports = router;