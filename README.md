# StockID Project Setup Guide

This project consists of a Flutter frontend and a Python Flask backend.

## Prerequisites
- Flutter SDK
- Python 3.8+
- VS Code (recommended)

## Project Structure
- `lib/`: Flutter frontend code.
- `backend/`: Python backend code for AI/ML and API.

## Setup Instructions

### 1. Backend Setup
Navigate to the `backend` directory and install dependencies:

```bash
cd backend
pip install flask flask-cors pandas numpy scikit-learn
```

Run the server:
```bash
python app.py
```
The server will start at `http://127.0.0.1:5000`.

### 2. Frontend Setup
Navigate to the root directory and get dependencies:

```bash
flutter pub get
```

Run the Flutter app:
```bash
flutter run
```

## Features Implemented
- **Design System**: Dark Soft Purple theme as requested.
- **Backend API**: Flask server with `/api/screen` and `/api/forecast` endpoints.
- **AI Logic**: 
    - Mocked Analyst Criteria (Buffett, Hakim, etc.)
    - Linear Regression model for price forecasting.
    - Reverse Merger indicator logic placeholder.

## Next Steps
- Connect the Flutter frontend to the Python backend using `http` package.
- Implement real-time data fetching from IDX/Yahoo Finance in `app.py`.
- Integrate Google Gemini/Grok API for qualitative analysis.
