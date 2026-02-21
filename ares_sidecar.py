import sys
import os

# Add backend directory to path if needed (assuming running from stockID root)
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from blackrock_multibagger_detector import AresVIIMultibaggerEngine

try:
    from app import app, socketio
    from flask import jsonify
except ImportError as e:
    import traceback
    traceback.print_exc()
    print(f"ERROR: Import failed: {e}")
    sys.exit(1)

# Initialize Engine
ares_engine = AresVIIMultibaggerEngine()

# ============================================================================
# BLACKROCK ARES-VII SIDECAR (SHADOW INTEGRATION)
# ============================================================================
# Deskripsi:
# Menambahkan fungsionalitas algoritma Multibagger ke instance Flask yang ada
# tanpa merubah satu baris kode pun di app.py (Zero-Touch Integration).
# ============================================================================

@app.route('/api/blackrock/predictions', methods=['GET'])
def get_blackrock_predictions():
    """
    Endpoint tambahan untuk akses data Ares-VII dari Dashboard / Frontend
    """
    moonshots = ares_engine.get_top_moonshots()
    return jsonify({
        "status": "success",
        "engine": f"Ares-VII {ares_engine.version}",
        "timestamp": datetime.now().isoformat(),
        "predictions": moonshots,
        "advice": "BlackRock Risk Framework: Use 2.5% max position size per ticker."
    })

if __name__ == '__main__':
    print("STARTING: StockID with BlackRock Ares-VII Shadow Integration...")
    # Jalankan menggunakan socketio dari app.py agar WS tetap berfungsi
    socketio.run(app, debug=True, host='0.0.0.0', port=5000, allow_unsafe_werkzeug=True)
