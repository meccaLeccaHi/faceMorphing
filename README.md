# faceMorphingTool

####R scripts for non-linear morphing/warping of faces for neuroscience/psychophysics experiments. 
Makes use of toolboxes intended for organizing, visualizing, and statistically exploring biomedical images.

These scripts make use of the following toolboxes:
## - Image registration:
**Advanced Normalization Tools (ANTs)** http://picsl.upenn.edu/software/ants/ / http://stnava.github.io/ANTs/
"ANTs computes high-dimensional mappings to capture the statistics of brain structure and function."
## - R interface for ANTs:
**ANTsR** http://stnava.github.io/ANTsR/

#### - set_my_path.R
- Defines appropriate directories, depending on whether running locally or on High Performance Computing cluster. 

#### - faceMorphBatch.R
Creates face-morph stimulus space for each frame of what will later be an animated movie with voice sounds.
1. Creates average face for all faces provided
2. Create hybrids of those original faces, to serve as "new identity" faces
3. Morph each new-identity face along the radial trajectory
4. Morph each new-identity face along the tangential trajectory

![Face-space example](https://cloud.githubusercontent.com/assets/15203083/21268802/d0cfbe2a-c375-11e6-8b99-2788bedb541b.png)
