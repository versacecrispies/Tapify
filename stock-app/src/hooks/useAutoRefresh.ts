import { useState, useEffect, useCallback } from 'react'

export interface AutoRefreshState {
  lastRefreshed: Date
  countdown: number        // seconds until next refresh
  intervalSec: number
  isRefreshing: boolean
  refresh: () => void
  setInterval: (sec: number) => void
}

export function useAutoRefresh(
  onRefresh: () => void,
  intervalSec = 300,
): AutoRefreshState {
  const [lastRefreshed, setLastRefreshed] = useState<Date>(new Date())
  const [countdown, setCountdown]         = useState<number>(intervalSec)
  const [interval, setIntervalSec]        = useState<number>(intervalSec)
  const [isRefreshing, setIsRefreshing]   = useState(false)

  const refresh = useCallback(() => {
    setIsRefreshing(true)
    // Simulate a brief loading flash so the UI shows activity
    setTimeout(() => {
      onRefresh()
      setLastRefreshed(new Date())
      setCountdown(interval)
      setIsRefreshing(false)
    }, 400)
  }, [onRefresh, interval])

  // Countdown ticker
  useEffect(() => {
    const tick = setInterval(() => {
      setCountdown(prev => {
        if (prev <= 1) {
          refresh()
          return interval
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(tick)
  }, [refresh, interval])

  // Reset countdown when interval changes
  useEffect(() => {
    setCountdown(interval)
  }, [interval])

  return { lastRefreshed, countdown, intervalSec: interval, isRefreshing, refresh, setInterval: setIntervalSec }
}
