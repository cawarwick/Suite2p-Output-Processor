//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
ParentD="E:/Itch Project/#468 2-1-22 (Nalf 4880)/Final FOV/Split Files/FOV2/suite2p/"; //the directory of your suite2p folder which contains stabilized files for averaging
planes=5; //Number of Z planes;
avg=40; //grouped Z amount average.
dzt=1; //set this to 1 to make a derivative image or 0 to not

ResidualD=ParentD+"residual/";
File.makeDirectory(ResidualD)
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
		if (File.exists(ResidualD+"/residual.tif")) {
			open(ResidualD);
			concat="  image1=residual.tif image2="+file;
			print(concat);
			run("Concatenate...", "  image1=residual.tif image2=file000_chan0.tif");
			rename(file);
			File.delete(ResidualD+"/residual.tif");		
			}
		//grouped Z-project function
		
		 //figure out the max number of z-projections
		originalname=getInfo("window.title");		
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		print("sl",Sl);
		print("F",F);
		frames=maxOf(Sl, F);
		print("Frames:",frames);
		slices=frames/avg;
		print("original slices",slices);
		residual=slices-floor(slices);
		roundslices=floor(slices);
		if (residual!=0) {
			endofstack=roundslices*avg;
			start=1;
			end=endofstack;
			name="slices="+start+"-"+end+" delete";
			run("Make Substack...", name);
			selectWindow(originalname);
			saveAs("Tiff", ResidualD+"residual");
			close();
			}
		mid="projection=[Average Intensity] group="+avg;
		run("Grouped Z Project...", mid);
		close("F*");
		
		//Saving the split stacks to the hardrive
		SaveD=ParentD+"plane"+p+"/"+avg+"x avg/";
		print("Save directory:", SaveD);
		File.makeDirectory(SaveD)
		output=SaveD+"avg_"+originalname;//where it's being saved and how it's being named
		saveAs("Tiff", output);
		close();
		}
		File.openSequence(SaveD);
		midparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg";
		print("merged file save location:", midparent);
		saveAs("Tiff", midparent);
		if (dzt==1) {
			run("FeatureJ Derivatives", "x-order=0 y-order=0 z-order=1 smoothing=1.0");
			close("\\Others");
			run("Min...", "value=0 stack");
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast", "saturated=0.05");
			getMinAndMax(min, max);
			close();
			setMinAndMax(0, max);
			run("8-bit");
			run("32_colors edit");
			zdtparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg dZ";
			saveAs("Tiff", zdtparent);
		}
		close("*");
		if (File.exists(ResidualD+"/residual.tif")) {
			open(ResidualD);
			Stack.getDimensions(Wd,Ht,Ch,Sl,F);
			close("*");
			lost=maxOf(Sl, F);
			print("plane",p," trimmed"+lost+" frames");
			Table.set("Plane", p, "Plane"+p);
			Table.set("Frames removed at end", p, lost);
		}else {
			Table.set("Plane", p, "Plane"+p);
			Table.set("Frames removed at end", p, "no frames trimmed");
		}
		print("plane",p," Finished");
		File.delete(ResidualD+"/residual.tif");
		runMacro("Garbage");
	}
	File.delete(ResidualD);
	print("All planes processed");
