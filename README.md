# Suite2p Output Processor
Make a grouped-Z projection of files too large to fit into ram. If you want to do some averaging, but the entire recording is too large to fit into RAM, you can take the Suite2p output (which is a bunch of smaller TIFFs) and this will open each of the TIFFs, average them, and then resave them. This significantly reduces the size of the data for manual viewing and doesn't require you to load the entire recording into RAM to do the grouped Z function. This is mostly just for visualization and/or ROI selection/refinement. This will also create some typical projections for assist in ROI generation.
_____________________________________________________________________________________________

Things to do before using are the same as here: https://github.com/cawarwick/ThorStackSplitter

If using the derivative function there are additional things to install:

1. Install the imagesceince plugin according to these instructions: https://imagej.net/libs/imagescience

2. I made a custom LUT for that which you'll need to install (32_colors edit.lut). Or just comment out that line and it'll remain grayscale.
_____________________________________________________________________________________________
## User inputs:

User provided information for running the macro is located at the top of the macro when opened in FIJI. These are the following variables you will need to change to run the macro:

**ParentD** = "C:/Users/warwickc/Desktop/Suite2p run/suite2p/"; //the directory of your suite2p folder which contains stabilized files for averaging. This is specific for Suite2p, make sure it is the Parent Suite2p directory NOT a specific plane. It expects to see a series of folders in this ParentD labeled "plane0", "plane1", etc exactly as Suite2p creates them

**planes** = 3; //Number of Z planes

**avg** = 8; //grouped Z amount average. New version will accomodate non-divisbles gracefully by cutting off frames from the final file in the image. 

**dZt** = 1 or 0 : This function will create a derivative image of the resultant averaged file if desired. Set to 1 to enable, 0 to disable. It will reopen the merged file, make a Z-derivative with 1.0 smoothing, increase contrast, and downscale to 8-bit images to save space.

## Summary images
**summary**=1 : This function (when set to 1) will create a series of useful reference images to assist in selecting ROIs

The following settings are only relevant to the summary function:

**SDp**=60; //number of frames to take of the average for the SD projection, something like 1-5 minutes of recording is good, e.g. if your average is 1hz, then set this to 60-300 frames

**maxdz**=60; //number of frames to take of the derivative for the Max projection, something like 1-5 minutes of recording is good, e.g. if your average is 1hz, then set this to 60-300 frames

**structavg**=600; //number of frames to take of the average for strucutral image (should be large on the order of >10 minutes, e.g. if your average is 1hz then this should be ~600)

**RG**=1; //set this to 1 to make an RG composite image to identify SPBNs

**fullmerge**=1; //set this to 1 to make a single tiff which contains all the full frame rate files for each plane. Note how much RAM you have and your file sizes before using this.

Once run, this will average each of the channel 0 (green) files in the directory and create each of the other specified images.
This is what the output looks like as an example

![image](https://user-images.githubusercontent.com/81972652/185458490-ff725f89-f6df-4f46-a1f5-db3cbec648c0.png)

________________________________________________________________________________________
# Multi Measure Macro

Use this macro once you have made your ROIs. Place your ROI zip file (saved from FIJI) into the subfolder of the appropriate folder, e.g. Plane0's ROIs go into the plane0 folder as shown below. Repeat for all planes. Of note, the files need to named consistently as Plane0 RoiSet.zip, Plane1 RoiSet.zip, Plane2 RoiSet.zip, etc as it needs to know the exact name to open the ROI zip file.

![image](https://user-images.githubusercontent.com/81972652/185488137-fa0a0eeb-d08a-4e26-84e2-7c82f44e23df.png)

## Inputs:

**ParentD**="C:/Users/Computer/Desktop/suite2p/" //where the files to process are located

**planes=3**; //Number of Z planes; 

Once run it will place a CSV with the mean values in the appropriate folder

![image](https://user-images.githubusercontent.com/81972652/185489545-1c6981c6-2441-4caa-860f-9800ead6991f.png)

_______________________________________________________________________________________
## For Grouped z-project Single folder.ijm:

This macro is for processing a single folder rather than a directory of Suite2p stabilized files.

User provided information for running the macro is located at the top of the macro when opened in FIJI. These are the following variables you will need to change to run the macro:

InputPath=”C:/path/to/where/the tiffs are/” (note the forward slashes, if you copy from Windows Explorer they are back slashes)
SavePath=”C:/path/to/where/you/want the tiffs saved/” (Also note the forward slash at the end, this says to look in that folder, otherwise it thinks it's a file)

If you want more or less averaging you can change the group= variable at line 15. 

Note that this is not a very smart tool in that all your files need to be divisible by the grouped amount (e.g. 40) and if they are not it will error out.
_____________________________________________________________________________________________

