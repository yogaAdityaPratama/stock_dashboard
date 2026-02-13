# StockID - AI System Architecture & Disclaimer

## Disclaimer & DYOR
**IMPORTANT:** This application uses Artificial Intelligence (AI) to generate stock analysis and predictions. These are for informational purposes only and DO NOT constitute financial or investment advice.
- **Accuracy**: AI models (including Linear Regression used here) are not 100% accurate.
- **Risk**: Stock market investments carry inherent risks.
- **Responsibility**: Users must conduct their own independent research (DYOR) before making any investment decisions. The developers and AI providers are not liable for any losses.

## System Architecture

### Frontend (Flutter)
- **Dashboard (`main.dart`)**: 
    - Overview of portfolio (mocked).
    - Quick actions to AI features.
    - "Dark Soft Purple" aesthetic.
- **Screening (`screening_screen.dart`)**:
    - Dropdown for Analyst Styles (Buffett, Hakim, MSCI, etc.).
    - Connects to Backend API.
    - Displays AI Confidence & Reverse Merger indicators.
- **Analysis (`analysis_screen.dart`)**:
    - Detailed 7-Task AI breakdown.
    - Forecast Charts (using `fl_chart`).
    - Reverse Merger Rumor details.

### Backend (Python Flask)
- **API (`app.py`)**:
    - `/api/screen`: Processes screening logic based on selected analyst style.
    - `/api/forecast`: Generates linear regression predictions on dummy historical data.
- **Data Source**: currently using internal mock data. In production, this would connect to IDX/Bloomberg APIs.

## How to Run
1. Start Backend:
   ```bash
   cd backend
   python app.py
   ```
2. Start Frontend:
   ```bash
   flutter run
   ```
