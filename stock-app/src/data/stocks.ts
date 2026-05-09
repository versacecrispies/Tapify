import type { Stock } from '../types'

// Curated large-cap stocks (market cap > $100B) with realistic historical &
// analyst-consensus forward figures as of early 2025.
export const RAW_STOCKS: Stock[] = [
  // ── Technology ────────────────────────────────────────────────────────────
  {
    ticker: 'NVDA', name: 'NVIDIA Corporation', industry: 'Technology',
    marketCapB: 2900, tenYearReturnPct: 29800, fiveYearReturnPct: 2640, oneYearReturnPct: 194,
    revenueGrowthCAGR: 24, epsGrowthCAGR: 28, analystUpsidePct: 18,
    moatScore: 9.5, sectorTailwindScore: 9.8, pegRatio: 1.4, forwardPE: 38, dividendYield: 0.03,
  },
  {
    ticker: 'AAPL', name: 'Apple Inc.', industry: 'Technology',
    marketCapB: 3200, tenYearReturnPct: 1050, fiveYearReturnPct: 310, oneYearReturnPct: 22,
    revenueGrowthCAGR: 7, epsGrowthCAGR: 11, analystUpsidePct: 9,
    moatScore: 9.2, sectorTailwindScore: 7.5, pegRatio: 2.6, forwardPE: 28, dividendYield: 0.5,
  },
  {
    ticker: 'MSFT', name: 'Microsoft Corporation', industry: 'Technology',
    marketCapB: 3100, tenYearReturnPct: 1020, fiveYearReturnPct: 215, oneYearReturnPct: 18,
    revenueGrowthCAGR: 14, epsGrowthCAGR: 16, analystUpsidePct: 14,
    moatScore: 9.4, sectorTailwindScore: 9.2, pegRatio: 2.0, forwardPE: 32, dividendYield: 0.7,
  },
  {
    ticker: 'GOOGL', name: 'Alphabet Inc.', industry: 'Technology',
    marketCapB: 2100, tenYearReturnPct: 530, fiveYearReturnPct: 185, oneYearReturnPct: 35,
    revenueGrowthCAGR: 12, epsGrowthCAGR: 15, analystUpsidePct: 17,
    moatScore: 9.0, sectorTailwindScore: 9.0, pegRatio: 1.4, forwardPE: 21, dividendYield: 0.5,
  },
  {
    ticker: 'META', name: 'Meta Platforms', industry: 'Technology',
    marketCapB: 1490, tenYearReturnPct: 780, fiveYearReturnPct: 290, oneYearReturnPct: 73,
    revenueGrowthCAGR: 16, epsGrowthCAGR: 20, analystUpsidePct: 13,
    moatScore: 8.8, sectorTailwindScore: 8.5, pegRatio: 1.3, forwardPE: 25, dividendYield: 0.4,
  },
  {
    ticker: 'AVGO', name: 'Broadcom Inc.', industry: 'Technology',
    marketCapB: 780, tenYearReturnPct: 2750, fiveYearReturnPct: 560, oneYearReturnPct: 98,
    revenueGrowthCAGR: 20, epsGrowthCAGR: 22, analystUpsidePct: 16,
    moatScore: 8.5, sectorTailwindScore: 9.0, pegRatio: 1.6, forwardPE: 34, dividendYield: 1.3,
  },
  {
    ticker: 'TSM', name: 'Taiwan Semiconductor', industry: 'Technology',
    marketCapB: 870, tenYearReturnPct: 680, fiveYearReturnPct: 260, oneYearReturnPct: 88,
    revenueGrowthCAGR: 18, epsGrowthCAGR: 20, analystUpsidePct: 21,
    moatScore: 9.3, sectorTailwindScore: 9.5, pegRatio: 1.3, forwardPE: 26, dividendYield: 1.2,
  },
  // ── Healthcare ────────────────────────────────────────────────────────────
  {
    ticker: 'LLY', name: 'Eli Lilly & Co.', industry: 'Healthcare',
    marketCapB: 740, tenYearReturnPct: 1940, fiveYearReturnPct: 725, oneYearReturnPct: 53,
    revenueGrowthCAGR: 22, epsGrowthCAGR: 28, analystUpsidePct: 22,
    moatScore: 8.8, sectorTailwindScore: 9.3, pegRatio: 1.5, forwardPE: 42, dividendYield: 0.7,
  },
  {
    ticker: 'UNH', name: 'UnitedHealth Group', industry: 'Healthcare',
    marketCapB: 450, tenYearReturnPct: 600, fiveYearReturnPct: 130, oneYearReturnPct: -12,
    revenueGrowthCAGR: 9, epsGrowthCAGR: 11, analystUpsidePct: 28,
    moatScore: 8.5, sectorTailwindScore: 7.8, pegRatio: 1.4, forwardPE: 15, dividendYield: 1.6,
  },
  {
    ticker: 'ABBV', name: 'AbbVie Inc.', industry: 'Healthcare',
    marketCapB: 315, tenYearReturnPct: 390, fiveYearReturnPct: 120, oneYearReturnPct: 15,
    revenueGrowthCAGR: 7, epsGrowthCAGR: 9, analystUpsidePct: 12,
    moatScore: 7.8, sectorTailwindScore: 7.5, pegRatio: 2.0, forwardPE: 18, dividendYield: 3.3,
  },
  {
    ticker: 'NVO', name: 'Novo Nordisk', industry: 'Healthcare',
    marketCapB: 520, tenYearReturnPct: 1550, fiveYearReturnPct: 470, oneYearReturnPct: -20,
    revenueGrowthCAGR: 19, epsGrowthCAGR: 23, analystUpsidePct: 30,
    moatScore: 8.7, sectorTailwindScore: 9.2, pegRatio: 1.2, forwardPE: 28, dividendYield: 1.2,
  },
  // ── Financials ────────────────────────────────────────────────────────────
  {
    ticker: 'V', name: 'Visa Inc.', industry: 'Financials',
    marketCapB: 600, tenYearReturnPct: 570, fiveYearReturnPct: 85, oneYearReturnPct: 21,
    revenueGrowthCAGR: 10, epsGrowthCAGR: 13, analystUpsidePct: 14,
    moatScore: 9.5, sectorTailwindScore: 8.0, pegRatio: 2.0, forwardPE: 26, dividendYield: 0.8,
  },
  {
    ticker: 'MA', name: 'Mastercard Inc.', industry: 'Financials',
    marketCapB: 470, tenYearReturnPct: 620, fiveYearReturnPct: 95, oneYearReturnPct: 22,
    revenueGrowthCAGR: 12, epsGrowthCAGR: 14, analystUpsidePct: 13,
    moatScore: 9.4, sectorTailwindScore: 8.0, pegRatio: 1.9, forwardPE: 27, dividendYield: 0.6,
  },
  {
    ticker: 'JPM', name: 'JPMorgan Chase', industry: 'Financials',
    marketCapB: 620, tenYearReturnPct: 310, fiveYearReturnPct: 115, oneYearReturnPct: 48,
    revenueGrowthCAGR: 6, epsGrowthCAGR: 8, analystUpsidePct: 7,
    moatScore: 8.8, sectorTailwindScore: 7.5, pegRatio: 2.0, forwardPE: 16, dividendYield: 2.2,
  },
  {
    ticker: 'BRK.B', name: 'Berkshire Hathaway B', industry: 'Financials',
    marketCapB: 1000, tenYearReturnPct: 245, fiveYearReturnPct: 120, oneYearReturnPct: 27,
    revenueGrowthCAGR: 5, epsGrowthCAGR: 8, analystUpsidePct: 9,
    moatScore: 9.0, sectorTailwindScore: 7.0, pegRatio: 1.8, forwardPE: 22, dividendYield: 0.0,
  },
  // ── Consumer Discretionary ────────────────────────────────────────────────
  {
    ticker: 'AMZN', name: 'Amazon.com Inc.', industry: 'Consumer Discretionary',
    marketCapB: 2100, tenYearReturnPct: 800, fiveYearReturnPct: 85, oneYearReturnPct: 44,
    revenueGrowthCAGR: 13, epsGrowthCAGR: 22, analystUpsidePct: 20,
    moatScore: 9.3, sectorTailwindScore: 8.8, pegRatio: 1.5, forwardPE: 33, dividendYield: 0.0,
  },
  {
    ticker: 'TSLA', name: 'Tesla Inc.', industry: 'Consumer Discretionary',
    marketCapB: 720, tenYearReturnPct: 1280, fiveYearReturnPct: 265, oneYearReturnPct: -10,
    revenueGrowthCAGR: 18, epsGrowthCAGR: 25, analystUpsidePct: 10,
    moatScore: 7.5, sectorTailwindScore: 8.5, pegRatio: 2.2, forwardPE: 55, dividendYield: 0.0,
  },
  {
    ticker: 'HD', name: 'Home Depot Inc.', industry: 'Consumer Discretionary',
    marketCapB: 375, tenYearReturnPct: 490, fiveYearReturnPct: 60, oneYearReturnPct: 18,
    revenueGrowthCAGR: 5, epsGrowthCAGR: 8, analystUpsidePct: 11,
    moatScore: 8.2, sectorTailwindScore: 6.8, pegRatio: 2.5, forwardPE: 20, dividendYield: 2.3,
  },
  // ── Communication Services ─────────────────────────────────────────────────
  {
    ticker: 'NFLX', name: 'Netflix Inc.', industry: 'Communication Services',
    marketCapB: 395, tenYearReturnPct: 1730, fiveYearReturnPct: 255, oneYearReturnPct: 83,
    revenueGrowthCAGR: 13, epsGrowthCAGR: 24, analystUpsidePct: 11,
    moatScore: 7.8, sectorTailwindScore: 8.0, pegRatio: 1.4, forwardPE: 34, dividendYield: 0.0,
  },
  {
    ticker: 'DIS', name: 'Walt Disney Co.', industry: 'Communication Services',
    marketCapB: 190, tenYearReturnPct: 48, fiveYearReturnPct: -30, oneYearReturnPct: 14,
    revenueGrowthCAGR: 6, epsGrowthCAGR: 18, analystUpsidePct: 20,
    moatScore: 8.0, sectorTailwindScore: 7.0, pegRatio: 1.2, forwardPE: 21, dividendYield: 0.8,
  },
  // ── Energy ────────────────────────────────────────────────────────────────
  {
    ticker: 'XOM', name: 'Exxon Mobil Corp.', industry: 'Energy',
    marketCapB: 520, tenYearReturnPct: 150, fiveYearReturnPct: 130, oneYearReturnPct: 14,
    revenueGrowthCAGR: 3, epsGrowthCAGR: 5, analystUpsidePct: 10,
    moatScore: 8.0, sectorTailwindScore: 6.0, pegRatio: 2.5, forwardPE: 14, dividendYield: 3.5,
  },
  {
    ticker: 'CVX', name: 'Chevron Corporation', industry: 'Energy',
    marketCapB: 270, tenYearReturnPct: 88, fiveYearReturnPct: 90, oneYearReturnPct: -3,
    revenueGrowthCAGR: 3, epsGrowthCAGR: 5, analystUpsidePct: 13,
    moatScore: 7.8, sectorTailwindScore: 6.0, pegRatio: 2.4, forwardPE: 14, dividendYield: 4.5,
  },
  // ── Industrials ───────────────────────────────────────────────────────────
  {
    ticker: 'CAT', name: 'Caterpillar Inc.', industry: 'Industrials',
    marketCapB: 195, tenYearReturnPct: 500, fiveYearReturnPct: 195, oneYearReturnPct: 9,
    revenueGrowthCAGR: 5, epsGrowthCAGR: 9, analystUpsidePct: 8,
    moatScore: 8.2, sectorTailwindScore: 7.2, pegRatio: 1.9, forwardPE: 18, dividendYield: 1.5,
  },
  {
    ticker: 'HON', name: 'Honeywell International', industry: 'Industrials',
    marketCapB: 133, tenYearReturnPct: 185, fiveYearReturnPct: 30, oneYearReturnPct: 6,
    revenueGrowthCAGR: 5, epsGrowthCAGR: 8, analystUpsidePct: 14,
    moatScore: 7.8, sectorTailwindScore: 7.5, pegRatio: 2.1, forwardPE: 21, dividendYield: 2.2,
  },
  {
    ticker: 'GE', name: 'GE Aerospace', industry: 'Industrials',
    marketCapB: 195, tenYearReturnPct: 410, fiveYearReturnPct: 355, oneYearReturnPct: 95,
    revenueGrowthCAGR: 8, epsGrowthCAGR: 18, analystUpsidePct: 16,
    moatScore: 8.0, sectorTailwindScore: 8.5, pegRatio: 1.6, forwardPE: 30, dividendYield: 0.7,
  },
]
