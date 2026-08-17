"""
forecast.py

Forecasts monthly unit sales for a single product using a
3-month moving average, then evaluates that forecast against actual
2026 Q1 sales with mean absolute error (MAE).

Usage:
    python forecast.py

Requires:
    - CSV files (products, product_variants, orders, order_items)
      present in the folder defined by PATH

Method:
    For each month in test_months, the forecast is the mean of
    quantity_sold over the 3 preceding months. Error is the absolute
    difference between forecast and actual sales for that month.
"""

import pandas as pd
import numpy as np

PATH = './1-lh_nautical_csv/'

# load the data
products = pd.read_csv(PATH + 'products.csv')
variants = pd.read_csv(PATH + 'product_variants.csv')
orders = pd.read_csv(PATH + 'orders.csv')
items = pd.read_csv(PATH + 'order_items.csv')

# set the created_at column to date type
orders['created_at'] = pd.to_datetime(orders['created_at'])

# filter to only the desired item "Bússola de Bordo 702"
products = products[products['name'] == "Bússola de Bordo 702"]
variants = variants[variants['product_id'].isin(products['id'])]
items = items[items['product_variant_id'].isin(variants['id'])]
orders = orders[orders['id'].isin(items['order_id'])]

# geting only paid or confirmed orders
orders = orders[orders['status'].isin(['paid', 'confirmed'])]

# joining orders and items
df = items.copy()
df = df.merge(orders[['id', 'created_at']], left_on='order_id', right_on='id', suffixes=('','_order'))

# make a dataframe with only the monthly sales for targeted product
monthly_sales = df.groupby(df['created_at'].dt.to_period('M'))['quantity'].sum().reset_index()
monthly_sales.columns = ['month', 'quantity_sold']
monthly_sales['month'] = pd.PeriodIndex(monthly_sales['month'], freq='M')
monthly_sales = monthly_sales.set_index('month')['quantity_sold'].sort_index() 

# now the moving average for the 2026 Q1 predictions
test_months = pd.period_range('2026-01', '2026-03', freq='M')
 
results = []
for m in test_months:
    prev_months = pd.period_range(m - 3, m - 1, freq='M')
    prev_values = monthly_sales.reindex(prev_months) 
    forecast = prev_values.mean()     
    actual = monthly_sales[m] if m in monthly_sales.index else np.nan
    error = abs(actual - forecast) if pd.notna(actual) and pd.notna(forecast) else np.nan
    results.append({
        'month': str(m),
        'forecast': round(forecast, 2) if pd.notna(forecast) else np.nan,
        'actual': actual,
        'abs_error': round(error, 2) if pd.notna(error) else np.nan
    })

result_df = pd.DataFrame(results)
print(result_df)

mae = result_df['abs_error'].sum()/3
print("MAE:", round(mae, 2))

print(f'Previsao de total de vendas para 2026 Q1: {int(result_df['forecast'].sum())}')






