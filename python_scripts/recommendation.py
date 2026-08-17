"""
recommendation.py

Generates product recommendations using item-based collaborative
filtering. Builds a customer x product purchase matrix (binary:
purchased or not) from paid/confirmed orders, computes cosine
similarity between products based on shared customers, and ranks
the most similar products to a given reference product.

Usage:
    python recommendation.py

Requires:
    - CSV files (products, product_variants, orders, order_items)
      present in the folder defined by PATH
"""

from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd

PATH = './1-lh_nautical_csv/'

def ranking_sim(product_id, product_df, sim_df, top_n=10):
    ranking = (
        sim_df[product_id]
        .drop(product_id) # remove the ref product
        .sort_values(ascending=False)
        .head(top_n) # get only the top n values
        .reset_index()
    )
    ranking.columns = ['product_id', 'similarity']
    ranking = ranking.merge(product_df[['id', 'name']], left_on='product_id', right_on='id')  # get product names  
    return ranking[['product_id', 'name', 'similarity']]


# load the data
products = pd.read_csv(PATH + 'products.csv')
variants = pd.read_csv(PATH + 'product_variants.csv')
orders = pd.read_csv(PATH + 'orders.csv')
items = pd.read_csv(PATH + 'order_items.csv')

# get only the valid orders
orders = orders[orders['status'].isin(['paid', 'confirmed'])]

# cross information needed to get customer_id and product_id in the df
df = items.copy()
df = df.merge(orders[['id', 'customer_id']], left_on='order_id', right_on='id', suffixes=('', '_order'))
df = df.merge(variants[['id', 'product_id']], left_on='product_variant_id', right_on='id', suffixes=('', '_variant'))
# df = df.merge(products[['id']], left_on='product_id', right_on='id', suffixes=('', '_product'))

df = df[['id', 'customer_id', 'product_id']]

print(df.head())

# generate customer x product matrix
matrix = pd.crosstab(df['customer_id'], df['product_id'])
matrix = (matrix > 0).astype(int)

print(matrix)

# generate product similarity matrix using cosine similarity
sim = cosine_similarity(matrix.T)
sim_df = pd.DataFrame(sim, index=matrix.columns, columns=matrix.columns)

print(sim_df.head())

# get reference product id
ref_prod = products['id'][products['name'] == 'Motor de Popa 1949'].tolist()[0]

# generate ranking
ranking = ranking_sim(ref_prod, products, sim_df)

print(ranking)
