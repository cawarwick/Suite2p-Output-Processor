//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//save location. Need to change this depending on the computer and intention
ParentD="C:/Users/warwickc/Desktop/Suite2p run/suite2p/"; //the directory of your suite2p folder which contains stabilized files for averaging
planes=3; //Number of Z planes;
avg=8; //grouped Z amount average. Make sure they are divisible this isn't smart enough to fix that yet.

for(p=0; p<planes; p++) {
	InputPath=ParentD+"plane"+p+"/reg_tif/";
	print("open directory:",InputPath);
	list=getFileList(InputPath);
	print(list.length);
	for (i=0; i<list.length; i++) {
		file=list[i];
		npath=InputPath+file;
		print(npath);
		open(npath);
		
		//grouped Z-project
		mid="projection=[Average Intensity] group="+avg;
		run("Grouped Z Project...", mid);
		close("F*");
		
		//Saving the split stacks to the hardrive
		SaveD=ParentD+"plane"+p+"/"+avg+"x avg/";
		print("Save directory:", SaveD);
		File.makeDirectory(SaveD)
		Filename=getInfo("window.title");
		output=SaveD+Filename;//where it's being saved and how it's being named
		saveAs("Tiff", output);
		close();
		}
		File.openSequence(SaveD);
		midparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg";
		print("merged file save location:", midparent);
		saveAs("Tiff", midparent);
		close("*");
		print("plane",p," Finished");
		runMacro("Garbage");
	}
	print("All planes processed");