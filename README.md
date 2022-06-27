# Grouped-Z-projector
Make a grouped-Z projection of files too large to fit into ram. If you want to do some averaging, but the entire recording is too large to fit into RAM, you can take the Suite2p output (which is a bunch of smaller TIFFs) and this will open each of the TIFFs, average them, and then resave them. This significantly reduces the size of the data for manual viewing and doesn't require you to load the entire recording into RAM to do the grouped Z function. This is mostly just for visualization and/or ROI selection/refinement. 
_____________________________________________________________________________________________

Things to do before using are the same as here: https://github.com/cawarwick/ThorStackSplitter

_____________________________________________________________________________________________
For Suite2p stack averaging:

User provided information for running the macro is located at the top of the macro when opened in FIJI. These are the following variables you will need to change to run the macro:

ParentD = "C:/Users/warwickc/Desktop/Suite2p run/suite2p/"; //the directory of your suite2p folder which contains stabilized files for averaging. This is specific for Suite2p, make sure it is the Parent Suite2p directory NOT a specific plane. It expects to see a series of folders in this ParentD labeled "plane0", "plane1", etc exactly as Suite2p creates them

planes = 3; //Number of Z planes

avg = 8; //grouped Z amount average. New version will accomodate non-divisbles gracefully by cutting off frames from the final file in the image. 

dZ = 1 or 0 : This function will create a derivative image of the resultant averaged file if desired. Set to 1 to enable, 0 to disable. It will reopen the merged file, make a Z-derivative with 1.0 smoothing, increase contrast, and downscale to 8-bit images to save space.

Once run, this will average each of the channel 0 (green) files in the directory, create a new directory with the individual averaged files and then merge the files into one tiff file and save it in the "suite2p\plane0\" rather than with the rest of the original green channel tiffs to make it possible to run this macro multiple times at different averaging without moving files around. e.g. you want a nice reference image to select ROIs with so you make a 40x average and then you make a 1hz average for analysis.
This is what the output looks like as an example
![image](https://user-images.githubusercontent.com/81972652/175789927-ab2632f5-7bf5-4d2b-908c-4b064971b572.png)

_______________________________________________________________________________________
For Grouped z-project Single folder.ijm:

This macro is for processing a single folder rather than a directory of Suite2p stabilized files.

User provided information for running the macro is located at the top of the macro when opened in FIJI. These are the following variables you will need to change to run the macro:

InputPath=”C:/path/to/where/the tiffs are/” (note the forward slashes, if you copy from Windows Explorer they are back slashes)
SavePath=”C:/path/to/where/you/want the tiffs saved/” (Also note the forward slash at the end, this says to look in that folder, otherwise it thinks it's a file)

If you want more or less averaging you can change the group= variable at line 15. 

Note that this is not a very smart tool in that all your files need to be divisible by the grouped amount (e.g. 40) and if they are not it will error out.
_____________________________________________________________________________________________

