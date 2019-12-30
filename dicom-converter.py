import cv2
import os
import pydicom
import numpy as np

inputdir = './ANGIO CT/'
outdir = './MANIX PNG/'
#os.mkdir(outdir)

test_list = [ f for f in  os.listdir(inputdir)]

for f in test_list:   # remove "[:10]" to convert all images 
    ds = pydicom.read_file(inputdir + f) # read dicom image
    img = ds.pixel_array # get image array
    shape = ds.pixel_array.shape
    image_2d = ds.pixel_array.astype(float)

    # Rescaling grey scale between 0-255
    image_2d_scaled = (np.maximum(image_2d,0) / image_2d.max()) * 255.0

    # Convert to uint
    image_2d_scaled = np.uint8(image_2d_scaled)
    cv2.imwrite(outdir + f.replace('.dcm','.png'),image_2d_scaled)