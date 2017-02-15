def split_im( RGB_im_nm, output_dir, filename_r, filename_b, filename_g ):
   "This reads an image, splits it into RGB channels, and saves each as image in the current directory"
   import cv2
   img = cv2.imread(RGB_im_nm)
   b,g,r = cv2.split(img)
   cv2.imwrite(output_dir+"/"+filename_r,r)
   cv2.imwrite(output_dir+"/"+filename_b,b)
   cv2.imwrite(output_dir+"/"+filename_g,g)

#split_im( "/home/lab/Cloud2/movies/human/faces/fin_frames/Ave/Average_200RGB.tiff",
#         "/home/lab/Desktop/","red.png","blue.png","green.png")
         
         
#import os
#os.chdir("/home/lab/Cloud2/movies/human/faces/face_scripts/");
#from split_im import split_im
#split_im("/home/lab/Cloud2/movies/human/faces/fin_frames/Ave/Average_200RGB.tiff",
#"/tmp/tempDir17433/","temp200R.tiff","temp200G.tiff","temp200B.tiff")