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
raw_data = pyreadr.read_r('cache/dta_train.Rds')

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

# Use implicit to get similar items.
similar = model.similar_items(item_id, n_similar)

# Print the names of our most similar artists
for item in similar:
    idx, score = item
    print data.artist.loc[data.artist_id == idx].iloc[0]

    
#------------------------------
# CREATE USER RECOMMENDATIONS
#------------------------------

# Create recommendations for user with id 2025
user_id = 2025

# Use the implicit recommender.
recommended = model.recommend(user_id, sparse_user_item)

artists = []
scores = []

# Get artist names from ids
for item in recommended:
    idx, score = item
    artists.append(data.artist.loc[data.artist_id == idx].iloc[0])
    scores.append(score)

# Create a dataframe of artist names and scores
recommendations = pd.DataFrame({'artist': artists, 'score': scores})

print recommendations
