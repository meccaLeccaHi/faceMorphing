faceMorphBatch <- function(STARTFRAME, STOPFRAME) 
{ # last modified
  # apj
  # 12/20/2016
  #
  # 1. Create average face
  #
  # 2. Create hybrids of original faces, to serve as full-identity faces
  #
  # 3. Morph each full-identity face along the radial trajectory
  #
  # 4. Morph each full-identity face along the tangential trajectory
  
  # all_pkgs  <- c("Rcpp","magrittr","dplyr","abind","bitops","BGLR","caret","cluster","d3Network","devtools",
  #                "DMwR", "EBImage", "e1071","extremevalues","fastICA","fpc","ggplot2","glasso","glmnet","grid",
  #                "gsubfn","igraph","imager","knitr","lme4","magic","MASS","methods","mFilter","misc3d","moments",
  #                "pixmap","png","pracma","psych","purrr","randomForest","rgl","rmarkdown","robust","robustbase",
  #                "RRedsvd","shiny","signal","slidify","sna","squash","testthat","tools","visreg","wmtsa")
  # install.packages(all_pkgs,dependencies=TRUE)
  
  # local v. cluster
  if(Sys.info()[[4]]=="lab-All") 
  {
    source('~/Cloud2/movies/human/faces/face_scripts/shifter.R') # load custom function
  } else {
    source("~/R/shifter.R") # load custom function
  }

  traj_dir_plot <- function()
  { # function to copy and convert (RGB>gray) input images in temp dir
    
    for (J in 1:2) # loop through filenames in list
    { # split image into channels and write each to new image file
      BAR               <- unname(mapply(gsub,pattern=COLOR_CHANS,replacement=CHANNEL,x=FNAMES[J]))
      TEMP_IMG_LIST     <- EBImage::getFrames(EBImage::readImage(FILELIST[J]))
      TEMP_FNAMES       <- paste(TEMP_DIR,"temp",BAR,sep="")
      if (!all(file.exists(TEMP_FNAMES))) 
      { # step through color channels and save
        walk2(TEMP_IMG_LIST,TEMP_FNAMES,EBImage::writeImage,bits.per.sample=8L,compression="none")  
      }
    }
    
    # create char array for input .csv
    FILELIST            <- paste(TEMP_DIR,"temp",TAN_NAME,MORPH_LEVL_IN,TRAJ_DIR,"_",FRAME_NUM_STR,sep="") # create file-list
    FILENAME_MAT        <- outer(FILELIST, paste(CHANNEL,IMAGE_EXT,',',sep=""),sep="",paste)
    
    # deine output directories and filenames
    OUTPUT_DIR          <- file.path(MY_PATHS$FINAL,TAN_NAME,TRAJ_DIR,MORPHS$STEPS[M])
    dir.create(OUTPUT_DIR,recursive=TRUE,showWarnings=FALSE)  # create output directory, if none exists
    FILENAME_OUT        <- paste(OUTPUT_DIR,"/",TAN_NAME,MORPH_LEVL_OUT,TRAJ_DIR,"_",FNAME_STR,sep="")
    TEMP_FILE_OUT       <- paste(TEMP_DIR,"/temp",TAN_NAME,MORPH_LEVL_OUT,TRAJ_DIR,"_",FRAME_NUM_STR,CHANNEL,IMAGE_EXT,sep="")
    ants_transform(INPUT_FNAMES=FILENAME_MAT,OUTPUT_FNAMES=FILENAME_OUT,
                   ITERATIONS=ITERATIONS_LIST$TRAJ,TEMP_OUTPUT_NAMES=TEMP_FILE_OUT)
  }
  
  ants_transform <- function(INPUT_FNAMES,OUTPUT_FNAMES,ITERATIONS,TEMP_OUTPUT_NAMES) 
  { # function to read character arrays listing files to be read/written by ANTs for morphing process
    # Usage:
    # ants_transform(INPUT_FNAMES,OUTPUT_FNAMES,ITERATIONS,TEMP_OUTPUT_NAMES=TEMP_FILE_OUT)
    
    # create temporary workspace, if it doesn't exist
    if (!exists("TEMP_DIR")) 
    { 
      TEMP_DIR          <- paste(MY_PATHS$OUTPUT,"tempDir",sample(1:100000,1),'/',sep="")
      dir.create(TEMP_DIR)
    }
    
    # create temporary csv file containing filenames for ANTs function
    write.table(INPUT_FNAMES,paste(TEMP_DIR,ANTS_CSV_FNAME,sep=""),row.names=FALSE,col.names=FALSE,quote=FALSE) 
    
    # load previous frame as template, if it exists
    TEMPLATE_FNAME      <- gsub(FRAME_NUM_STR,sprintf("%03d",I-1),OUTPUT_FNAMES[1])
    if (FALSE) #(file.exists(TEMPLATE_FNAME)) 
    {
      # for shame...
      system(paste("matlab -nodisplay -nojvm -r 'addpath ", MY_PATHS$PROJ, "; colChanSplit ", TEMPLATE_FNAME, " ", TEMP_DIR, "; exit;'",sep=""))
      
      # TEMP_IMG_LIST     <- EBImage::getFrames(EBImage::readImage(TEMPLATE_FNAME))
      TEMP_FNAMES       <- paste(TEMP_DIR,sprintf("temp%03d",I-1),CHANNEL,IMAGE_EXT,sep="")
      # walk2(TEMP_IMG_LIST,TEMP_FNAMES,EBImage::writeImage,quality=10,bits.per.sample=8L,compression="none") 
      
      # TEMP_IMG_LIST     <- EBImage::getFrames(EBImage::readImage(TEMPLATE_FNAME))
      # TEMP_FNAMES       <- paste(TEMP_DIR,sprintf("temp%03d",I-1),CHANNEL,IMAGE_EXT,sep="")
      # walk2(TEMP_IMG_LIST,TEMP_FNAMES,writeTIFF,bits.per.sample=8L,compression="none")  # step through color channels and save
      
      # lapply(paste("convert ",TEMPLATE_FNAME,
      #                        " -channel ",shifter(CHAN_NAMES,n=1)," -channel ",shifter(CHAN_NAMES,n=2),
      #                        " -evaluate set 0 +channel ",
      #                        TEMP_DIR,sprintf("temp%03d",I-1),CHANNEL,IMAGE_EXT,sep=""),system) #  -type Grayscale
      TEMPLATE_STR      <- paste("-z",TEMP_FNAMES,collapse=" ") # char array listing template images
    } else {
      TEMPLATE_STR      <- ""
    }
    
    # call ANTs function from shell
    system(paste("export ANTSPATH=",MY_PATHS$ANTS,'\n', 
                 MY_PATHS$ANTS,"/antsMultivariateTemplateConstruction2.sh",
                 " -o ",TEMP_DIR,
                 " -i ",ITERATIONS,
                 " -c ",PARALLEL,
                 " -k ",length(CHANNEL),
                 " -d 2 -r 1 -g 0.25 -f 16x12x8x4x2x1 -s 4x4x4x2x1x0 -q 100x100x100x70x50x10",
                 " -n 1 -m CC -t BSplineSyN[0.1,75,0] ",
                 TEMPLATE_STR," ",
                 TEMP_DIR,ANTS_CSV_FNAME,sep=""))
    
    # read nifti file output, and adjust the level of each input channel
    TEMP_IM      <- EBImage::rgbImage(oro.nifti::readNIfTI(paste(TEMP_DIR,"template0.nii.gz",sep=""))*NORM_VALUE[1],
                                    oro.nifti::readNIfTI(paste(TEMP_DIR,"template1.nii.gz",sep=""))*NORM_VALUE[2],
                                     oro.nifti::readNIfTI(paste(TEMP_DIR,"template2.nii.gz",sep=""))*NORM_VALUE[3])

    # IM_OUT        <- EBImage::flop(EBImage::transpose(TEMP_IM/max(TEMP_IM)))

    # normalize each channel to one
    TEMP_IM      <- TEMP_IM/max(TEMP_IM)
    
    # change orientation for saving
    IM_OUT       <- EBImage::flop(EBImage::transpose(TEMP_IM))
    
    # save output to RGB image(s)
    walk2(list(IM_OUT),OUTPUT_FNAMES,writeTIFF,bits.per.sample=8L) # ,reduce=TRUE
    
    # save temporary copy of image files for next loop iterations to use
    TEMP_IMG_LIST     <- EBImage::getFrames(IM_OUT)
    # TEMP_IMG_LIST     <- lapply(TEMP_IMG_LIST,EBImage::transpose)
    
    if(!missing(TEMP_OUTPUT_NAMES)) # if output names exist
    { 
      # # rotate image, if necessary
      # TEMP_DIMS         <- dim(TEMP_IMG_LIST[[1]])
      # if(TEMP_DIMS[1]>TEMP_DIMS[2])
      # {TEMP_IMG_LIST     <- lapply(TEMP_IMG_LIST,EBImage::transpose)}
  
      # step through color channels and save each to file
      walk2(TEMP_IMG_LIST,TEMP_OUTPUT_NAMES,writeTIFF,bits.per.sample=8L)
    }
    
    # EBImage::image(oro.nifti::readNIfTI('/tmp/tempDir49992/template2Piers_002B17WarpedToTemplate.nii.gz'))

    # delete temporary workspace
    unlink(TEMP_DIR,force=TRUE)
  }
  
  ####################################################################################################################
  
  ## INSTALL PACKAGES
  # check if CRAN packages are installed, if not then install 
  necc_pkgs   <- c("Rcpp","EBImage","purrr","magrittr","tiff")
  if (length(setdiff(necc_pkgs, rownames(installed.packages()))) > 0) 
  { 
    install.packages(setdiff(necc_pkgs, rownames(installed.packages())),dependencies=TRUE)  
  }
  
  # check if git packages are installed, if not then install
  ants_pkgs   <- c("ITKR","ANTsR")
  if (length(setdiff(necc_pkgs, rownames(installed.packages()))) > 0) 
  { 
    library(devtools) # need devtools to install packages
    install_github("stnava/ITKR")
    install_github("stnava/ANTsR")
  }
  
  # load both sets of packages
  #pkgs <- c("ANTsR","devtools","stringi","grid","oro.nifti","devtools","raster","tiff","purrr","squash","EBImage")
  lapply(c(necc_pkgs,ants_pkgs),library,character.only=TRUE)
  
  ## DEFINE PATHS
  # define path depending on local v. cluster
  if(Sys.info()[[4]]=="lab-All") 
  {
    source("~/Cloud2/movies/human/faces/face_scripts/set_my_path.R") # load custom function
    source('~/Cloud2/movies/human/faces/face_scripts/shifter.R')
    IMAGE_EXT               <- ".tiff"
  } else {
    source("~/R/set_my_path.R") # load custom function
    source("~/R/shifter.R")
    IMAGE_EXT               <- ".tiff" # ".png"
  }
  MY_PATHS                  <- set_my_path() 
  
  ## DEFINE PROCESSING PARAMETERS
  FUNCTION_TOGGLES          <- list("AVE"=TRUE,"HYB"=TRUE,"TRAJ"=TRUE) # list of components to complete
  PARALLEL                  <- 0  # parallel processing toggle (0='no',1='yes')
  ITERATIONS_LIST           <- list("AVE"=1,"HYB"=1,"TRAJ"=1) # iterations of the template construction
  TRAJ_DIR_LIST             <- c("rad","tan") # trajectory name strings
  COLOR_CHANS               <- "RGB" # color abbreviations
  CHAN_NAMES                <- c("Red", "Green", "Blue") # color channel name strings
  CHANNEL                   <- unlist(strsplit(COLOR_CHANS,"")) # list of color abbreviations
  NORM_VALUE                <- c(0.89,0.58,0.50) # brightness of color channels (rel. to 1)
  ANTS_CSV_FNAME            <- "inputFiles.csv" # file name string
  
  # create list defining morph levels
  MORPHS                    <- list("LEVELS"            = seq(100,0,-25),
                                    "INPUT1"             = c(100,0,50),
                                    "INPUT2"             = c(0,50,100),
                                    "HYBRID"             = 50)
  MORPHS$STEPS              <- colMeans(rbind(MORPHS$INPUT1,MORPHS$INPUT2))
  MORPHS$STRS               <- sprintf("%03d",MORPHS$LEVELS)
  
  # define faces to use for input to average face
  FACES                     <- c("Arnold","Barney","Daniel","Hillary","Ian","Piers","Shinzo","Tom")
  # HYBRID_SELECTION           <- ("Hillary-Shinzo" "Daniel-Hillary" "Ian-Tom"\
  # "Barney-Daniel" "Piers-Tom" "Daniel-Shinzo" "Arnold-Barney" "Ian-Piers")
  
  # load file defining face order around face-space perimeter (tangential morphs axes), based on MDS analysis of turk responses
  FACEORDER_FILE            <- paste(MY_PATHS$TURK,"proj2/reordered_nameList.csv",sep="")
  TANG_SELECTION            <- unlist(lapply(read.csv(FACEORDER_FILE,header=FALSE), as.character))
  
  # frame loop
  for (I in STARTFRAME:STOPFRAME) 
  { # define current frame
    FRAME_NUM_STR           <- sprintf("%03d",I)
    FNAME_STR               <- paste(FRAME_NUM_STR,COLOR_CHANS,IMAGE_EXT,sep="")
    
    ########################################################################################################################
    ## create average face for current frame
    ########################################################################################################################
    
    if (FUNCTION_TOGGLES$AVE)  
    { # create char array for input .csv
      INPUT_FNAMES          <- paste(MY_PATHS$INPUT,"/",FACES,"_",FRAME_NUM_STR,sep="") # create file-list
      FILENAME_MAT          <- outer(INPUT_FNAMES, paste(CHANNEL,IMAGE_EXT,',',sep=""),sep="",paste)
      FILENAME_OUT          <- paste(MY_PATHS$FINAL,"Ave/","Average_",FNAME_STR,sep="")
      
      # create output directory, if none exists
      dir.create(paste(MY_PATHS$FINAL,"Ave",sep="/"),showWarnings=FALSE)  
      
      # perform morphing process
      ants_transform(INPUT_FNAMES=FILENAME_MAT,OUTPUT_FNAMES=FILENAME_OUT,ITERATIONS=ITERATIONS_LIST$AVE)
    }
    
    ########################################################################################################################
    ## hybrid loop
    ########################################################################################################################
    
    if (FUNCTION_TOGGLES$HYB)  
    { # face loop
      for (II in seq_along(TANG_SELECTION)) 
      { # define inputs
        TEMP_NAME_PAIR      <- unlist(strsplit(gsub('([[:upper:]])',' \\1',TANG_SELECTION[II])," "))[2:3]
        
        # create char array for input .csv
        FILELIST            <- paste(MY_PATHS$INPUT,"/",unlist(TEMP_NAME_PAIR),"_",FRAME_NUM_STR,sep="") # create file-list
        FILENAME_MAT        <- outer(FILELIST, paste(CHANNEL,IMAGE_EXT,',',sep=""),sep="",paste)
        FOO                 <- c(TANG_SELECTION[II],shifter(TANG_SELECTION,n=1)[II])
        BAR                 <- file.path(MY_PATHS$FINAL,FOO,TRAJ_DIR_LIST,MORPHS$STRS[1])
        walk(BAR,dir.create,recursive=TRUE,showWarnings=FALSE)  # create output directory, if none exists
        FILENAME_OUT        <- paste(BAR,"/",FOO,MORPHS$STRS[1],TRAJ_DIR_LIST,"_",FNAME_STR,sep="")
        
        # perform morphing process
        ants_transform(INPUT_FNAMES=FILENAME_MAT,OUTPUT_FNAMES=FILENAME_OUT,ITERATIONS=ITERATIONS_LIST$HYB)
      }
    }
    
    ########################################################################################################################
    ## trajectory loop: RADIAL & TANGENTIAL
    ########################################################################################################################
    
    if (FUNCTION_TOGGLES$TRAJ)  
    { # face loop
      for (II in seq_along(TANG_SELECTION)) 
      { 
        TAN_NAME              <- TANG_SELECTION[II]
        TANG_PARTNER          <- shifter(TANG_SELECTION,n=1)[II]
        
        ## create temporary image file directory
        TEMP_DIR              <- paste(MY_PATHS$OUTPUT,"tempDir",sample(1:100000,1),'/',sep="")
        dir.create(TEMP_DIR)
        
        ########################################################################################################################
        ## create each morph trajectory (of 2) for each individual (of 8)
        ########################################################################################################################
        
        # loop through morph steps
        for (M in seq_along(MORPHS$STEPS)) 
        { # define morph-levels
          MORPH_IN_RAW        <- c(MORPHS$INPUT1[M],MORPHS$INPUT2[M])
          MORPH_LEVL_IN       <- sprintf("%03d",MORPH_IN_RAW)
          MORPH_LEVL_OUT      <- sprintf("%03d",round(mean(c(MORPHS$INPUT1[M],MORPHS$INPUT2[M]))))
          
          # copy and convert (RGB>gray) input images in temp dir
          TRAJ_DIR            <- TRAJ_DIR_LIST[1]
          FILEPATHS           <- paste(MY_PATHS$FINAL,TAN_NAME,TRAJ_DIR,MORPH_IN_RAW,sep="/") # create file-list
          
          FNAMES              <- paste(TAN_NAME,MORPH_LEVL_IN,TRAJ_DIR,"_",FNAME_STR,sep="") # create file-list
          FILELIST            <- paste(FILEPATHS,FNAMES,sep="/")
          if (any(grep("000",MORPH_LEVL_IN))) 
          { 
            AVEFILE           <- paste("Average_",FNAME_STR,sep="")
            AVEFILEPATH       <- paste(MY_PATHS$FINAL,"Ave/",AVEFILE,sep="") # create file-list
            FILELIST[grep("000",MORPH_LEVL_IN)]       <- AVEFILEPATH
          }
          traj_dir_plot()
          
          # copy and convert (RGB>gray) input images in temp dir
          TRAJ_DIR            <- TRAJ_DIR_LIST[2]
          FILEPATHS           <- paste(MY_PATHS$FINAL,TAN_NAME,TRAJ_DIR,MORPH_IN_RAW,sep="/") # create file-list
          
          FNAMES              <- paste(TAN_NAME,MORPH_LEVL_IN,TRAJ_DIR,"_",FNAME_STR,sep="") # create file-list
          FILELIST            <- paste(FILEPATHS,FNAMES,sep="/")
          if (any(grep("000",MORPH_LEVL_IN))) 
          { 
            AVEFILE           <- paste("Average_",FNAME_STR,sep="")
            FILEPATH          <- paste(MY_PATHS$FINAL,TANG_PARTNER,TRAJ_DIR,"100",sep="/") # create file-list
            FNAME             <- paste(TANG_PARTNER,"100",TRAJ_DIR,"_",FNAME_STR,sep="") # create file-list
            FILELIST[grep("000",MORPH_LEVL_IN)]       <- paste(FILEPATH,FNAME,sep="/")
          }
          traj_dir_plot()
          
        } # end MORPHS
        
        unlink(TEMP_DIR,recursive=TRUE,force=TRUE)
        
      } # end FUNCTION_TOGGLES
      
    } # end face loop
    
  } # frame loop end
  
} # end FUNCTION

