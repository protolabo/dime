require('dotenv').config();
const express = require('express');
const productRoutes = require('./routes/productRoutes');
const favoriteProductRoutes = require('./routes/favoriteProductRoutes');
const storeRoutes = require('./routes/storeRoutes');
const promotionRoutes = require('./routes/promotionRoutes');
const shelfRoutes = require('./routes/shelfRoutes');
const alertRoutes = require('./routes/alertRoutes');
const favoriteStoreRoutes = require('./routes/favoriteStoreRoutes');
const pricedProductRoutes = require('./routes/pricedProductRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const shelfPlaceRoutes = require('./routes/shelfPlaceRoutes');
const app = express();
const port = process.env.PORT || 3001;
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');





app.use(cors());
app.use(express.json());
app.use('/auth', authRoutes);
app.use('/shelf-places', shelfPlaceRoutes);
app.use('/reviews', reviewRoutes);
app.use('/priced-products', pricedProductRoutes);
app.use('/products', productRoutes);
app.use('/favorite-products', favoriteProductRoutes);
app.use('/stores', storeRoutes);
app.use('/promotions', promotionRoutes);
app.use('/shelves', shelfRoutes);
app.use('/alerts', alertRoutes);
app.use('/favorite-stores', favoriteStoreRoutes);
app.listen(port, () => {
  console.log(` Serveur Dime : http://localhost:${port}`);
});
