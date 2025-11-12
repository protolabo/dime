const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

//Client routes
router.post('/client/signup', authController.clientSignUp);
router.post('/client/signin', authController.clientSignIn);

//Commercant routes
router.post('/commercant/signup', authController.commercantSignUp);
router.post('/commercant/signin', authController.commercantSignIn);

//Common routes
router.post('/signout', authController.signOut);
router.get('/user', authController.getCurrentUser);

module.exports = router;