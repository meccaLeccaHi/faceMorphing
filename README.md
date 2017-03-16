# faceMorphingTool

#### R scripts for non-linear morphing/warping of faces for neuroscience/psychophysics experiments. 
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
An example animated face-space generated via face-morphing with this tool. 

![Face-space example](https://cloud.githubusercontent.com/assets/15203083/21275286/b24b5ede-c391-11e6-8ae9-a3a71f14ba87.gif)

Original faces provided, graciously, by Supasorn Suwajanakorn 
[[Web]](http://homes.cs.washington.edu/~supasorn/) 
[[Faces]](https://www.youtube.com/watch?v=86wXbwvmnWM) 
[[Paper]](http://grail.cs.washington.edu/projects/3DPersona/)  

**Created by Dr Adam Jones  
Department of Neurosurgery,  
University of Iowa,  
Iowa City IA, USA** 
