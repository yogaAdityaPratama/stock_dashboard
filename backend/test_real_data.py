#!/usr/bin/env python3
"""
Test script untuk memverifikasi real data fetching dari Yahoo Finance
Menjalankan test untuk beberapa saham IDX populer
"""

import yfinance as yf
import json
from datetime import datetime

def test_single_stock(code):
    """Test fetch data untuk single stock"""
    print(f"\n{'='*60}")
    print(f"Testing: {code}")
    print(f"{'='*60}")
    
    try:
        yf_code = f"{code}.JK"
        print(f"📡 Fetching from Yahoo Finance: {yf_code}")
        
        stock = yf.Ticker(yf_code)
        info = stock.info
        hist = stock.history(period="5y")
        
        if hist.empty or info.get('currentPrice') is None:
            print(f"⚠️ No sufficient data for {yf_code}")
            return False
        
        # Extract key metrics
        print(f"\n✅ Data Found!")
        print(f"   Company: {info.get('longName', 'N/A')}")
        print(f"   Current Price: Rp{info.get('currentPrice', 0):,.0f}")
        print(f"   Market Cap: ${info.get('marketCap', 0)/1e9:.2f}B")
        print(f"   Sector: {info.get('sector', 'N/A')}")
        print(f"   PER: {info.get('trailingPE', 'N/A'):.2f}x" if info.get('trailingPE') else "   PER: N/A")
        print(f"   PBV: {info.get('priceToBook', 'N/A'):.2f}x" if info.get('priceToBook') else "   PBV: N/A")
        print(f"   DER: {info.get('debtToEquity', 'N/A'):.2f}x" if info.get('debtToEquity') else "   DER: N/A")
        print(f"   ROE: {(info.get('returnOnEquity', 0) * 100):.2f}%" if info.get('returnOnEquity') else "   ROE: N/A")
        print(f"   Dividend Yield: {(info.get('dividendYield', 0) * 100):.2f}%" if info.get('dividendYield') else "   Dividend Yield: N/A")
        print(f"   EPS: {info.get('trailingEps', 'N/A')}")
        print(f"   ESG Score: {info.get('esgScore', 'N/A')}")
        print(f"   Data Points: {len(hist)} (5-year history)")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("\n" + "="*60)
    print("🚀 Real Data Integration Test Suite")
    print("="*60)
    print(f"Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("Testing Yahoo Finance integration for Indonesian stocks")
    
    # Popular Indonesian stocks to test
    test_stocks = ['BBCA', 'ADRO', 'GOTO', 'UNTR', 'ASII', 'BMRI', 'TLKM', 'INDF']
    
    results = {}
    for stock_code in test_stocks:
        success = test_single_stock(stock_code)
        results[stock_code] = "✅ PASS" if success else "❌ FAIL"
    
    # Summary
    print(f"\n{'='*60}")
    print("📊 Test Summary")
    print(f"{'='*60}")
    passed = sum(1 for v in results.values() if "✅" in v)
    total = len(results)
    
    for stock, result in results.items():
        print(f"{stock:10} : {result}")
    
    print(f"\nTotal: {passed}/{total} stocks passed")
    print(f"Success Rate: {(passed/total*100):.1f}%")
    
    if passed == total:
        print("\n🎉 All tests passed! Real data integration is working!")
    elif passed > 0:
        print("\n⚠️ Some tests passed. Fallback mechanism will handle failures.")
    else:
        print("\n❌ All tests failed. Check internet connection and Yahoo Finance access.")
    
    print(f"\nEnd time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}\n")

if __name__ == '__main__':
    main()
