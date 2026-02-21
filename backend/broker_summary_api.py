from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import JSONResponse
import requests
import redis
from cachetools import TTLCache
import os
import random
import time
from datetime import datetime
import logging
import json
import asyncio
from typing import List, Optional
from pydantic import BaseModel
from pydantic_settings import BaseSettings
import yfinance as yf
import socketio

# --- Logging Setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration (Pydantic Settings) ---
class Settings(BaseSettings):
    redis_url: str = "redis://localhost:6379/0"
    use_redis: bool = False
    stockbit_token: Optional[str] = None
    # Internal endpoint often used by Stockbit web app
    stockbit_api_url: str = "https://stockbit.com/api/v2.4/orderflow/bandarmology"
    
    class Config:
        env_file = ".env"

settings = Settings()

# --- Pydantic Models for Response ---
class BrokerData(BaseModel):
    broker: str
    value: str
    avg_price: int
    volume: int

class BrokerSummaryResponse(BaseModel):
    symbol: str
    market_maker_action: str
    avg_price: int
    top_buyers: List[BrokerData]
    top_sellers: List[BrokerData]
    last_updated: str
    dominant_broker: str

sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins='*')
app = FastAPI(title="Broker Summary API", version="1.2.0")
socket_app = socketio.ASGIApp(sio, app)

# --- Service Layer ---
class BrokerSummaryService:
    def __init__(self):
        # Fallback in-memory cache
        self.ttl_cache = TTLCache(maxsize=100, ttl=300)
        self.redis_client = None
        
        if settings.use_redis:
            try:
                self.redis_client = redis.from_url(settings.redis_url, decode_responses=True)
                logger.info("✅ Redis connected")
            except Exception as e:
                logger.error(f"❌ Redis connection failed: {e}")

    def _get_user_agent(self):
        user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
        ]
        return random.choice(user_agents)

    async def get_data(self, symbol: str) -> dict:
        symbol = symbol.upper()
        cache_key = f"broker_summary:{symbol}"

        # 1. Try Cache
        cached = await self._get_from_cache(cache_key)
        if cached:
            logger.info(f"CACHE HIT for {symbol}")
            return cached

        logger.info(f"CACHE MISS for {symbol}, fetching fresh data...")
        
        # 2. Try Fetching (Local JSON -> Real Market Simulation)
        data = await self._fetch_fresh_data(symbol)
        
        # 3. Save Cache
        await self._save_to_cache(cache_key, data)
        
        return data

    async def _get_from_cache(self, key: str):
        if self.redis_client:
            val = self.redis_client.get(key)
            if val:
                return json.loads(val)  # SECURITY: json.loads, NOT eval()
        else:
            # TTLCache is sync, but fast enough
            return self.ttl_cache.get(key)
        return None

    async def _save_to_cache(self, key: str, data: dict):
        if self.redis_client:
            self.redis_client.setex(key, 300, json.dumps(data))
        else:
            self.ttl_cache[key] = data

    async def _fetch_fresh_data(self, symbol: str):
        # Priority 1: Local JSON (Debug)
        if os.path.exists("stockbit_response.json"):
            try:
                # Use thread pool for file I/O to avoid blocking valid async loop
                loop = asyncio.get_event_loop()
                data = await loop.run_in_executor(None, self._read_local_json)
                logger.info("Loaded local stockbit_response.json")
                return self._process_stockbit_response(symbol, data)
            except Exception as e:
                logger.warning(f"Failed to read local JSON: {e}")

        # Priority 2: Real Market Simulation (YFinance)
        return await self._generate_simulation_data(symbol)
    
    def _read_local_json(self):
        with open("stockbit_response.json", "r") as f:
            return json.load(f)

    async def _generate_simulation_data(self, symbol: str):
        logger.info(f"GENERATING ANALYTICAL DATA for {symbol}")
        
        base_price = 5000 
        real_volume = 10_000_000 # Default fallback volume
        price_change_pct = 0.0
        
        try:
            loop = asyncio.get_event_loop()
            history = await loop.run_in_executor(None, lambda: self._fetch_yfinance_price(symbol))
            
            if not history.empty:
                # 1. Get Real Price
                base_price = int(history['Close'].iloc[-1])
                prev_close = int(history['Close'].iloc[-2]) if len(history) > 1 else base_price
                
                # 2. Get Real Volume (Shares)
                real_volume = int(history['Volume'].iloc[-1])
                
                # 3. Calculate Change & Logic
                price_change = base_price - prev_close
                price_change_pct = (price_change / prev_close) if prev_close else 0
                
                logger.info(f"✅ Real Data {symbol}: Price={base_price}, Vol={real_volume}, Chg={price_change_pct:.2%}")
            else:
                logger.warning(f"⚠️ Empty history for {symbol}")
                
        except Exception as e:
             logger.error(f"❌ Error fetching yfinance: {e}")

        # --- ANALYTICAL INFRENCE (Simulating Bandar Logic from Real Data) ---
        
        # Determine Status based on Price Action & Volume
        # If Price Up > 1% ? Likely Accumulation
        # If Price Down < -1% ? Likely Distribution
        if price_change_pct > 0.01:
            market_maker_action = "BUYING"
            dominance = 0.65 # Top buyers dominate 65%
        elif price_change_pct < -0.01:
            market_maker_action = "SELLING"
            dominance = 0.35 # Top buyers weak (sellers dominate)
        else:
            market_maker_action = "NEUTRAL"
            dominance = 0.50

        # Calculate Real Transaction Value for the day
        total_market_value = (real_volume * base_price)
        
        # Brokers List (still anonymous/simulated codes as this is proprietary)
        brokers = ["YP", "PD", "AK", "BK", "KZ", "CC", "YU", "DR", "OD", "XC", "NI", "MG", "ZL"]
        
        # Distribute the Real Value among top brokers based on 'dominance'
        buy_portion_total = total_market_value * dominance
        sell_portion_total = total_market_value * (1 - dominance)
        
        def generate_broker_distribution(total_value_pool, is_buyer):
            result = []
            used_brokers = []
            pool_remaining = total_value_pool
            
            # Top 3 brokers usually hold 60-80% of the top 5's accumulation
            weights = [0.40, 0.25, 0.15, 0.12, 0.08] 
            
            for i in range(5):
                b_code = random.choice(brokers)
                while b_code in used_brokers: b_code = random.choice(brokers)
                used_brokers.append(b_code)
                
                # Assign value based on weight
                allocated_value = total_value_pool * weights[i]
                
                # Volume = Value / Price
                # Buyers avg price usually slightly higher than market (Haka)
                # Sellers avg price usually slightly lower (Haki)
                
                offset = random.randint(0, 50) if is_buyer else random.randint(-50, 0)
                avg_price_est = base_price + offset
                if avg_price_est <= 0: avg_price_est = base_price
                
                vol_est = int(allocated_value / avg_price_est)
                val_billions = allocated_value / 1_000_000_000
                
                result.append({
                    "broker": b_code,
                    "value": f"{val_billions:.1f}B",
                    "avg_price": avg_price_est,
                    "volume": vol_est
                })
            return result

        top_buyers = generate_broker_distribution(buy_portion_total, True)
        top_sellers = generate_broker_distribution(sell_portion_total, False)
        
        dominant_broker = top_buyers[0]['broker'] if market_maker_action == "BUYING" else top_sellers[0]['broker']
        
        return {
            "symbol": symbol,
            "market_maker_action": market_maker_action,
            "avg_price": base_price,
            "dominant_broker": dominant_broker,
            "top_buyers": top_buyers,
            "top_sellers": top_sellers,
            "last_updated": datetime.now().isoformat()
        }

    def _fetch_yfinance_price(self, symbol: str):
        # Try with .JK first
        ticker = yf.Ticker(f"{symbol}.JK")
        hist = ticker.history(period="1d")
        
        # If empty, maybe it's an index or doesn't need .JK (rare but possible)
        if hist.empty:
             logger.warning(f"Retry fetch without .JK for {symbol}")
             ticker = yf.Ticker(symbol)
             hist = ticker.history(period="1d")
             
        return hist

    def _process_stockbit_response(self, symbol: str, data: dict):
        try:
            real_data = data.get("data", {})
            analysis = real_data.get("analysis", {})
            action_status = analysis.get("status", "NEUTRAL").upper()
            
            mm_action = "NEUTRAL"
            if "ACCUM" in action_status or "BIG" in action_status:
                mm_action = "BUYING"
            elif "DISTRIB" in action_status:
                mm_action = "SELLING"

            def parse_brokers(raw_list):
                result = []
                for b in raw_list[:5]:
                    result.append({
                        "broker": b.get("broker_code", "XX"),
                        "value": f"{b.get('value', 0) / 1_000_000_000:.1f}B",
                        "avg_price": int(b.get("avg_price", 0)),
                        "volume": int(b.get("volume", 0))
                    })
                return result

            top_buyers_list = parse_brokers(real_data.get("top_buyers", []))
            top_sellers_list = parse_brokers(real_data.get("top_sellers", []))
            
            dominant_broker = top_buyers_list[0]['broker'] if mm_action == "BUYING" and top_buyers_list else (
                top_sellers_list[0]['broker'] if top_sellers_list else "N/A"
            )

            return {
                "symbol": symbol,
                "market_maker_action": mm_action,
                "avg_price": int(real_data.get("closing_price", 0)),
                "dominant_broker": dominant_broker,
                "top_buyers": top_buyers_list,
                "top_sellers": top_sellers_list,
                "last_updated": datetime.now().isoformat()
            }
        except Exception as e:
            logger.error(f"Error parsing Stockbit JSON: {e}")
            # Fallback to simulation if parsing fails
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            return loop.run_until_complete(self._generate_simulation_data(symbol))

def get_service():
    return BrokerSummaryService()

connected_clients = {}

@sio.event
async def connect(sid, environ):
    connected_clients[sid] = {'symbols': []}
    await sio.emit('connected', {'message': 'Connected to Broker Summary'}, room=sid)

@sio.event
async def disconnect(sid):
    if sid in connected_clients:
        del connected_clients[sid]

@sio.event
async def subscribe(sid, data):
    symbol = data.get('symbol', '').upper()
    if sid in connected_clients:
        if symbol not in connected_clients[sid]['symbols']:
            connected_clients[sid]['symbols'].append(symbol)
    await sio.emit('subscribed', {'symbol': symbol}, room=sid)
    
    service = BrokerSummaryService()
    initial_data = await service.get_data(symbol)
    await sio.emit('broker_summary_data', initial_data, room=sid)

@sio.event
async def unsubscribe(sid, data):
    symbol = data.get('symbol', '').upper()
    if sid in connected_clients and symbol in connected_clients[sid]['symbols']:
        connected_clients[sid]['symbols'].remove(symbol)

async def broadcast_updates():
    while True:
        await asyncio.sleep(5)
        service = BrokerSummaryService()
        for sid, client_data in list(connected_clients.items()):
            for symbol in client_data.get('symbols', []):
                try:
                    fresh_data = await service.get_data(symbol)
                    fresh_data['last_updated'] = datetime.now().isoformat()
                    await sio.emit('broker_summary_data', fresh_data, room=sid)
                except Exception as e:
                    logger.error(f"Error broadcasting to {sid}: {e}")

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(broadcast_updates())

# --- Endpoints ---
@app.get("/api/v1/broker-summary/{symbol}", response_model=BrokerSummaryResponse)
async def get_broker_summary(symbol: str, service: BrokerSummaryService = Depends(get_service)):
    try:
        return await service.get_data(symbol)
    except Exception as e:
        logger.error(f"Internal Server Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(socket_app, host="0.0.0.0", port=5000)
