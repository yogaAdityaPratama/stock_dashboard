import requests
import concurrent.futures
import time
from colorama import Fore, Style, init

# Initialize Colorama
init(autoreset=True)

# 🚀 TARGET: SAHAM DENGAN POTENSI KENAIKAN > 30%
# Kita scan campuran saham Blue Chip, Lapis 2, dan Saham Volatile (High Beta)
STOCKS_TO_SCAN = [
    # --- BANK DIGITAL & TECH (High Beta) ---
    "ARTO", "BBYB", "BANK", "BBHI", "AGRO", "BCIC", "BABP", "BNBA", "AMAR",
    "GOTO", "BUKA", "EMTK", "BELI", "WIFI", "MTDL", "MCAS", "NFCX",

    # --- ENERGY & COMMODITIES (Cyclical) ---
    "ADRO", "PTBA", "ITMG", "PGAS", "MEDC", "AKRA", "ELSA", "INDY",
    "ANTM", "INCO", "TINS", "MDKA", "BRMS", "PSAB", "HRUM", "NCKL", "MBMA",
    "AMMN", "CUAN", "BREN", "PTMP", "STRK", "BRAND", "IOF", "SATE", "FUTR",

    # --- KONGLOMERASI & INFRA (Volatile) ---
    "PANI", "TPIA", "BRPT", "FILM", "KIJA", "BEST", "SSIA",
    "JSMR", "META", "EXCL", "ISAT", "TLKM", "FREN",

    # --- KONSTRUKSI & PROPERTI (Turnaround?) ---
    "WIKA", "PTPP", "ADHI", "WSKT", "Pans", "CTRA", "BSDE", "SMRA", "ASRI",

    # --- CONSUMER & OTHERS ---
    "ICBP", "INDF", "MYOR", "UNVR", "GGRM", "HMSP", "SIDO", "KLBF",
    "ACES", "MAPI", "ERAA", "AMRT", "MIDI", "ROTI",

    # --- BLUE CHIP (Benchmark) ---
    "BBCA", "BBRI", "BMRI", "BBNI", "ASII", "UNTR"
]

BASE_URL = "http://127.0.0.1:5000/api/forecast_advanced"
RESULTS = []

def scan_stock(code):
    """Scan single stock and return (code, return, signal, message)"""
    try:
        start_time = time.time()
        response = requests.post(BASE_URL, json={"code": code}, timeout=20)
        elapsed = time.time() - start_time
        
        if response.status_code == 200:
            data = response.json()
            ret = data.get("expected_return_30d_%", 0)
            quant = data.get("quant_signal_advanced", {})
            signal = quant.get("level", "UNKNOWN")
            msg = quant.get("message", "No message")
            
            # Print progress immediately
            color = Fore.GREEN if ret > 0 else Fore.RED
            if ret > 20: color = Fore.CYAN # Jackpot potential
            
            print(f"{color}Scanning {code:<5} ... Done ({elapsed:.2f}s) -> Forecast: {ret:>6.2f}% [{signal}]")
            
            return {
                "code": code,
                "return": ret,
                "signal": signal,
                "message": msg,
                "price": data.get("current_price", 0)
            }
    except Exception as e:
        print(f"{Fore.YELLOW}Scanning {code:<5} ... Failed ({str(e)[:20]})")
    return None

print(f"\n{Fore.YELLOW}{'='*60}")
print(f"{Fore.YELLOW}🚀 STARTING DEEP MARKET SCAN (Target: >30% Return)")
print(f"{Fore.YELLOW}🎯 Scanning {len(STOCKS_TO_SCAN)} stocks concurrently...")
print(f"{Fore.YELLOW}{'='*60}\n")

start_scan = time.time()

# Use ThreadPoolExecutor for concurrent scanning (Much faster!)
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    futures = [executor.submit(scan_stock, code) for code in STOCKS_TO_SCAN]
    
    for future in concurrent.futures.as_completed(futures):
        res = future.result()
        if res:
            RESULTS.append(res)

TOTAL_TIME = time.time() - start_scan

# --- ANALISIS HASIL ---
RESULTS.sort(key=lambda x: x["return"], reverse=True)

print(f"\n{Fore.YELLOW}{'='*60}")
print(f"{Fore.CYAN}🏆 TOP GEM FINDER (>20% Potential Return)")
print(f"{Fore.YELLOW}{'='*60}")

gems_found = 0
for res in RESULTS:
    if res["return"] > 20: # Menampilkan yang > 20% (karena 30% mungkin sangat jarang)
        gems_found += 1
        print(f"\n💎 {Fore.CYAN}{res['code']} (+{res['return']}%)")
        print(f"   Signal : {res['signal']}")
        print(f"   Price  : {res['price']}")
        print(f"   Reason : {res['message']}")

if gems_found == 0:
    print(f"\n{Fore.RED}😔 Tidak ditemukan saham dengan potensi > 20% di list ini.")
    print(f"Pasar mungkin sedang Bearish/Sideways berat.")
    
    # Tampilkan Top 5 Saja sebagai hiburan
    print(f"\n{Fore.WHITE}Top 5 Terbaik saat ini:")
    for res in RESULTS[:5]:
        print(f"👉 {res['code']}: {res['return']}% ({res['signal']})")

print(f"\n{Fore.WHITE}Scan finished in {TOTAL_TIME:.2f} seconds.")
