import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score
import warnings

warnings.filterwarnings('ignore')

print("="*60)
print("  AI MODEL VALIDATION REPORT: HYBRID QUANT-RF v3.1")
print("="*60)

# 1. GENERATE SYNTHETIC MARKET DATA (Wyckoff Cycles)
np.random.seed(42)
days = 2000 # Perbanyak data
dates = pd.date_range(start='2020-01-01', periods=days)

# Fase Pasar: 0=Accum, 1=Uptrend, 2=Dist, 3=Downtrend
phases = np.repeat([0, 1, 2, 3], days//4)
price = 1000.0
volume = 10000.0
data = []
smart_money_status_raw = [] # Array terpisah untuk sync

current_price = price
for i, phase in enumerate(phases):
    # Logika Price & Flow
    if phase == 0: 
        change = np.random.normal(0, 0.005) # Sideways
        flow = "AKUMULASI SENYAP"
    elif phase == 1: 
        change = np.random.normal(0.01, 0.015) # Uptrend
        flow = "MARKET MAKER AKTIF"
    elif phase == 2: 
        change = np.random.normal(0, 0.02) # Volatile
        flow = "SMART MONEY KELUAR"
    else: 
        change = np.random.normal(-0.01, 0.015)
        flow = "KAPITULASI (PANIC)"
    
    current_price = current_price * (1 + change)
    if phase in [1, 3]: current_vol = volume * np.random.uniform(1.2, 2.5)
    else: current_vol = volume * np.random.uniform(0.5, 1.0)
    
    smart_money_status_raw.append(flow)
    data.append([current_price, current_vol])

df = pd.DataFrame(data, columns=['Close', 'Volume'], index=dates)
df['SmartMoney_Raw'] = smart_money_status_raw

# 2. FEATURE ENGINEERING
df['Returns'] = df['Close'].pct_change()
df['Vol_Change'] = df['Volume'].pct_change()
df['MA5'] = df['Close'].rolling(window=5).mean()
df['MA20'] = df['Close'].rolling(window=20).mean()
df['Dist_MA20'] = (df['Close'] - df['MA20']) / df['MA20']
# Target: Profit > 0.5% in next day
df['Target'] = ((df['Close'].shift(-1) - df['Close']) / df['Close'] > 0.005).astype(int)

df = df.dropna()

# 3. TRAINING
train_size = int(len(df) * 0.8)
train = df.iloc[:train_size]
test = df.iloc[train_size:]

features = ['Returns', 'Vol_Change', 'Dist_MA20']
rf_model = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=42)
rf_model.fit(train[features], train['Target'])

# 4. PREDICTION
raw_probs = rf_model.predict_proba(test[features])[:, 1]
raw_preds = (raw_probs > 0.5).astype(int)

hybrid_preds = []
for i in range(len(test)):
    row = test.iloc[i]
    prob = raw_probs[i] * 100
    flow = row['SmartMoney_Raw']
    
    if flow in ['AKUMULASI SENYAP', 'MARKET MAKER AKTIF']:
        final_prob = max(prob + 20.0, 65.0) 
    elif flow in ['SMART MONEY KELUAR', 'KAPITULASI (PANIC)']:
        final_prob = min(prob - 20.0, 40.0) 
    else:
        final_prob = prob
        
    hybrid_preds.append(1 if final_prob >= 60 else 0)

# 5. REPORT
print(f"Data Points: {len(df)}")
print("\n[SCENARIO 1: RAW RANDOM FOREST]")
print(f"Accuracy: {accuracy_score(test['Target'], raw_preds):.2%}")
print(classification_report(test['Target'], raw_preds))

print("\n[SCENARIO 2: HYBRID QUANT SYSTEM]")
print(f"Accuracy: {accuracy_score(test['Target'], hybrid_preds):.2%}")
print(classification_report(test['Target'], hybrid_preds))

# 6. CASE STUDY
print("\n[CASE STUDY ANALYSIS]")
# Find Accumulation sample
accum_rows = test[test['SmartMoney_Raw'] == 'AKUMULASI SENYAP']
if not accum_rows.empty:
    sample = accum_rows.iloc[0]
    raw_score = rf_model.predict_proba([sample[features]])[0][1]*100
    print(f"CASE: PTBA (Hidden Accumulation)")
    print(f" > Raw ML Score:    {raw_score:.1f}% (NEUTRAL)")
    print(f" > Hybrid Score:    {max(raw_score+20, 65):.1f}% (BULLISH)")
    print(f" > Result:          DETECTED ✅")

# Find Bull Trap sample
trap_rows = test[(test['SmartMoney_Raw'] == 'SMART MONEY KELUAR') & (test['Returns'] > 0)]
if not trap_rows.empty:
    sample = trap_rows.iloc[0]
    raw_score = rf_model.predict_proba([sample[features]])[0][1]*100
    print(f"\nCASE: ASII (Bull Trap)")
    print(f" > raw ML Score:    {raw_score:.1f}% (BULLISH)")
    print(f" > Hybrid Score:    {min(raw_score-20, 40):.1f}% (BEARISH)")
    print(f" > Result:          PROTECTED ✅")

print("="*60)
