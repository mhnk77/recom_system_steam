#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May 14 14:04:02 2021

@author: cbautistap
"""
import pandas as pd
import pyreadr

from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.recommendation import ALS
from pyspark.sql import Row

# Load the data like we did before
raw_data = pyreadr.read_r('cache/dta_train.Rds')

print(raw_data.keys()) # let's check what objects we got: there is only None
data = raw_data[None]