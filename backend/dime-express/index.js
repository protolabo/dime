require('dotenv').config();
const express = require('express');
const productRoutes = require('./database/routes/productRoutes');

const app = express();
const port = process.env.PORT || 3001;

app.use(express.json());
app.use('/products', productRoutes); // << raccourci

app.listen(port, () => {
  console.log(`✅ Serveur Dime : http://localhost:${port}`);
});
