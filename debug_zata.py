import yfinance as yf
import datetime

print("=== Checking ZATA vs BBCA on Yahoo Finance (v8) ===")
# Use yfinance or direct requests (better use yfinance for debug)
zata = yf.Ticker("ZATA.JK")
info = zata.history(period="1d")
print(f"ZATA History 1d: {info}")

bbca = yf.Ticker("BBCA.JK")
info_bbca = bbca.history(period="1d")
print(f"BBCA History 1d: {info_bbca}")

# Checking regularMarketChangePercent
print(f"ZATA Fast Info: {zata.fast_info}")
print(f"BBCA Fast Info: {bbca.fast_info}")

# Get change percent for the current market session
# If it hasn't traded since Feb 20, change today should be 0.
