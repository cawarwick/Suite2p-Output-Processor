# Grouped-Z-projector
Make a grouped-Z projection of files too large to fit into ram. If you want to do some averaging, but the entire recording is too large to fit into RAM, you can take the Suite2p output (which is a bunch of smaller TIFFs) and this will open each of the TIFFs, average them, and then resave them. This significantly reduces the size of the data for manual viewing and doesn't require you to load the entire recording into RAM to do the grouped Z function. This is mostly just for visualization and/or ROI selection/refinement. 
_____________________________________________________________________________________________

Things to do before using are the same as here: https://github.com/cawarwick/ThorStackSplitter

_____________________________________________________________________________________________

User provided information for running the macro is located at the top of the macro when opened in FIJI. These are the folllowing variables you will need to change to run the macro:

InputPath=”C:/path/to/where/the tiffs are/” (note the forward slashes, if you copy from Windows Explorer they are back slashes)
SavePath=”C:/path/to/where/you/want the tiffs saved/” (Also note the forward slash at the end, this says to look in that folder, otherwise it thinks it's a file)

If you want more or less averaging you can change the group= variable at line 15. 

Note that this is not a very smart tool in that all your files need to be divisible by the grouped amount (e.g. 40) and if they are not it will error out.
_____________________________________________________________________________________________
