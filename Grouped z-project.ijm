//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//save location. Need to change this depending on the computer and intention
InputPath="E:/ImageJ Macro Output/4-plane files/suite2p/plane3/reg_tif/";
SavePath="C:/Users/warwickc/Desktop/Suite2p run/"; //Where to save the files


list=getFileList(InputPath);
print(list.length);
for (i=0; i<list.length; i++) {
	file=list[i];
	npath=InputPath+file;
	print(npath);
	open(npath);
	//grouped Z-project
	run("Grouped Z Project...", "projection=[Average Intensity] group=40"); ///if you want more or less averaging, this is the spot to change that
	close("F*");
	//Saving the split stacks to the hardrive
	Filename=getInfo("window.title");
	output=SavePath+Filename;//where it's being saved and how it's being named
	saveAs("Tiff", output);
	close();
	}
	print("Run Finished");
	runMacro("Garbage");
}
