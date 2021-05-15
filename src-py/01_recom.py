#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May 13 13:09:13 2021

@author: cbautistap
"""

import sys
import pandas as pd
import numpy as np
import scipy.sparse as sparse
from scipy.sparse.linalg import spsolve
import random
import pyreadr

from sklearn.preprocessing import MinMaxScaler

import implicit # The Cython library

# Load the data like we did before
raw_data = pyreadr.read_r('cache/training.Rds')

print(raw_data.keys()) # let's check what objects we got: there is only None
data = raw_data[None] # extract the pandas data frame for the only object available

#raw_data = raw_data.drop(raw_data.columns[1], axis=1)
#raw_data.columns = ['user', 'artist', 'plays']

# Drop NaN columns
data = data.dropna()
data = data.copy()
data.head()

# Create a numeric user_id and artist_id column
data['steamid'] = data['steamid'].astype("category")
data['appid'] = data['appid'].astype("int")
data['steamid'] = data['steamid'].cat.codes
#data['artist_id'] = data['artist'].cat.codes

# The implicit library expects data as a item-user matrix so we
# create two matricies, one for fitting the model (item-user) 
# and one for recommendations (user-item)
sparse_item_user = sparse.csr_matrix((data['playtime_forever'].astype(float), (data['appid'], data['steamid'])))
sparse_user_item = sparse.csr_matrix((data['playtime_forever'].astype(float), (data['appid'], data['steamid'])))

# Initialize the als model and fit it using the sparse item-user matrix
model = implicit.als.AlternatingLeastSquares(factors=20, regularization=0.1, iterations=20)

# Calculate the confidence by multiplying it by our alpha value.
alpha_val = 15
data_conf = (sparse_item_user * alpha_val).astype('double')

# Fit the model
model.fit(data_conf)


#---------------------
# FIND SIMILAR ITEMS
#---------------------

# Find the 10 most similar to Jay-Z
item_id = 147068 #Jay-Z
n_similar = 10

# Get the user and item vectors from our trained model
user_vecs = model.user_factors
item_vecs = model.item_factors

# Calculate the vector norms
item_norms = np.sqrt((item_vecs * item_vecs).sum(axis=1))

# Calculate the similarity score, grab the top N items and
# create a list of item-score tuples of most similar artists
scores = item_vecs.dot(item_vecs[item_id]) / item_norms
top_idx = np.argpartition(scores, -n_similar)[-n_similar:]
similar = sorted(zip(top_idx, scores[top_idx] / item_norms[item_id]), key=lambda x: -x[1])

# Print the names of our most similar artists
for item in similar:
    idx, score = item
    print data.artist.loc[data.artist_id == idx].iloc[0]


#------------------------------
# CREATE USER RECOMMENDATIONS
#------------------------------

def recommend(user_id, sparse_user_item, user_vecs, item_vecs, num_items=10):
    """The same recommendation function we used before"""

    user_interactions = sparse_user_item[user_id,:].toarray()

    user_interactions = user_interactions.reshape(-1) + 1
    user_interactions[user_interactions > 1] = 0

    rec_vector = user_vecs[user_id,:].dot(item_vecs.T).toarray()

    min_max = MinMaxScaler()
    rec_vector_scaled = min_max.fit_transform(rec_vector.reshape(-1,1))[:,0]
    recommend_vector = user_interactions * rec_vector_scaled

    item_idx = np.argsort(recommend_vector)[::-1][:num_items]

    artists = []
    scores = []

    for idx in item_idx:
        artists.append(data.artist.loc[data.artist_id == idx].iloc[0])
        scores.append(recommend_vector[idx])

    recommendations = pd.DataFrame({'artist': artists, 'score': scores})

    return recommendations

# Get the trained user and item vectors. We convert them to 
# csr matrices to work with our previous recommend function.
user_vecs = sparse.csr_matrix(model.user_factors)
item_vecs = sparse.csr_matrix(model.item_factors)

# Create recommendations for user with id 2025
user_id = 2025

recommendations = recommend(user_id, sparse_user_item, user_vecs, item_vecs)

print recommendations
