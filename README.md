# faceMorphingTool

#### R scripts for un-supervised morphing of images 
These scripts make use of the following toolboxes intended for organizing, visualizing, and statistically exploring biomedical images:

## - Image registration:
**Advanced Normalization Tools (ANTs)** http://picsl.upenn.edu/software/ants/ **/** http://stnava.github.io/ANTs/  
"ANTs computes high-dimensional mappings to capture the statistics of brain structure and function."
## - R interface:
**ANTsR** http://stnava.github.io/ANTsR/  
_[requires **ITKR** https://github.com/stnava/ITKR ]_  
"A package providing ANTs features in R as well as imaging-specific data representations, spatially regularized dimensionality reduction and segmentation tools."
##
#### set_my_path.R
Defines appropriate directories, depending on whether running locally or on High Performance Computing cluster. 

#### faceMorphBatch.R
Creates face-morph stimulus space for each frame of what will later be an animated movie with voice sounds.  
1.  Creates average face for all faces provided  
2. Create hybrids of those original faces, to serve as "new identity" faces  
3. Morph each new-identity face along the radial trajectory  
4. Morph each new-identity face along the tangential trajectory 
##

### Morphing animated faces 
An example of an unsupervised face morph created with this tool. 

![Face-morph example](http://i.imgur.com/4vh8XxK.png)

Original faces provided, graciously, by Supasorn Suwajanakorn 
[[Web]](http://homes.cs.washington.edu/~supasorn/) 

**Created by Dr Adam Jones  
Department of Neurosurgery,  
University of Iowa,  
Iowa City IA, USA** 
