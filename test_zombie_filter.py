import yfinance as yf

def verify_liquidity(candidate_codes):
    tickers_str = " ".join([f"{c}.JK" for c in candidate_codes])
    print(f"Checking: {tickers_str}")
    try:
        verify_data = yf.Tickers(tickers_str)
        for c in candidate_codes:
            t_obj = verify_data.tickers[f"{c}.JK"]
            hist = t_obj.history(period="1d")
            vol = hist['Volume'].iloc[-1] if not hist.empty else "N/A"
            print(f"Ticker: {c}, Last Day Volume: {vol}")
            if vol == 0:
                print(f"  [RESULT] {c} is a ZOMBIE (Vol=0)")
            else:
                print(f"  [RESULT] {c} is ACTIVE (Vol={vol})")
    except Exception as e:
        print(f"Error: {e}")

# ZATA is known zombie, BBCA is active.
candidates = ["ZATA", "BBCA", "GOTO", "BNBR"]
verify_liquidity(candidates)
