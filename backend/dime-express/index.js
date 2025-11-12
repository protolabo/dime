require('dotenv').config();
const express = require('express');
const productRoutes = require('./database/routes/productRoutes');
const favoriteProductRoutes = require('./database/routes/favoriteProductRoutes');
const storeRoutes = require('./database/routes/storeRoutes');
const promotionRoutes = require('./database/routes/promotionRoutes');
const shelfRoutes = require('./database/routes/shelfRoutes');
const alertRoutes = require('./database/routes/alertRoutes');
const favoriteStoreRoutes = require('./database/routes/favoriteStoreRoutes');
const pricedProductRoutes = require('./database/routes/pricedProductRoutes');
const reviewRoutes = require('./database/routes/reviewRoutes');
const shelfPlaceRoutes = require('./database/routes/shelfPlaceRoutes');
const app = express();
const port = process.env.PORT || 3001;
const cors = require('cors');
const authRoutes = require('./database/routes/auth');





app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);
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
