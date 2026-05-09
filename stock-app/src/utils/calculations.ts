import type { Stock, StockWithScores } from '../types'

// Normalise a raw value to 0-100 given known domain min/max.
function normalise(value: number, min: number, max: number): number {
  if (max === min) return 50
  return Math.min(100, Math.max(0, ((value - min) / (max - min)) * 100))
}

// Clamp a score to [0, 100].
function clamp(v: number): number {
  return Math.min(100, Math.max(0, v))
}

/**
 * Composite historical score (0-100) weighting:
 *   40% 10-year return
 *   35% 5-year return
 *   25% 1-year return
 *
 * Values are log-normalised so extreme outliers (NVDA) don't crush everyone.
 */
export function calcHistoricalScore(stock: Stock): number {
  const log10yr = Math.log1p(stock.tenYearReturnPct)
  const log5yr  = Math.log1p(stock.fiveYearReturnPct)
  const log1yr  = Math.log1p(Math.max(0, stock.oneYearReturnPct))

  // Empirical domain maxima (log scale)
  const max10 = Math.log1p(30000)
  const max5  = Math.log1p(3000)
  const max1  = Math.log1p(200)

  const s10 = normalise(log10yr, 0, max10) * 0.40
  const s5  = normalise(log5yr,  0, max5)  * 0.35
  const s1  = normalise(log1yr,  0, max1)  * 0.25

  return clamp(s10 + s5 + s1)
}

/**
 * Composite future-outlook score (0-100) weighting:
 *   25% revenue growth CAGR (5yr)
 *   25% EPS growth CAGR (5yr)
 *   20% analyst upside %
 *   15% competitive moat (1-10 → 0-100)
 *   15% sector tailwind (1-10 → 0-100)
 *
 * PEG ratio applies a small penalty: high PEG (expensive relative to growth) trims score.
 */
export function calcFutureScore(stock: Stock): number {
  const revScore      = normalise(stock.revenueGrowthCAGR, 0, 30) * 0.25
  const epsScore      = normalise(stock.epsGrowthCAGR, 0, 35)     * 0.25
  const upsideScore   = normalise(stock.analystUpsidePct, 0, 35)  * 0.20
  const moatScore     = (stock.moatScore / 10) * 100              * 0.15
  const tailwindScore = (stock.sectorTailwindScore / 10) * 100    * 0.15

  const raw = revScore + epsScore + upsideScore + moatScore + tailwindScore

  // PEG penalty: PEG > 3 reduces score by up to 5 pts
  const pegPenalty = stock.pegRatio > 3 ? Math.min(5, (stock.pegRatio - 3) * 2) : 0

  return clamp(raw - pegPenalty)
}

export function scoreStocks(stocks: Stock[]): StockWithScores[] {
  return stocks.map(s => ({
    ...s,
    historicalScore: Math.round(calcHistoricalScore(s) * 10) / 10,
    futureScore:     Math.round(calcFutureScore(s) * 10) / 10,
  }))
}

export function formatPct(value: number, decimals = 0): string {
  const sign = value >= 0 ? '+' : ''
  return `${sign}${value.toFixed(decimals)}%`
}

export function formatMarketCap(billions: number): string {
  if (billions >= 1000) return `$${(billions / 1000).toFixed(1)}T`
  return `$${billions.toFixed(0)}B`
}

export function getReturnColour(pct: number): string {
  if (pct >= 500)  return '#22d3ee'  // cyan — exceptional
  if (pct >= 100)  return '#4ade80'  // green — strong
  if (pct >= 0)    return '#86efac'  // light green — positive
  return '#f87171'                   // red — negative
}

export function getScoreColour(score: number): string {
  if (score >= 75) return '#4ade80'
  if (score >= 55) return '#facc15'
  if (score >= 35) return '#fb923c'
  return '#f87171'
}
