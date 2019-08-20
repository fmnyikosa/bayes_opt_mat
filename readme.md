# BayesOptMat: Bayesian Optimization for MATLAB

This a Gaussian process optimization using modified [GPML v4.0](http://www.gaussianprocess.org/gpml/code/matlab/doc/). Performs Bayesian global optimization with different acquisition functions. Among other functionalities, it is possible to use BayesOptMat to optimize physical experiments and tune the parameters of Machine Learning algorithms. This code has the following additional features:

- Bayesian Optimization diagnostic and logging tools to test optimization speed and efficiency; 
- Visualization and animation utilities for low dimensional data and functions, and for performance metrics' graphs. 

## Setup

The root folder contains the file `start.m` which adds the relevent dependencies to the current path. Make sure you run this file before executing anything. 

The root folder also contains demo files for how to use the various features, and the methods have comments about their inputs and outputs.   