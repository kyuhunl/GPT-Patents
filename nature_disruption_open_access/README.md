# Science and technology are becoming less disruptive over time

This document gives an overview of files included in the accompanying archive for replicating the analyses in "Science and technology are becoming less disruptive over time" by Michael Park, Erin Leahey, and Russell J. Funk, published in _Nature_.

# Data availability
Our project makes use of multiple different data sets. While some of these are publicly available, some are used under license from their respective publishers, and restrictions apply to their sharing. To facilitate replication of our findings, we have therefore made two versions of this archive, one of which includes only the publicly available data, and the other of which includes both the public and restricted access data. The former is freely available online; the latter will be provided upon request from the authors and approval from the respective data publisher. 

Both versions of the archive include all code necessary to replicate our analyses, for both the public and restricted access data.

## Public data sources
* Microsoft Academic Graph
* Patents View
* PubMed

## Restricted data sources
* American Physical Society corpus
* JSTOR corpus
* Web of Science

# Package versions

Our analyses used the following software libraries. For Python, a conda environment file is available in the `conda` directory, which will install the core packages and versions necessary to replicate our analysis. 

## Python (v3.10.6)
* pandas (v1.4.3)
* numpy (v1.23.1)
* jupyterlab (v3.4.4)
* matplotlib (v3.5.2)
* seaborn (v0.11.2)

## R (v4.2.1)
* ggplot2 (v3.3.6)
* ggrepel (v0.9.0)

## StataMP (v17.0)
* reghdfe (v5.7.3)

## Overview of files and folders

The following files and folders are included in the archive.

* `conda` is a folder that contains an environment file that will install the packages (and appropriate versions) necessary to replicate our analyses.
* `data` is a folder containing the replication data. Note that in the public access version of this archive, the restricted data files have been removed.
* `compute_shapley_values.ipynb` is a Jupyter notebook that will compute the Shapley values reported in our analysis on the relative contribution of field, author, and year effects. 
* `config.py` is a configuration file that can be used to set the working directory and other settings.
* `paper_analyses.ipynb` is a Jupyter notebook that will replicate our analyses for the paper (primarily Web of Science) data.
* `paper_analyses.R` is an R script that will replicate a small number of our analyses for the paper (primarily Web of Science) data.
* `patent_analyses.ipynb` is a Jupyter notebook that will replicate our analyses for the patent (primarily Patents View) data.
* `regression_adjustments.do` is a Stata .do file that runs the regressions used to adjust the CD index for publication, citation, and authorship practices.
* `regressions_analysis.do` is a Stata .do file that runs the main regression analyses reported in the paper.
* `regressions_authors_shapley_papers.do` is a Stata .do file that computes the input data for papers for the Jupyter notebook `compute_shapley_values.ipynb`.
* `regressions_authors_shapley_patents.do` is a Stata .do file that computes the input data for patents for the Jupyter notebook `compute_shapley_values.ipynb`.
* `results` is a folder for output from the Jupyter notebook, R, and Stata scripts.

# Contact

For questions, please contact Russell J. Funk, the corresponding author, at <rfunk@umn.edu>.