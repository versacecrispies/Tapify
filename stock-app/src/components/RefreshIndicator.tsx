import React from 'react'
import type { AutoRefreshState } from '../hooks/useAutoRefresh'

const s: Record<string, React.CSSProperties> = {
  wrap: {
    display: 'flex', alignItems: 'center', gap: '12px',
    fontSize: '13px', color: '#94a3b8',
  },
  btn: {
    padding: '6px 14px', borderRadius: '6px', border: 'none', cursor: 'pointer',
    background: '#1e293b', color: '#e2e8f0', fontSize: '13px',
    transition: 'background 0.15s',
  },
  pulse: {
    width: 8, height: 8, borderRadius: '50%', background: '#22d3ee',
    animation: 'pulse 1.2s infinite',
  },
  idle: {
    width: 8, height: 8, borderRadius: '50%', background: '#475569',
  },
  select: {
    background: '#1e293b', color: '#e2e8f0', border: '1px solid #334155',
    borderRadius: '6px', padding: '4px 8px', fontSize: '13px',
  },
}

interface Props {
  state: AutoRefreshState
}

export function RefreshIndicator({ state }: Props) {
  const { lastRefreshed, countdown, intervalSec, isRefreshing, refresh, setInterval } = state

  const mm = lastRefreshed.getHours().toString().padStart(2, '0')
  const ss = lastRefreshed.getMinutes().toString().padStart(2, '0')
  const timeStr = `${mm}:${ss}`

  return (
    <div style={s.wrap}>
      <div style={isRefreshing ? s.pulse : s.idle} title={isRefreshing ? 'Refreshing…' : 'Live'} />
      <span>Last updated {timeStr}</span>
      <span>· Next in {countdown}s</span>
      <select
        style={s.select}
        value={intervalSec}
        onChange={e => setInterval(Number(e.target.value))}
        aria-label="Refresh interval"
      >
        <option value={60}>Every 1m</option>
        <option value={300}>Every 5m</option>
        <option value={600}>Every 10m</option>
        <option value={1800}>Every 30m</option>
      </select>
      <button
        style={s.btn}
        onClick={refresh}
        disabled={isRefreshing}
        aria-label="Refresh now"
      >
        {isRefreshing ? 'Refreshing…' : '⟳ Refresh'}
      </button>
    </div>
  )
}
