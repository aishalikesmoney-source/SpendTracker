require('dotenv').config();
const express = require('express');
const cors = require('cors');
const plaidRoutes = require('./routes/plaid');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: '*' }));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', env: process.env.PLAID_ENV || 'sandbox' });
});

app.use('/api', plaidRoutes);

app.use((err, req, res, next) => {
  console.error('[SpendTrack Server Error]', err.message);
  res.status(500).json({ error: err.message });
});

app.listen(PORT, () => {
  console.log(`\n🚀 SpendTrack server running at http://localhost:${PORT}`);
  console.log(`   Plaid environment: ${process.env.PLAID_ENV || 'sandbox'}`);
  console.log(`   Health check: http://localhost:${PORT}/health\n`);
});
