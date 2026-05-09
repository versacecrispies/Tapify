import { describe, it, expect } from 'vitest'
import {
  calcHistoricalScore,
  calcFutureScore,
  scoreStocks,
  formatPct,
  formatMarketCap,
  getReturnColour,
  getScoreColour,
} from '../utils/calculations'
import type { Stock } from '../types'

const BASE: Stock = {
  ticker: 'TEST', name: 'Test Co', industry: 'Technology',
  marketCapB: 500,
  tenYearReturnPct: 500, fiveYearReturnPct: 200, oneYearReturnPct: 30,
  revenueGrowthCAGR: 15, epsGrowthCAGR: 18, analystUpsidePct: 20,
  moatScore: 8, sectorTailwindScore: 8, pegRatio: 2.0, forwardPE: 28, dividendYield: 0.5,
}

// ── calcHistoricalScore ──────────────────────────────────────────────────────
describe('calcHistoricalScore', () => {
  it('returns a number between 0 and 100', () => {
    const s = calcHistoricalScore(BASE)
    expect(s).toBeGreaterThanOrEqual(0)
    expect(s).toBeLessThanOrEqual(100)
  })

  it('higher 10yr return → higher score', () => {
    const low  = calcHistoricalScore({ ...BASE, tenYearReturnPct: 50 })
    const high = calcHistoricalScore({ ...BASE, tenYearReturnPct: 5000 })
    expect(high).toBeGreaterThan(low)
  })

  it('exceptional performer (NVDA-like) scores near 100', () => {
    const nvda = calcHistoricalScore({ ...BASE, tenYearReturnPct: 29800, fiveYearReturnPct: 2640, oneYearReturnPct: 194 })
    expect(nvda).toBeGreaterThan(90)
  })

  it('zero returns score near 0', () => {
    const s = calcHistoricalScore({ ...BASE, tenYearReturnPct: 0, fiveYearReturnPct: 0, oneYearReturnPct: 0 })
    expect(s).toBeLessThan(5)
  })

  it('negative 1yr return still computes without error', () => {
    const s = calcHistoricalScore({ ...BASE, oneYearReturnPct: -30 })
    expect(s).toBeGreaterThanOrEqual(0)
    expect(s).toBeLessThanOrEqual(100)
  })
})

// ── calcFutureScore ──────────────────────────────────────────────────────────
describe('calcFutureScore', () => {
  it('returns a number between 0 and 100', () => {
    const s = calcFutureScore(BASE)
    expect(s).toBeGreaterThanOrEqual(0)
    expect(s).toBeLessThanOrEqual(100)
  })

  it('higher growth metrics → higher score', () => {
    const low  = calcFutureScore({ ...BASE, revenueGrowthCAGR: 2, epsGrowthCAGR: 3, analystUpsidePct: 2 })
    const high = calcFutureScore({ ...BASE, revenueGrowthCAGR: 28, epsGrowthCAGR: 32, analystUpsidePct: 30 })
    expect(high).toBeGreaterThan(low)
  })

  it('high PEG ratio reduces score', () => {
    const normal = calcFutureScore({ ...BASE, pegRatio: 1.5 })
    const pricey = calcFutureScore({ ...BASE, pegRatio: 5.0 })
    expect(normal).toBeGreaterThan(pricey)
  })

  it('strong moat increases score', () => {
    const weakMoat   = calcFutureScore({ ...BASE, moatScore: 3 })
    const strongMoat = calcFutureScore({ ...BASE, moatScore: 9.5 })
    expect(strongMoat).toBeGreaterThan(weakMoat)
  })
})

// ── scoreStocks ──────────────────────────────────────────────────────────────
describe('scoreStocks', () => {
  it('returns same number of stocks as input', () => {
    const result = scoreStocks([BASE, { ...BASE, ticker: 'B' }])
    expect(result).toHaveLength(2)
  })

  it('adds historicalScore and futureScore fields', () => {
    const [s] = scoreStocks([BASE])
    expect(s).toHaveProperty('historicalScore')
    expect(s).toHaveProperty('futureScore')
  })

  it('scores are rounded to 1 decimal place', () => {
    const [s] = scoreStocks([BASE])
    const decimals = (v: number) => ((v * 10) % 1 < 0.001 ? true : false)
    expect(decimals(s.historicalScore)).toBe(true)
    expect(decimals(s.futureScore)).toBe(true)
  })

  it('handles empty array', () => {
    expect(scoreStocks([])).toEqual([])
  })
})

// ── formatPct ────────────────────────────────────────────────────────────────
describe('formatPct', () => {
  it('prefixes positive numbers with +', () => {
    expect(formatPct(42)).toBe('+42%')
  })

  it('does not double-prefix negative numbers', () => {
    expect(formatPct(-15)).toBe('-15%')
  })

  it('respects decimal places', () => {
    expect(formatPct(12.567, 2)).toBe('+12.57%')
  })

  it('handles zero', () => {
    expect(formatPct(0)).toBe('+0%')
  })
})

// ── formatMarketCap ───────────────────────────────────────────────────────────
describe('formatMarketCap', () => {
  it('formats trillions correctly', () => {
    expect(formatMarketCap(3200)).toBe('$3.2T')
  })

  it('formats billions correctly', () => {
    expect(formatMarketCap(450)).toBe('$450B')
  })

  it('formats exactly 1T', () => {
    expect(formatMarketCap(1000)).toBe('$1.0T')
  })
})

// ── getReturnColour ────────────────────────────────────────────────────────────
describe('getReturnColour', () => {
  it('returns cyan for exceptional returns (≥500%)', () => {
    expect(getReturnColour(500)).toBe('#22d3ee')
    expect(getReturnColour(10000)).toBe('#22d3ee')
  })

  it('returns green for strong returns (100-499%)', () => {
    expect(getReturnColour(100)).toBe('#4ade80')
    expect(getReturnColour(250)).toBe('#4ade80')
  })

  it('returns light green for positive returns (0-99%)', () => {
    expect(getReturnColour(50)).toBe('#86efac')
  })

  it('returns red for negative returns', () => {
    expect(getReturnColour(-20)).toBe('#f87171')
  })
})

// ── getScoreColour ─────────────────────────────────────────────────────────────
describe('getScoreColour', () => {
  it('returns green for high scores (≥75)', () => {
    expect(getScoreColour(80)).toBe('#4ade80')
  })

  it('returns yellow for medium scores (55-74)', () => {
    expect(getScoreColour(65)).toBe('#facc15')
  })

  it('returns orange for low scores (35-54)', () => {
    expect(getScoreColour(45)).toBe('#fb923c')
  })

  it('returns red for poor scores (<35)', () => {
    expect(getScoreColour(20)).toBe('#f87171')
  })
})
