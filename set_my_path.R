set_my_path <- function () 
{
  if(Sys.info()[[4]]=="lab-All") # PC option
    
  {
    
    my_paths <- list(
      PROJ                  = "/home/lab/Cloud2/movies/human/LazerMorph/",
      INPUT                 = "/home/lab/Cloud2/movies/human/faces/raw_frames",
      FINAL                 = "/home/lab/Cloud2/movies/human/faces/fin_frames/",
      ANTS                  = "/usr/local/ants/antsbin/bin",
      ANTSFACE              = "/home/lab/ANTs/bin/bin/Template/Faces",
      TURK                  = "/home/lab/Cloud2/movies/human/turk/results/",
      OUTPUT                = "/tmp/")
    
    return(my_paths)
    
  }
  
  else if (length(grep("neon",Sys.info()[[4]]))>0) # HPC cluster option
    
  {
    
    my_paths <- list(
      PROJ                  = "/Users/apjons/",
      INPUT                 = "/Users/apjons/raw_frames",
      FINAL                 = "/Users/apjons/fin_frames/",
      ANTS                  = "/Users/apjons/ANTs/bin/bin",
      ANTSFACE              = "/Users/apjons/ANTs/bin/bin/Template/Faces",
      TURK                  = "/Users/apjons/turk_results/",
      OUTPUT                = "/tmp/")
    
    return(my_paths)
    
  }
  
}
