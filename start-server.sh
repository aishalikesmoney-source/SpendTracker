#!/bin/bash
# SpendTrack — Start the local Plaid backend server

set -e
cd "$(dirname "$0")/Server"

if [ ! -f .env ]; then
  echo "⚠️  No .env file found."
  echo "   Copy .env.example to .env and add your Plaid credentials:"
  echo "   cp .env.example .env"
  echo ""
  echo "   Get your Plaid keys at: https://dashboard.plaid.com/team/keys"
  exit 1
fi

if [ ! -d node_modules ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

echo "🚀 Starting SpendTrack server..."
npm start
