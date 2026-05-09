import React from 'react'
import type { StockWithScores, SortKey, SortDir } from '../types'
import { formatPct, formatMarketCap, getReturnColour, getScoreColour } from '../utils/calculations'

interface Props {
  stocks: StockWithScores[]
  sortKey: SortKey
  sortDir: SortDir
  onSort: (key: SortKey) => void
  mode: 'historical' | 'future'
}

const th: React.CSSProperties = {
  padding: '10px 14px', textAlign: 'left', fontSize: '12px',
  color: '#64748b', fontWeight: 600, textTransform: 'uppercase',
  letterSpacing: '0.05em', userSelect: 'none', cursor: 'pointer',
  whiteSpace: 'nowrap',
}

const td: React.CSSProperties = {
  padding: '10px 14px', fontSize: '14px', color: '#e2e8f0',
  borderTop: '1px solid #1e293b',
}

function SortArrow({ active, dir }: { active: boolean; dir: SortDir }) {
  if (!active) return <span style={{ opacity: 0.3, marginLeft: 4 }}>↕</span>
  return <span style={{ marginLeft: 4 }}>{dir === 'desc' ? '↓' : '↑'}</span>
}

function ScoreBadge({ score }: { score: number }) {
  return (
    <span
      style={{
        display: 'inline-block', minWidth: 42, textAlign: 'center',
        padding: '2px 8px', borderRadius: '10px', fontSize: '13px',
        fontWeight: 700, color: '#0f172a',
        background: getScoreColour(score),
      }}
    >
      {score.toFixed(1)}
    </span>
  )
}

function Col({ label, sortK, sortKey, sortDir, onSort }: {
  label: string; sortK: SortKey; sortKey: SortKey; sortDir: SortDir; onSort: (k: SortKey) => void
}) {
  return (
    <th style={th} onClick={() => onSort(sortK)}>
      {label}<SortArrow active={sortKey === sortK} dir={sortDir} />
    </th>
  )
}

const INDUSTRY_COLOR: Record<string, string> = {
  Technology: '#38bdf8',
  Healthcare: '#4ade80',
  Financials: '#facc15',
  'Consumer Discretionary': '#fb923c',
  'Communication Services': '#a78bfa',
  Energy: '#f97316',
  Industrials: '#94a3b8',
}

export function StockTable({ stocks, sortKey, sortDir, onSort, mode }: Props) {
  if (stocks.length === 0) {
    return (
      <div style={{ padding: '48px', textAlign: 'center', color: '#475569' }}>
        No stocks match the selected filter.
      </div>
    )
  }

  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ background: '#0f172a' }}>
            <th style={{ ...th, width: 44 }}>#</th>
            <Col label="Ticker"   sortK="marketCapB"      sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
            <th style={th}>Industry</th>
            <Col label="Mkt Cap"  sortK="marketCapB"      sortKey={sortKey} sortDir={sortDir} onSort={onSort} />

            {mode === 'historical' ? (
              <>
                <Col label="10Y Return" sortK="tenYearReturnPct"   sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="5Y Return"  sortK="historicalScore"    sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="1Y Return"  sortK="historicalScore"    sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="Hist. Score" sortK="historicalScore"   sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
              </>
            ) : (
              <>
                <Col label="Rev CAGR"     sortK="futureScore"       sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="EPS CAGR"     sortK="futureScore"       sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="Analyst ↑"    sortK="analystUpsidePct"  sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="Fwd P/E"      sortK="futureScore"       sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="PEG"          sortK="futureScore"       sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
                <Col label="Future Score" sortK="futureScore"       sortKey={sortKey} sortDir={sortDir} onSort={onSort} />
              </>
            )}
          </tr>
        </thead>
        <tbody>
          {stocks.map((stock, i) => (
            <tr
              key={stock.ticker}
              style={{ background: i % 2 === 0 ? '#0f172a' : '#0c1526', transition: 'background 0.1s' }}
            >
              <td style={{ ...td, color: '#475569', textAlign: 'center' }}>{i + 1}</td>
              <td style={td}>
                <div style={{ fontWeight: 700, color: '#f1f5f9' }}>{stock.ticker}</div>
                <div style={{ fontSize: '12px', color: '#64748b', marginTop: 2, maxWidth: 160 }}>
                  {stock.name}
                </div>
              </td>
              <td style={td}>
                <span style={{
                  fontSize: '11px', padding: '2px 8px', borderRadius: '10px',
                  background: `${INDUSTRY_COLOR[stock.industry] ?? '#475569'}22`,
                  color: INDUSTRY_COLOR[stock.industry] ?? '#94a3b8',
                  fontWeight: 600,
                }}>
                  {stock.industry}
                </span>
              </td>
              <td style={td}>{formatMarketCap(stock.marketCapB)}</td>

              {mode === 'historical' ? (
                <>
                  <td style={{ ...td, color: getReturnColour(stock.tenYearReturnPct), fontWeight: 700 }}>
                    {formatPct(stock.tenYearReturnPct)}
                  </td>
                  <td style={{ ...td, color: getReturnColour(stock.fiveYearReturnPct) }}>
                    {formatPct(stock.fiveYearReturnPct)}
                  </td>
                  <td style={{ ...td, color: getReturnColour(stock.oneYearReturnPct) }}>
                    {formatPct(stock.oneYearReturnPct)}
                  </td>
                  <td style={td}><ScoreBadge score={stock.historicalScore} /></td>
                </>
              ) : (
                <>
                  <td style={{ ...td, color: '#4ade80' }}>{formatPct(stock.revenueGrowthCAGR)}/yr</td>
                  <td style={{ ...td, color: '#22d3ee' }}>{formatPct(stock.epsGrowthCAGR)}/yr</td>
                  <td style={{ ...td, color: getReturnColour(stock.analystUpsidePct), fontWeight: 600 }}>
                    {formatPct(stock.analystUpsidePct)}
                  </td>
                  <td style={td}>{stock.forwardPE.toFixed(0)}x</td>
                  <td style={{
                    ...td,
                    color: stock.pegRatio < 2 ? '#4ade80' : stock.pegRatio < 3 ? '#facc15' : '#f87171',
                  }}>
                    {stock.pegRatio.toFixed(1)}
                  </td>
                  <td style={td}><ScoreBadge score={stock.futureScore} /></td>
                </>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
