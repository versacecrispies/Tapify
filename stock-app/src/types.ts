export type Industry =
  | 'Technology'
  | 'Healthcare'
  | 'Financials'
  | 'Consumer Discretionary'
  | 'Communication Services'
  | 'Energy'
  | 'Industrials'

export interface Stock {
  ticker: string
  name: string
  industry: Industry
  marketCapB: number        // market cap in billions USD
  // Historical performance
  tenYearReturnPct: number  // % total return over 10 years
  fiveYearReturnPct: number
  oneYearReturnPct: number
  // Future outlook (analyst consensus / fundamental estimates)
  revenueGrowthCAGR: number    // projected 5yr revenue CAGR %
  epsGrowthCAGR: number        // projected 5yr EPS CAGR %
  analystUpsidePct: number     // % upside to 12-month consensus price target
  moatScore: number            // 1-10 competitive moat score
  sectorTailwindScore: number  // 1-10 macro/sector tailwind score
  pegRatio: number             // price/earnings-to-growth
  forwardPE: number
  dividendYield: number        // %
}

export interface StockWithScores extends Stock {
  historicalScore: number  // composite 0-100
  futureScore: number      // composite 0-100
}

export type SortKey = 'historicalScore' | 'futureScore' | 'tenYearReturnPct' | 'analystUpsidePct' | 'marketCapB'
export type SortDir = 'asc' | 'desc'
