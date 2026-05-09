import React from 'react'
import type { AutoRefreshState } from '../hooks/useAutoRefresh'
import { RefreshIndicator } from './RefreshIndicator'

interface Props {
  refresh: AutoRefreshState
}

export function Header({ refresh }: Props) {
  return (
    <header
      style={{
        padding: '24px 32px 16px',
        borderBottom: '1px solid #1e293b',
        background: 'rgba(15, 23, 42, 0.95)',
        position: 'sticky',
        top: 0,
        zIndex: 10,
        backdropFilter: 'blur(8px)',
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#f1f5f9', letterSpacing: '-0.3px' }}>
            📈 Large-Cap Stock Performance
          </h1>
          <p style={{ fontSize: '13px', color: '#64748b', marginTop: '4px' }}>
            Top large-cap performers — past 10 years · 5-year outlook · by industry
          </p>
        </div>
        <RefreshIndicator state={refresh} />
      </div>
    </header>
  )
}
