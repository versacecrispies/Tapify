import { describe, it, expect } from 'vitest'
import { RAW_STOCKS } from '../data/stocks'
import type { Industry } from '../types'

const VALID_INDUSTRIES: Industry[] = [
  'Technology', 'Healthcare', 'Financials',
  'Consumer Discretionary', 'Communication Services',
  'Energy', 'Industrials',
]

describe('RAW_STOCKS data integrity', () => {
  it('contains at least 20 stocks', () => {
    expect(RAW_STOCKS.length).toBeGreaterThanOrEqual(20)
  })

  it('all tickers are non-empty strings', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.ticker).toBeTruthy()
      expect(typeof s.ticker).toBe('string')
    })
  })

  it('all tickers are unique', () => {
    const tickers = RAW_STOCKS.map(s => s.ticker)
    const unique  = new Set(tickers)
    expect(unique.size).toBe(tickers.length)
  })

  it('all stocks have a valid industry', () => {
    RAW_STOCKS.forEach(s => {
      expect(VALID_INDUSTRIES).toContain(s.industry)
    })
  })

  it('every industry has at least one stock', () => {
    const industriesPresent = new Set(RAW_STOCKS.map(s => s.industry))
    VALID_INDUSTRIES.forEach(ind => {
      expect(industriesPresent.has(ind)).toBe(true)
    })
  })

  it('all stocks are large-cap (market cap ≥ $100B)', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.marketCapB).toBeGreaterThanOrEqual(100)
    })
  })

  it('10-year returns are finite numbers', () => {
    RAW_STOCKS.forEach(s => {
      expect(typeof s.tenYearReturnPct).toBe('number')
      expect(Number.isFinite(s.tenYearReturnPct)).toBe(true)
    })
  })

  it('moat scores are between 1 and 10', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.moatScore).toBeGreaterThanOrEqual(1)
      expect(s.moatScore).toBeLessThanOrEqual(10)
    })
  })

  it('sector tailwind scores are between 1 and 10', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.sectorTailwindScore).toBeGreaterThanOrEqual(1)
      expect(s.sectorTailwindScore).toBeLessThanOrEqual(10)
    })
  })

  it('forward P/E is positive for all stocks', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.forwardPE).toBeGreaterThan(0)
    })
  })

  it('PEG ratio is positive for all stocks', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.pegRatio).toBeGreaterThan(0)
    })
  })

  it('dividend yield is non-negative for all stocks', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.dividendYield).toBeGreaterThanOrEqual(0)
    })
  })

  it('Technology sector has at least 4 stocks', () => {
    const tech = RAW_STOCKS.filter(s => s.industry === 'Technology')
    expect(tech.length).toBeGreaterThanOrEqual(4)
  })

  it('NVDA has the highest 10-year return', () => {
    const maxReturn = Math.max(...RAW_STOCKS.map(s => s.tenYearReturnPct))
    const nvda = RAW_STOCKS.find(s => s.ticker === 'NVDA')
    expect(nvda?.tenYearReturnPct).toBe(maxReturn)
  })

  it('revenue growth CAGR is reasonable (0-50% range)', () => {
    RAW_STOCKS.forEach(s => {
      expect(s.revenueGrowthCAGR).toBeGreaterThanOrEqual(0)
      expect(s.revenueGrowthCAGR).toBeLessThanOrEqual(50)
    })
  })
})
