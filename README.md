# GlobalForestChange_Python
Using Google Earth Engine to evaluate annual forest loss in sub-saharan Africa
**Quick summary: ** This is a Python-based analysis of the Hassen Forest Global Watch Data using Google Earth Engine. The goal is to access annual forest loss within each LSLA region. 

Data source:
Hansen, M. C., P. V. Potapov, R. Moore, M. Hancher, S. A. Turubanova, A. Tyukavina, D. Thau, S. V. Stehman, S. J. Goetz, T. R. Loveland, A. Kommareddy, A. Egorov, L. Chini, C. O. Justice, and J. R. G. Townshend. 2013. "High-Resolution Global Maps of 21st-Century Forest Cover Change." Science 342 (15 November): 850-53. 10.1126/science.1244693 Data available on-line at: https://glad.earthengine.app/view/global-forest-change.


Repository structure:

Javascript: used to download data from Google earth engine. //
JupyterNotebook: stores the python codes in jupyter notebook.//
post-processing_code: post-process data files downloaded from Google earth engine in R to summarize treecover2000 and lossyear data at the district level.
