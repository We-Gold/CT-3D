import pydicom as dicom
import PIL 
import pandas as pd
import matplotlib.pyplot as plt

folder_path = "./ANGIO CT/"

image_path = folder_path+'IM-0001-0001.dcm'
ds = dicom.dcmread(image_path)
plt.imshow( ds.pixel_array)

plt.show()