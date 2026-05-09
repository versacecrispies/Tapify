import { useState, useCallback, useMemo } from 'react'
import type { Industry, SortKey, SortDir, StockWithScores } from '../types'
import { RAW_STOCKS } from '../data/stocks'
import { scoreStocks } from '../utils/calculations'

export interface StocksState {
  stocks: StockWithScores[]
  selectedIndustry: Industry | 'All'
  sortKey: SortKey
  sortDir: SortDir
  refreshKey: number
  setIndustry: (industry: Industry | 'All') => void
  setSorting: (key: SortKey) => void
  forceRefresh: () => void
  industries: Array<Industry | 'All'>
}

const ALL_INDUSTRIES: Array<Industry | 'All'> = [
  'All',
  'Technology',
  'Healthcare',
  'Financials',
  'Consumer Discretionary',
  'Communication Services',
  'Energy',
  'Industrials',
]

export function useStocks(): StocksState {
  const [selectedIndustry, setSelectedIndustry] = useState<Industry | 'All'>('All')
  const [sortKey, setSortKeyState]              = useState<SortKey>('historicalScore')
  const [sortDir, setSortDir]                   = useState<SortDir>('desc')
  const [refreshKey, setRefreshKey]             = useState(0)

  const setIndustry = useCallback((industry: Industry | 'All') => {
    setSelectedIndustry(industry)
  }, [])

  const setSorting = useCallback((key: SortKey) => {
    setSortKeyState(prev => {
      if (prev === key) setSortDir(d => (d === 'desc' ? 'asc' : 'desc'))
      else setSortDir('desc')
      return key
    })
  }, [])

  const forceRefresh = useCallback(() => {
    setRefreshKey(k => k + 1)
  }, [])

  const stocks = useMemo(() => {
    // scoreStocks re-runs on every refresh (refreshKey triggers memo invalidation)
    void refreshKey
    const scored = scoreStocks(RAW_STOCKS)

    const filtered =
      selectedIndustry === 'All'
        ? scored
        : scored.filter(s => s.industry === selectedIndustry)

    return [...filtered].sort((a, b) => {
      const mul = sortDir === 'desc' ? -1 : 1
      return (a[sortKey] - b[sortKey]) * mul
    })
  }, [selectedIndustry, sortKey, sortDir, refreshKey])

  return {
    stocks,
    selectedIndustry,
    sortKey,
    sortDir,
    refreshKey,
    setIndustry,
    setSorting,
    forceRefresh,
    industries: ALL_INDUSTRIES,
  }
}
