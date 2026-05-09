import React, { useState } from 'react'
import { Header } from './components/Header'
import { IndustryFilter } from './components/IndustryFilter'
import { StockTable } from './components/StockTable'
import { useStocks } from './hooks/useStocks'
import { useAutoRefresh } from './hooks/useAutoRefresh'

type Tab = 'historical' | 'future'

const TAB_LABELS: Record<Tab, string> = {
  historical: '📊 Past 10-Year Performance',
  future: '🔭 5-Year Outlook',
}

export function App() {
  const [activeTab, setActiveTab] = useState<Tab>('historical')
  const { stocks, selectedIndustry, sortKey, sortDir, setIndustry, setSorting, forceRefresh, industries } =
    useStocks()
  const refresh = useAutoRefresh(forceRefresh, 300)

  return (
    <div style={{ minHeight: '100vh', background: '#0f172a' }}>
      <Header refresh={refresh} />

      <main style={{ maxWidth: '1400px', margin: '0 auto', padding: '0 24px 48px' }}>
        {/* Tabs */}
        <div style={{ display: 'flex', gap: '4px', padding: '20px 0 0' }}>
          {(Object.keys(TAB_LABELS) as Tab[]).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              style={{
                padding: '9px 20px',
                borderRadius: '8px 8px 0 0',
                border: 'none',
                cursor: 'pointer',
                fontSize: '14px',
                fontWeight: activeTab === tab ? 700 : 400,
                background: activeTab === tab ? '#1e293b' : 'transparent',
                color: activeTab === tab ? '#f1f5f9' : '#64748b',
                borderBottom: activeTab === tab ? '2px solid #38bdf8' : '2px solid transparent',
                transition: 'all 0.15s',
              }}
            >
              {TAB_LABELS[tab]}
            </button>
          ))}
        </div>

        {/* Card */}
        <div
          style={{
            background: '#1e293b',
            borderRadius: '0 12px 12px 12px',
            border: '1px solid #334155',
            overflow: 'hidden',
          }}
        >
          <div style={{ padding: '16px 20px 0' }}>
            <IndustryFilter
              industries={industries}
              selected={selectedIndustry}
              onChange={setIndustry}
            />
          </div>

          {/* Summary bar */}
          <div style={{
            padding: '10px 20px',
            fontSize: '13px', color: '#64748b',
            borderTop: '1px solid #334155',
            borderBottom: '1px solid #334155',
            background: '#0f172a',
          }}>
            Showing <strong style={{ color: '#94a3b8' }}>{stocks.length}</strong> large-cap stocks
            {selectedIndustry !== 'All' && (
              <> in <strong style={{ color: '#38bdf8' }}>{selectedIndustry}</strong></>
            )}
          </div>

          <StockTable
            stocks={stocks}
            sortKey={sortKey}
            sortDir={sortDir}
            onSort={setSorting}
            mode={activeTab}
          />
        </div>

        {/* Legend */}
        <div style={{ marginTop: '20px', display: 'flex', gap: '20px', flexWrap: 'wrap', fontSize: '12px', color: '#475569' }}>
          <span>Score colours: <span style={{ color: '#4ade80' }}>■</span> High (75+) &nbsp;
            <span style={{ color: '#facc15' }}>■</span> Medium (55-75) &nbsp;
            <span style={{ color: '#fb923c' }}>■</span> Low (35-55) &nbsp;
            <span style={{ color: '#f87171' }}>■</span> Poor (&lt;35)
          </span>
          <span>Data reflects analyst consensus estimates as of early 2025. Not financial advice.</span>
        </div>
      </main>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50% { opacity: 0.5; transform: scale(1.3); }
        }
        button:hover { opacity: 0.85; }
        tr:hover td { background: rgba(56,189,248,0.04) !important; }
      `}</style>
    </div>
  )
}
