#######################################################################################
## Instructions for using Automatic algorithm for estimating effective contact angle ##
#######################################################################################

1) Obtain the tomograms, reconstruct images and load them into Avizo


2) Extract a subvolume around the region where you want to measure the angle (it is advised to choose a single ganglion, and not to choose a region which is too big, otherwise the whole process will be slower)


3) Filter data and apply the best segmentation you are able to :-)

Options:
- It is advised to use the crop editor and set minimum coordinate to (0, 0, 0) and voxel size 1x1x1


4) Extract the three phase contact line from segmented data, using Avizo function "label interfaces" (it is advised to choose 6 neighborhood option, that gives better results, if segmentation is good enough)


5) Save the interfaces as 2D Tiff and name them as "CPline"


6) Run the script "Points_directions.m" in Matlab. This will save a points_directions_subvolume_movavg.txt file with coordinates and directions of perpendicular planes, and subvolume boundaries.
	
Options:
- Matlab will ask you how many .tif images you have. Provide the correct number
- Select the dimension of subvolume you prefer (40 should be ok). Remember this value as you will need it afterwards
		

7) Run the script "Extract_slices.tcl" in Avizo. This will save 2D perpendicular slices.

Options:
- Line 5: Provide the dimension of subvolume (default is 40)
- line 7: Number of rows in points_directions_subvolume_movavg.txt
- Line 10 path of folder with segmented data
- line 13 your working folder, where to save the slices
- line 19: the exact name of segmented data
- line 22: your working folder, you have the points_directions_subvolume_movavg.txt file containing coordinates and directions

/ you can take a *beer-break* while avizo extract the slices / 



8) Run the script "Scanzi_contact_angle.m" in Matlab, and you will obtain distribution and map of contact angles in the region you selected.

Options:
- Provide the correct number of slices (it is the number of rows of points_directions_subvolume_movavg.txt)
- Give the length of contact line. 200 should work well

/ you could take another *beer-break*. SALUTE! /





