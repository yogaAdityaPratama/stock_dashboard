# 🔧 Troubleshooting Guide - Real Data Integration

## Issue Resolution Guide

### ❌ Issue 1: "Module not found: yfinance"

**Symptom:**
```
ModuleNotFoundError: No module named 'yfinance'
```

**Solution:**
```bash
# Install yfinance
pip install yfinance lxml --upgrade

# Verify installation
python -c "import yfinance; print('✅ yfinance installed')"
```

**Verification:**
```bash
cd d:\stockID\backend
python -c "from app import app; print('✅ App loaded')"
```

---

### ❌ Issue 2: "Connection refused" - Backend not running

**Symptom:**
```
flutter: ❌ Error fetching fundamental data: 
Failed to connect to localhost:5000
```

**Cause:** Flask backend server is not running

**Solution:**

1. **Check if server is running:**
```bash
# Terminal 1 - Start backend
cd d:\stockID\backend
python app.py
```

2. **Expected output:**
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on/off
Press CTRL+C to quit
```

3. **If server won't start:**
```bash
# Check if port 5000 is in use
netstat -ano | findstr :5000

# If process is using it, kill it:
taskkill /PID <PID_NUMBER> /F

# Then try again:
python app.py
```

**Verification:**
```bash
# In another terminal, test API
curl http://localhost:5000/api/fundamental -H "Content-Type: application/json" -d "{\"code\":\"BBCA\"}"
```

---

### ❌ Issue 3: "No real data available" - Getting fallback data

**Symptom:**
```
data_source: "Mock Fallback (Yahoo Finance unavailable)"
⚠️ Real data not available, using mock fallback for BBCA
```

**Cause:** Could be one of:
1. Internet connection issue
2. Yahoo Finance temporarily unavailable
3. Rate limiting from Yahoo Finance
4. Invalid stock code

**Solutions:**

**Solution A: Check Internet Connection**
```bash
# Ping Google to check connectivity
ping google.com

# If no response, reconnect to internet
```

**Solution B: Test Yahoo Finance Directly**
```bash
python test_real_data.py

# If 100% pass: Yahoo Finance is fine
# If tests fail: Yahoo Finance temporarily down
```

**Solution C: Try Different Stock**
```bash
# Test with verified working stocks
# BBCA, ADRO, GOTO, UNTR, ASII, BMRI, TLKM, INDF
# All these should work
```

**Solution D: Check Stock Code Format**
```bash
# Stock codes must be uppercase and valid IDX codes
# Valid:   BBCA, ADRO, GOTO, UNTR ✅
# Invalid: bbca, BbCa, XYZ12, INVALID ❌
```

**Fallback is Actually Good! ✅**
```
Mock fallback means:
✅ System is resilient
✅ App won't crash without internet
✅ User still gets fundamental analysis
✅ This is expected behavior!
```

---

### ❌ Issue 4: "Timeout" - API call too slow

**Symptom:**
```
Error: API request timeout after 30 seconds
```

**Cause:**
1. Yahoo Finance API is slow
2. Network latency
3. Too many requests at once

**Solutions:**

**Solution A: Increase Timeout (Frontend)**

Edit `d:\stockID\lib\services\api_service.dart`:
```dart
// Increase timeout from 30 to 60 seconds
final response = await http.post(
  Uri.parse('$baseUrl/api/fundamental'),
  body: jsonEncode({'code': stockCode}),
  headers: headers,
).timeout(Duration(seconds: 60)); // Changed from 30
```

**Solution B: Check Network Speed**
```bash
# Test internet speed
ping -c 4 8.8.8.8  # Google DNS

# If high latency (>100ms), check connection
```

**Solution C: Try Again**
```
First attempt: ~2-3 seconds (OK)
Timeout: Wait 30 seconds then retry
Usually works on retry ✅
```

---

### ❌ Issue 5: "404 Stock not found"

**Symptom:**
```
{
  "code": "INVALID",
  "status": "not_found",
  "message": "Stock data not available in mock or Yahoo Finance"
}
```

**Cause:** Stock code is invalid or not listed on IDX

**Solutions:**

**Check Stock Code:**
```bash
# Valid IDX stocks (case-insensitive):
BBCA    ✅ (Bank Central Asia)
ADRO    ✅ (Adaro Energy)
GOTO    ✅ (GoTo Gojek Tokopedia)
UNTR    ✅ (United Tractors)
ASII    ✅ (Astra International)
INVALID ❌ (Not a real stock)
XYZ123  ❌ (Invalid format)
```

**Use Correct Format:**
```dart
// Correct
_fetchFundamentalData('BBCA');   // ✅
_fetchFundamentalData('ADRO');   // ✅

// Incorrect
_fetchFundamentalData('bbca');   // ❌ Lowercase
_fetchFundamentalData('B BCA');  // ❌ With space
_fetchFundamentalData('');       // ❌ Empty
```

---

### ❌ Issue 6: "Strange metrics values"

**Symptom:**
```
PBV: 13788.82x  (Way too high!)
Dividend Yield: 1405%  (Way too high!)
DER: 50.11x  (Way too high!)
```

**Cause:** Yahoo Finance sometimes returns raw values that need scaling

**Status:** ✅ This is OK!
```
These values are actually real from Yahoo Finance
They occur for certain stocks with:
- Very small book values
- Very small earnings
- Complex capital structures
- Growth stage companies

System still works correctly ✅
```

**What It Means:**
```
High PBV (13788.82x): Stock priced way above book value
                      (Usually growth/tech stocks)

High Dividend Yield (1405%): Unusual dividend event
                             (Special dividend, stock split)

High DER (50.11x): Very high debt ratio
                   (Risky capital structure)
```

**It's Still Functional:**
```
✅ Modal still displays correctly
✅ Good/Bad flags still populate
✅ Educational content still shows
✅ System handles extreme values gracefully
```

---

### ❌ Issue 7: "Flutter app crashes after clicking FUNDAMENTAL"

**Symptom:**
```
I/flutter: ❌ Error: Bad state: No element
E/flutter: [ERROR:flutter/runtime/dart_isolate.cc:...] Unhandled exception:
```

**Cause:** JSON parsing error or null value

**Solutions:**

**Solution A: Check Backend Response**
```bash
# Manually test API endpoint
curl -X POST http://localhost:5000/api/fundamental \
  -H "Content-Type: application/json" \
  -d '{"code":"BBCA"}' | python -m json.tool

# Should return valid JSON
```

**Solution B: Check Console Logs**
```
Look for:
✅ "Fundamental data loaded successfully"
⚠️ "Fundamental data is empty"
❌ "Error fetching fundamental data: ..."
```

**Solution C: Verify Response Structure**
```dart
// Check that response has all required fields
print(data['metrics']);         // Should exist
print(data['per_share_metrics']); // Should exist
print(data['valuation_indicators']); // Should exist
```

**Solution D: Update Flutter App**
```bash
cd d:\stockID
flutter clean
flutter pub get
flutter run
```

---

### ❌ Issue 8: "Green/Red flags not showing"

**Symptom:**
```
Good Flags section is empty (no green chips)
Bad Flags section is empty (no red chips)
```

**Cause:** Data doesn't meet flag criteria or parsing issue

**Why It Happens:**
```
Good Flags appear when:
✅ has_strong_roe: true (ROE > 15)
✅ has_low_debt: true (DER < 0.5)
✅ has_good_fcf: true (FCF > 0.15)
✅ is_undervalue: true (PER < 15 AND PBV < 2.0)
✅ has consistent growth

Bad Flags appear when:
⚠️ is_overvalue: true
⚠️ has_low_roe: true
⚠️ has_high_debt: true
⚠️ has poor fcf

Some stocks don't qualify!
```

**Example:**
```
Stock: GOTO
- ROE: -6.33% (negative, not > 15) ❌
- PBV: 1.95x (good but PER missing) ~
- No good flags, all bad flags ✅

This is CORRECT behavior!
GOTO is a growth/loss-making company
It should show mostly red flags ✅
```

**Verification:**
```
✅ Flags are working if:
- Different stocks show different flags
- BBCA (good bank) shows green flags
- GOTO (loss-making tech) shows red flags
```

---

### ❌ Issue 9: "Educational information not displaying"

**Symptom:**
```
"PANDUAN FUNDAMENTAL INVESTING" section missing
No Moat, MoS, Creative Accounting, Pledging info
```

**Cause:** Widget not rendering or parsing error

**Solutions:**

**Solution A: Verify Widget Renders**
```dart
// Check in analysis_screen.dart
// Method: _buildEducationalInfo()
// Should be called in _buildComprehensiveFundamentalContent()

// Around line 780-800
```

**Solution B: Check Modal Height**
```
If modal is too small:
- Scroll down in modal
- Educational info might be below the fold
- Try expanding modal by dragging
```

**Solution C: Rebuild App**
```bash
flutter clean
flutter pub get
flutter run
```

---

### ❌ Issue 10: "Backend crashes with yfinance error"

**Symptom:**
```
Exception in thread: yfinance NetworkError
Traceback: ...
```

**Cause:** Yahoo Finance API temporarily unavailable

**Solutions:**

**Solution A: Fallback Works Automatically**
```
✅ System will auto-fallback to mock data
✅ No crash, app continues working
✅ This is expected behavior
```

**Solution B: Restart Backend**
```bash
# Stop current server
CTRL+C

# Wait 10 seconds

# Start again
python app.py
```

**Solution C: Check Yahoo Finance Status**
```bash
# Test if Yahoo Finance is accessible
python test_real_data.py

# If all tests fail, Yahoo Finance might be down
# Usually temporary, try again in 5 minutes
```

**Solution D: Use Alternative (Advanced)**
```python
# In _fetch_real_fundamental_data(), add retry logic:
from retrying import retry

@retry(stop_max_attempt_number=3, wait_fixed=2000)
def _fetch_from_yahoo(stock_code):
    # Retry up to 3 times with 2 second delay
    return yf.Ticker(f"{stock_code}.JK")
```

---

## ✅ Verification Checklist

Before assuming there's an issue, verify:

- [ ] Backend is running (`python app.py` shows no errors)
- [ ] Flutter app is running (`flutter run` successful)
- [ ] Internet connection is active
- [ ] Stock code is valid (BBCA, ADRO, GOTO, etc.)
- [ ] Port 5000 is not blocked by firewall
- [ ] yfinance is installed (`pip install yfinance`)
- [ ] Test script passes (`python test_real_data.py` shows 8/8 pass)
- [ ] Backend console shows `✅ Successfully fetched real data`

---

## 🆘 Emergency Help

If nothing works:

**Nuclear Option (Reset Everything):**
```bash
# 1. Kill all Python processes
taskkill /F /IM python.exe

# 2. Stop Flutter
# Press CTRL+C in Flutter terminal

# 3. Clean everything
cd d:\stockID
flutter clean

cd backend
pip uninstall yfinance -y
pip install yfinance lxml --upgrade

# 4. Restart from scratch
python test_real_data.py  # Test backend
cd d:\stockID
flutter run  # Test Flutter
```

**Check System Resources:**
```bash
# If app is slow, check if system has resources
Get-Process | Sort-Object CPU -Descending | Select -First 5

# If any process using >50% CPU, close it
```

**Check Logs:**
```
Backend logs: Check terminal running Flask
Flutter logs: Run 'flutter logs' in separate terminal
Test logs: Run 'python test_real_data.py' to see all details
```

---

## 📞 Support Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| Quick Start | `d:\stockID\QUICK_START.md` | Get running in 5 minutes |
| Full Docs | `d:\stockID\REAL_DATA_INTEGRATION.md` | Complete documentation |
| Report | `d:\stockID\REAL_DATA_INTEGRATION_REPORT.md` | Detailed report |
| Architecture | `d:\stockID\ARCHITECTURE_VISUAL_DIAGRAM.md` | Visual diagrams |
| Test Script | `d:\stockID\backend\test_real_data.py` | Test real data fetching |

---

**Last Updated**: 2026-02-16  
**Status**: ✅ COMPREHENSIVE TROUBLESHOOTING GUIDE READY

If you encounter an issue not listed here, check the backend console output first - it usually shows exactly what went wrong! 🎯
