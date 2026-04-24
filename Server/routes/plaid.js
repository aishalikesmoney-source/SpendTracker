const express = require('express');
const fs = require('fs');
const path = require('path');
const {
  Configuration,
  PlaidApi,
  PlaidEnvironments,
  Products,
  CountryCode,
} = require('plaid');

const router = express.Router();

// ── Plaid client setup ──────────────────────────────────────────────────────

const plaidEnv = process.env.PLAID_ENV || 'sandbox';

const plaidClient = new PlaidApi(
  new Configuration({
    basePath: PlaidEnvironments[plaidEnv],
    baseOptions: {
      headers: {
        'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
        'PLAID-SECRET': process.env.PLAID_SECRET,
      },
    },
  })
);

// ── Local storage (JSON file) ───────────────────────────────────────────────

const DATA_DIR = path.join(__dirname, '..', 'data');
const ITEMS_FILE = path.join(DATA_DIR, 'items.json');

function loadItems() {
  if (!fs.existsSync(ITEMS_FILE)) return {};
  try { return JSON.parse(fs.readFileSync(ITEMS_FILE, 'utf-8')); }
  catch { return {}; }
}

function saveItems(items) {
  if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
  fs.writeFileSync(ITEMS_FILE, JSON.stringify(items, null, 2));
}

// ── Routes ──────────────────────────────────────────────────────────────────

/**
 * POST /api/link-token
 * Creates a Plaid Link token to initialize the iOS Link flow.
 */
router.post('/link-token', async (req, res, next) => {
  try {
    const { user_id = 'local_user' } = req.body;
    const response = await plaidClient.linkTokenCreate({
      user: { client_user_id: user_id },
      client_name: 'SpendTrack',
      products: [Products.Transactions],
      country_codes: [CountryCode.Us],
      language: 'en',
      redirect_uri: process.env.PLAID_REDIRECT_URI || undefined,
    });
    res.json({ link_token: response.data.link_token });
  } catch (err) {
    next(plaidError(err));
  }
});

/**
 * POST /api/exchange-token
 * Exchanges a public_token for an access_token and persists it locally.
 */
router.post('/exchange-token', async (req, res, next) => {
  try {
    const { public_token } = req.body;
    if (!public_token) return res.status(400).json({ error: 'public_token required' });

    const exchangeResp = await plaidClient.itemPublicTokenExchange({ public_token });
    const { access_token, item_id } = exchangeResp.data;

    // Fetch item details for institution info
    const itemResp = await plaidClient.itemGet({ access_token });
    const institutionId = itemResp.data.item.institution_id;

    let institutionName = 'Unknown Bank';
    let institutionColor = '#1D4ED8';
    if (institutionId) {
      try {
        const instResp = await plaidClient.institutionsGetById({
          institution_id: institutionId,
          country_codes: [CountryCode.Us],
          options: { include_optional_metadata: true },
        });
        const inst = instResp.data.institution;
        institutionName = inst.name;
        institutionColor = inst.primary_color || '#1D4ED8';
      } catch (_) {}
    }

    // Persist
    const items = loadItems();
    items[item_id] = { access_token, institution_id: institutionId, institution_name: institutionName, sync_cursor: null };
    saveItems(items);

    res.json({ item_id, institution_id: institutionId, institution_name: institutionName, institution_color: institutionColor });
  } catch (err) {
    next(plaidError(err));
  }
});

/**
 * POST /api/sync
 * Fetches accounts + incremental transactions for a given item_id.
 */
router.post('/sync', async (req, res, next) => {
  try {
    const { item_id, cursor } = req.body;
    if (!item_id) return res.status(400).json({ error: 'item_id required' });

    const items = loadItems();
    const item = items[item_id];
    if (!item) return res.status(404).json({ error: 'Item not found. Re-connect this account.' });

    const { access_token } = item;
    const effectiveCursor = cursor || item.sync_cursor || undefined;

    // Accounts
    const accountsResp = await plaidClient.accountsGet({ access_token });
    const accounts = accountsResp.data.accounts.map(a => ({
      account_id: a.account_id,
      name: a.name,
      official_name: a.official_name,
      type: a.type,
      subtype: a.subtype,
      mask: a.mask,
      current_balance: a.balances.current,
      available_balance: a.balances.available,
      iso_currency_code: a.balances.iso_currency_code,
    }));

    // Transactions (sync API with cursor)
    let added = [], modified = [], removed = [], nextCursor = effectiveCursor;
    let hasMore = true;

    while (hasMore) {
      const syncResp = await plaidClient.transactionsSync({
        access_token,
        cursor: nextCursor,
        options: { include_personal_finance_category: true },
      });
      const { data } = syncResp;
      added = added.concat(data.added);
      modified = modified.concat(data.modified);
      removed = removed.concat(data.removed);
      nextCursor = data.next_cursor;
      hasMore = data.has_more;
    }

    // Persist cursor
    items[item_id].sync_cursor = nextCursor;
    saveItems(items);

    const mapTx = tx => ({
      transaction_id: tx.transaction_id,
      account_id: tx.account_id,
      name: tx.name,
      merchant_name: tx.merchant_name,
      amount: tx.amount,
      date: tx.date,
      primary_category: tx.personal_finance_category?.primary ?? 'OTHER',
      detailed_category: tx.personal_finance_category?.detailed ?? 'OTHER',
      pending: tx.pending,
      logo_url: tx.logo_url,
    });

    res.json({
      accounts,
      added: added.map(mapTx),
      modified: modified.map(mapTx),
      removed: removed.map(r => r.transaction_id),
      next_cursor: nextCursor,
    });
  } catch (err) {
    next(plaidError(err));
  }
});

/**
 * DELETE /api/item/:itemId
 * Removes an item from Plaid and local storage.
 */
router.delete('/item/:itemId', async (req, res, next) => {
  try {
    const { itemId } = req.params;
    const items = loadItems();
    const item = items[itemId];

    if (item) {
      try { await plaidClient.itemRemove({ access_token: item.access_token }); }
      catch (_) {}
      delete items[itemId];
      saveItems(items);
    }

    res.json({ removed: true });
  } catch (err) {
    next(plaidError(err));
  }
});

// ── Error helper ────────────────────────────────────────────────────────────

function plaidError(err) {
  const msg = err?.response?.data?.error_message || err?.message || 'Plaid error';
  const code = err?.response?.data?.error_code;
  console.error('[Plaid]', code, msg);
  const error = new Error(code ? `${code}: ${msg}` : msg);
  error.status = err?.response?.status || 500;
  return error;
}

module.exports = router;
