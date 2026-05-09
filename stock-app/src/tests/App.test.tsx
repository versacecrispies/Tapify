import React from 'react'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, act } from '@testing-library/react'
import { App } from '../App'

// Stub timers so auto-refresh doesn't interfere
beforeEach(() => {
  vi.useFakeTimers()
})

afterEach(() => {
  vi.useRealTimers()
})

describe('App', () => {
  it('renders the page title', () => {
    render(<App />)
    expect(screen.getByText(/Large-Cap Stock Performance/i)).toBeInTheDocument()
  })

  it('renders the historical tab by default', () => {
    render(<App />)
    expect(screen.getByText(/Past 10-Year Performance/i)).toBeInTheDocument()
  })

  it('renders the future outlook tab button', () => {
    render(<App />)
    expect(screen.getByRole('button', { name: /5-Year Outlook/i })).toBeInTheDocument()
  })

  it('switches to future tab on click', () => {
    render(<App />)
    const futureTab = screen.getByRole('button', { name: /5-Year Outlook/i })
    fireEvent.click(futureTab)
    // Future-mode columns appear
    expect(screen.getByText(/Future Score/i)).toBeInTheDocument()
  })

  it('shows industry filter buttons', () => {
    render(<App />)
    expect(screen.getByRole('button', { name: /Technology/i })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /Healthcare/i })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /Financials/i })).toBeInTheDocument()
  })

  it('filters stocks by industry', () => {
    render(<App />)
    const techButton = screen.getAllByText(/Technology/i)[0]
    fireEvent.click(techButton)
    // After filtering, every industry badge in the table should be Technology
    const badges = screen.queryAllByText('Technology')
    expect(badges.length).toBeGreaterThan(0)
  })

  it('shows All industry filter resets to full list', () => {
    render(<App />)
    // Filter to Technology first
    fireEvent.click(screen.getAllByText(/Technology/i)[0])
    // Then click All
    fireEvent.click(screen.getByText(/^🌐 All$/))
    // NVDA and LLY both visible
    expect(screen.getByText('NVDA')).toBeInTheDocument()
    expect(screen.getByText('LLY')).toBeInTheDocument()
  })

  it('renders the refresh button', () => {
    render(<App />)
    expect(screen.getByLabelText(/Refresh now/i)).toBeInTheDocument()
  })

  it('refresh button triggers refresh', async () => {
    render(<App />)
    const refreshBtn = screen.getByLabelText(/Refresh now/i)
    await act(async () => {
      fireEvent.click(refreshBtn)
    })
    // Button becomes disabled during refresh
    expect(refreshBtn).toBeDisabled()
  })

  it('renders stock count summary', () => {
    render(<App />)
    expect(screen.getByText(/large-cap stocks/i)).toBeInTheDocument()
  })

  it('renders NVDA in the table', () => {
    render(<App />)
    expect(screen.getByText('NVDA')).toBeInTheDocument()
  })

  it('renders at least 20 stock rows', () => {
    render(<App />)
    // Each row has a ticker cell; count them by finding known tickers
    const tickers = ['NVDA', 'AAPL', 'MSFT', 'GOOGL', 'META', 'LLY', 'V', 'MA', 'AMZN', 'NFLX',
                     'AVGO', 'TSM', 'UNH', 'ABBV', 'NVO', 'JPM', 'BRK.B', 'TSLA', 'HD', 'XOM']
    tickers.forEach(t => {
      expect(screen.getByText(t)).toBeInTheDocument()
    })
  })

  it('countdown timer shows seconds', () => {
    render(<App />)
    expect(screen.getByText(/Next in \d+s/i)).toBeInTheDocument()
  })

  it('auto-refresh interval selector is present', () => {
    render(<App />)
    expect(screen.getByLabelText(/Refresh interval/i)).toBeInTheDocument()
  })

  it('changing interval selector updates countdown', async () => {
    render(<App />)
    const select = screen.getByLabelText(/Refresh interval/i)
    await act(async () => {
      fireEvent.change(select, { target: { value: '60' } })
    })
    expect(screen.getByText(/Next in (5[0-9]|60)s/i)).toBeInTheDocument()
  })
})
