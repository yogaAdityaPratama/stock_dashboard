import streamlit as st
import numpy as np
import pandas as pd
import plotly.express as px
import yfinance as yf
from datetime import date



bg_img_1 = """
    <style>
        [data-testid='stAppViewContainer']{
            background-image: url(https://wallpapers.com/images/hd/bearish-stock-market-h7j5141cg4jjmdwa.jpg);
            background-size: cover;
        }
        [data-testid='stSidebar']{
            background-image: url(https://wallpapers.com/images/hd/beach-rocks-portrait-agsz4jj940o7a5ql.jpg);
            background-size: cover;
        }
        [data-testid="stHeader"]{
            background-color: rgba(0, 0, 0, 0);
        }
        h1{
            color: #000000;
            text-align: Center;
        }
        h3{
            color: #000000;
        }

        .stMarkdown p {
            color: #000000;
        }

        .css-k3w14i{
            color: #000000;
        }
        .st-e5 {
            background: rgba(0, 0, 0, .3);
        }
        .element {
        background-color: rgba(0, 0, 0, 0.4);
        }
        </>
    """

st.markdown(bg_img_1, unsafe_allow_html=True)


st.title('Stock Dashboard')
st.sidebar.header('Menu')
ticker = st.sidebar.text_input('Ticker', value='TSLA')
start_date = st.sidebar.date_input('Start Date', value=date(2022, 4, 14))
end_date = st.sidebar.date_input('End date', value=date(2023, 4, 14))


data = yf.download(ticker, start=start_date, end=end_date)
fig = px.line(data, x = data.index, y = 'Adj Close', title= ticker)
st.plotly_chart(fig)

pricing_data, fundamental_data, news = st.tabs(['Pricing Data', 'Fundamental Data', 'Top 10 News'])


with pricing_data:
    st.header('Price Movements')
    data2 = data
    data2['% Change'] = data['Adj Close'] / data['Adj Close'].shift(1)-1
    st.write(data2)
    annual_return = data2['% Change'].mean()*252*100
    st.write(f'Annual Return is {annual_return:.4f}','%')
    stdev = np.std(data2['% Change'])*np.sqrt(252)
    st.write(f'Standart Deviation is {stdev*100:.4f}','%')
    st.write(f'Risk Adj. Return is {annual_return/(stdev*100):4f}')

from alpha_vantage.fundamentaldata import FundamentalData
with fundamental_data:
    st.write('Fundamental')
    key = '4KOEYD09PLCLULLP'
    fd = FundamentalData(key, output_format = 'pandas')
    st.subheader('Balance Sheet')
    balance_sheet = fd.get_balance_sheet_annual(ticker)[0]
    bs = balance_sheet.T[2:]
    bs.colums = list(balance_sheet.T.iloc[0])
    st.write(bs)
    st.subheader('Income Statement')
    income_statement = fd.get_balance_sheet_annual(ticker)[0]
    is1 = income_statement.T[2:]
    is1.colums = list(income_statement.T.iloc[0])
    st.write(is1)
    st.subheader('Cash Flow Statement')
    cash_flow = fd.get_balance_sheet_annual(ticker)[0]
    cf = cash_flow.T[2:]
    cf.colums = list(cash_flow.T.iloc[0])
    st.write(cf)


from stocknews import StockNews
with news:
    st.header(f'News of {ticker}')
    sn = StockNews(ticker, save_news=False)
    df_news = sn.read_rss()
    for i in range(10):
        st.subheader(f'News {i+1}')
        st.write(df_news['published'][i])
        st.write(df_news['title'][i])
        st.write(df_news['summary'][i])
        title_sentiment = df_news['sentiment_title'][i]
        st.write(f'Title Sentiment {title_sentiment}')
        news_sentiment = df_news['sentiment_summary'][i]
        st.write(f'News Sentiment {news_sentiment}')