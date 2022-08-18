ParentD="C:/Users/Computer/Desktop/suite2p/" //where the files to process are located
planes=3; //Number of Z planes;

for(p=0; p<planes; p++) {
	InputPath=ParentD+"plane"+p+"/reg_tif/";
	print("open directory:",InputPath);
	list=getFileList(InputPath);
	print(list.length);
	runMacro("Garbage");
	list=getFileList(InputPath);
	print("Number of files in folder:",list.length);
	ROIs=ParentD+"plane"+p+"/Plane"+p+" RoiSet.zip";
	roiManager("Open", ROIs);
	for (i=0; i<list.length; i++) {
		print("Name of file:",list[i]);
		print("Working on file number:",i);
		file=list[i];
		npath=InputPath+file;
		print("Opening 1st file from:",npath);
		open(npath);
			//Get the file info before messing with it
		Y=getInfo("window.title");
		print("Name of file opened:",Y);
		eos=lengthOf(Y);
		sos=eos-4;
		Z=substring(Y, 0,sos);
		print("Trimmed file name:",Z);
		OG_filename=File.name;
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		roiManager("multi-measure measure_all one append");
		close();
		runMacro("Garbage");
	}
	csvsave=ParentD+"plane"+p+"/"+"Plane"+p+" Results.csv";
	saveAs("Results", csvsave);
	run("Clear Results");
	roiManager("Delete");
}
