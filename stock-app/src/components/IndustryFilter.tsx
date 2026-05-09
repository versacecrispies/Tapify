import React from 'react'
import type { Industry } from '../types'

interface Props {
  industries: Array<Industry | 'All'>
  selected: Industry | 'All'
  onChange: (v: Industry | 'All') => void
}

const INDUSTRY_ICONS: Record<string, string> = {
  All: '🌐',
  Technology: '💻',
  Healthcare: '🏥',
  Financials: '🏦',
  'Consumer Discretionary': '🛍',
  'Communication Services': '📡',
  Energy: '⚡',
  Industrials: '🏗',
}

export function IndustryFilter({ industries, selected, onChange }: Props) {
  return (
    <div
      style={{
        display: 'flex', gap: '8px', flexWrap: 'wrap',
        padding: '16px 0',
      }}
    >
      {industries.map(industry => {
        const active = selected === industry
        return (
          <button
            key={industry}
            onClick={() => onChange(industry)}
            style={{
              padding: '7px 16px',
              borderRadius: '20px',
              border: active ? '1px solid #38bdf8' : '1px solid #334155',
              background: active ? 'rgba(56, 189, 248, 0.12)' : '#1e293b',
              color: active ? '#38bdf8' : '#94a3b8',
              cursor: 'pointer',
              fontSize: '13px',
              fontWeight: active ? 600 : 400,
              transition: 'all 0.15s',
              whiteSpace: 'nowrap',
            }}
          >
            {INDUSTRY_ICONS[industry] ?? ''} {industry}
          </button>
        )
      })}
    </div>
  )
}
