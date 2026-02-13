
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from datetime import datetime
import random # Placeholder for external API calls

app = Flask(__name__)
CORS(app) # Enable CORS for Flutter frontend

# --- Dummy Data & Mock Logic ---

# Analyst Criteria definitions (simplified for logic)
ANALYST_CRITERIA = {
    'Andri Hakim': {'min_profit_growth': 15, 'max_per': 15, 'max_pbv': 2, 'max_der': 1},
    'Hengky Adinata': {'min_roe': 17, 'max_cut_loss_pct': 10, 'smart_money': True},
    'Warren Buffett': {'min_roe': 15, 'min_roi': 15, 'max_de': 0.5, 'min_eps_growth': 10},
    'MSCI': {'min_market_cap_t': 10, 'min_free_float': 15, 'esg_compliant': True},
    'BlackRock': {'min_roe': 15, 'min_fcf_ni': 0.1, 'max_pe': 25},
}

# Mock Stock Data
MOCK_STOCKS = [
    {'code': 'BBCA', 'name': 'Bank Central Asia', 'price': 9800, 'sector': 'Finance', 'roe': 18.5, 'per': 24.5, 'pbv': 4.8, 'der': 0.2, 'market_cap': 1200, 'net_profit_growth': 12, 'esg': True},
    {'code': 'ADRO', 'name': 'Adaro Energy', 'price': 2450, 'sector': 'Energy', 'roe': 25.0, 'per': 4.5, 'pbv': 0.9, 'der': 0.4, 'market_cap': 80, 'net_profit_growth': 150, 'esg': False}, # Coal exclusion for MSCI
    {'code': 'GOTO', 'name': 'GoTo Gojek Tokopedia', 'price': 84, 'sector': 'Technology', 'roe': -15.0, 'per': -10.0, 'pbv': 0.8, 'der': 0.1, 'market_cap': 100, 'net_profit_growth': 20, 'esg': True},
    {'code': 'UNTR', 'name': 'United Tractors', 'price': 23500, 'sector': 'Industrial', 'roe': 19.0, 'per': 6.5, 'pbv': 1.2, 'der': 0.3, 'market_cap': 90, 'net_profit_growth': 8, 'esg': True},
]

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

@app.route('/api/screen', methods=['POST'])
def screen_stocks():
    """
    Screen stocks based on analyst style and criteria.
    Body:
    {
        "analyst_style": "Warren Buffett", (or others)
        "market_cap_min": 0,
        ...
    }
    """
    data = request.json
    style = data.get('analyst_style', 'Warren Buffett')
    
    # Simple logic to filter mock stocks based on style
    results = []
    
    criteria = ANALYST_CRITERIA.get(style, ANALYST_CRITERIA['Warren Buffett'])
    
    for stock in MOCK_STOCKS:
        # Mocking the AI filtering logic
        score = 0
        reasons = []
        
        # Example logic for Warren Buffett
        if style == 'Warren Buffett':
            if stock['roe'] >= criteria.get('min_roe', 15):
                score += 20
                reasons.append("High ROE")
            if stock['per'] <= criteria.get('max_pe', 25): # using generic max_pe if not specific
                score += 20
                reasons.append("Reasonable PER")
        
        # Example logic for Andri Hakim (value + growth)
        elif style == 'Andri Hakim':
             if stock['per'] < criteria.get('max_per', 15) and stock['pbv'] < criteria.get('max_pbv', 2):
                 score += 40
                 reasons.append("Undervalued (PER/PBV)")
        
        # Add random "AI Forecasting"
        forecast_1m = stock['price'] * (1 + random.uniform(-0.05, 0.10))
        accuracy_ml = random.uniform(80, 95) if score > 0 else random.uniform(50, 70)
        
        # Mock Reverse Merger
        is_reverse_merger = random.choice([True, False]) if stock['code'] == 'GOTO' else False
        
        results.append({
            'code': stock['code'],
            'name': stock['name'],
            'current_price': stock['price'],
            'analyst_score': score,
            'match_reasons': reasons,
            'ml_accuracy': round(accuracy_ml, 2),
            'forecast_1m': round(forecast_1m, 2),
            'forecast_change_pct': round(((forecast_1m - stock['price']) / stock['price']) * 100, 2),
            'is_reverse_merger': is_reverse_merger,
            'news_multibagger': "Rumor akuisisi oleh global player" if is_reverse_merger else "Laporan keuangan stabil"
        })
    
    # Sort by Score/Accuracy
    results.sort(key=lambda x: x['ml_accuracy'], reverse=True)
    
    return jsonify({'results': results, 'meta': {'style': style, 'count': len(results)}})

@app.route('/api/forecast', methods=['POST'])
def forecast_stock():
    """
    Perform linear regression on historical data (mocked) for a specific stock.
    """
    stock_code = request.json.get('code')
    
    # Mock generating historical data
    days = 100
    dates = pd.date_range(end=datetime.now(), periods=days)
    base_price = 1000
    trend = 0.05 # upward trend
    noise = np.random.normal(0, 10, days)
    prices = base_price + (np.arange(days) * trend) + noise
    
    # Linear Regression
    X = np.array(range(days)).reshape(-1, 1)
    y = prices
    
    model = LinearRegression()
    model.fit(X, y)
    
    r_squared = model.score(X, y)
    
    # Predict next 30 days
    future_X = np.array(range(days, days + 30)).reshape(-1, 1)
    predictions = model.predict(future_X)
    
    return jsonify({
        'stock': stock_code,
        'r_squared': r_squared,
        'current_price': prices[-1],
        'prediction_30d': predictions[-1],
        'trend': 'Bullish' if model.coef_[0] > 0 else 'Bearish'
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)
