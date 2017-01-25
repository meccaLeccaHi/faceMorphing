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
    
  # define output directories and filenames
  OUTPUT_DIR          <- file.path(MY_PATHS$FINAL,TAN_NAME,TRAJ_DIR,MORPHS$STEPS[M])
  dir.create(OUTPUT_DIR,recursive=TRUE,showWarnings=FALSE)  # create output directory, if none exists
  FILENAME_OUT        <- paste(OUTPUT_DIR,"/",TAN_NAME,MORPH_LEVL_OUT,TRAJ_DIR,"_",FNAME_STR,sep="")
  TEMP_FILE_OUT       <- paste(TEMP_DIR,"/temp",TAN_NAME,MORPH_LEVL_OUT,TRAJ_DIR,"_",FRAME_NUM_STR,CHANNEL,IMAGE_EXT,sep="")
  ants_transform(INPUT_FNAMES=FILENAME_MAT,OUTPUT_FNAMES=FILENAME_OUT,
                 ITERATIONS=ITERATIONS_LIST$TRAJ,TEMP_OUTPUT_NAMES=TEMP_FILE_OUT)
}
