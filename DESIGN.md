# StockID AI System Design Document

## Overview
StockID is a professional AI-powered stock screening application for the Indonesian market (IDX), designed by experts from BlackRock, J.P. Morgan, and MSCI. It leverages Flutter for cross-platform (Web/Mobile) capability and Firestore/Python backend for data processing and AI analysis.

## Core Features
1.  **AI Analyst Screening**: Multi-strategy screening (Andri Hakim, Hengky Adinata, Warren Buffett, MSCI, BlackRock).
2.  **Reverse Merger Indicator**: Detection of backdoor listings via news and unusual market activity.
3.  **Predictive Analytics**: Machine Learning (Linear Regression) for price forecasting with >80% accuracy r-squared target.
4.  **Portfolio Management**: Real-time tracking, SIP calculator, and sector allocation.
5.  **News Integration**: Real-time news feed for "Big News" and sentiment analysis.

## Technical Architecture

### Frontend (Flutter)
*   **Framework**: Flutter (Dart)
*   **State Management**: Provider / Riverpod / Bloc (TBD based on complexity)
*   **UI/UX**: Custom "Dark Soft Purple" theme.
    *   Primary: `#4B0082`
    *   Secondary: `#301934`
    *   Background: `#121212`
    *   Accent: `#8A2BE2`

### Backend (Python Flask + Firestore)
*   **API Server**: Python Flask
*   **Database**: Google Firestore (User data, Portfolio), MongoDB (Historical Data - Optional)
*   **AI/ML**:
    *   **Screening**: Grok/Gemini API for qualitative analysis.
    *   **Forecasting**: Scikit-learn (Linear Regression) on historical price data.
    *   **News**: Twitter/X Search API, Google News API.

### Data Flow
1.  **User Action**: User logs in -> Dashboard -> Input Portfolio/Screening Criteria.
2.  **Screening Request**: Frontend sends filter criteria + selected "Analyst Style" to Backend API.
3.  **Data Fetching**: Backend fetches real-time data from IDX/finance APIs (Coingecko/Polygon).
4.  **AI Processing**:
    *   Quantitative data passed to ML model for forecasting.
    *   Qualitative data + News passed to LLM (Grok/Gemini) for "Multibagger" probability and "Reverse Merger" checks.
5.  **Response**: JSON response with stock list, accuracy score, and analysis summary sent to Frontend.
6.  **Rendering**: Flutter renders the interactive table and charts.

## Analyst Criteria Breakdown

| Analyst | Key Metrics |
| :--- | :--- |
| **Andri Hakim** | Supply-demand, Net Profit >15% YoY, PER <15, PBV <2, DER <1, Energy/Mining/Digital, Volume > Avg. |
| **Hengky Adinata** | Smart Money Flow, Net Buy Foreign >Rp50M, ROE >17%, Cut Loss <10%. |
| **Warren Buffett** | ROE >15%, ROI >15%, D/E <0.5, EPS Growth >10%, Profit Margin > Industry Avg. |
| **MSCI** | Market Cap >Rp10T, Free Float >15%, ATVR >15%, ESG Compliance (No Weapons/Tobacco/Coal). |
| **BlackRock** | ROE >15%, FCF/Net Income >0.1, P/E <25, Economies of Scale. |

## Reverse Merger Indicator
*   **Logic**: Monitoring for "Tender Offer" rumors, "Change of Control", "Rights Issue (>300%)", "Asset Acquisition".
*   **Output**: Boolean (Yes/No) + Source Link.

## UX Design
*   **Theme**: Dark Soft Purple.
*   **Components**:
    *   Dropdown for Analyst Style.
    *   Interactive Data Table (Sortable).
    *   Forecasting Chart (price vs predicted).
