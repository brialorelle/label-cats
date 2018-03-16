from __future__ import division

import torch
import torchvision.models as models
import torch.nn as nn
import torchvision.transforms as transforms
import torch.nn.functional as F
from torch.autograd import Variable

from glob import glob
import os

import numpy as np
import pandas as pd
import json
import re

from PIL import Image
import base64

from embedding_labelconcept import *

# retrieve sketch paths
def list_files(path, ext='jpg'):
    result = [y for x in os.walk(path) for y in glob(os.path.join(x[0], '*.%s' % ext))]
    return result

def make_dataframe(ImageNames,Categories):    
    Y = pd.DataFrame([ImageNames,Categories])
    Y = Y.transpose()
    Y.columns = ['imagename','category']   
    return Y

def normalize(X):
    X = X - X.mean(0)
    X = X / np.maximum(X.std(0), 1e-5)
    return X

def preprocess_features(Features, Y):
    _Y = Y.sort_values(['imagename','category'])
    inds = np.array(_Y.index)
    _Features = normalize(Features[inds])
    _Y = _Y.reset_index(drop=True) # reset pandas dataframe index
    return _Features, _Y

def save_features(Features, Y, layer_num):
    if not os.path.exists('./features'):
        os.makedirs('./features')
    layers = ['P1','P2','P3','P4','P5','FC6','FC7']
    np.save('./features/FEATURES_{}.npy'.format(layers[int(layer_num)]), Features)
    Y.to_csv('./features/METADATA.csv')
    return layers[int(layer_num)]


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', type=str, help='full path to images', default='../images')
    parser.add_argument('--layer_ind', help='fc6 = 5, fc7 = 6', default=6)
    args = parser.parse_args()
    
    ## get list of all image paths
    image_paths = sorted(list_files(args.data))
    print('Length of image_paths before filtering: {}'.format(len(image_paths)))
      
    
    ## extract features
    layers = ['P1','P2','P3','P4','P5','FC6','FC7']
    extractor = FeatureExtractor(image_paths,layer=args.layer_ind)
    Features, ImageNames, Categories = extractor.extract_feature_matrix()
        
    # organize metadata into dataframe
    Y = make_dataframe(ImageNames,Categories)
    _Features, _Y = preprocess_features(Features, Y)
    
    # save features
    layer = save_features(_Features, _Y, args.layer_ind)
       