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