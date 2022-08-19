//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//save location. Need to change this depending on the computer and intention
ParentD="E:/Itch Project/#462 1-5-22 (Control CQ+4880)/Time Lapse/Split Files for stabilization/suite2p/"; //the directory of your suite2p folder which contains stabilized files for averaging
planes=4; //Number of Z planes;
avg=20; //grouped Z amount average.
dzt=1; //set this to 1 to make a derivative image of the average image. Otherwise set it to 0 to not. If using, it applies a custom LUT which you'll need to install.
summary=1; //set this to 1 to make summary images
SDp=80; //number of frames to take of the average for the SD projection, e.g. 40*10= 400frame projection
maxdz=80; //number of frames to take of the average for the SD projection, e.g. 40*10= 400frame projection (both of these are ~2-5 minutes depending)
structavg=210; //number of frames to take of the average for strucutral image (should be large on the order of >10 minutes)
RG=1; //set this to 1 to make an RG composite image to identify SPBNs
fullmerge=1; //set this to 1 to make a single tiff which contains all the full frame rate files for each plane. 
 
 
ResidualD=ParentD+"residual/"; //where the residual/leftover frames are stored 
File.makeDirectory(ResidualD)  //make the new directory

//for each plane
for(p=0; p<planes; p++) {
	InputPath=ParentD+"plane"+p+"/reg_tif/";
	print("open directory:",InputPath);
	list=getFileList(InputPath);
	print(list.length);
	//for each file within the specific plane
	for (i=0; i<list.length; i++) { 
		file=list[i];
		npath=InputPath+file;
		print(npath);
		open(npath);
		//checks for a residual file, opens, and the concatenates it to the opened file
		if (File.exists(ResidualD+"/residual.tif")) {
			open(ResidualD+"/residual.tif");
			concat="  image1=residual.tif image2="+file;
			print(concat);
			run("Concatenate...", concat);
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
		//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
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
		//actually run the grouped Z projection
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
		runMacro("Garbage");
		}
		//when all files are finished within the specified plane, then combined them all into 1 continuous tiff
		File.openSequence(SaveD);
		midparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg";
		print("merged file save location:", midparent);
		saveAs("Tiff", midparent);

//if a Z derivative is desired, then this runs
		if (dzt==1) {
			run("FeatureJ Derivatives", "x-order=0 y-order=0 z-order=1 smoothing=1.0");
			close("\\Others");
			run("Min...", "value=0 stack");
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast", "saturated=0.05"); //this finds the 'right' contrast for the dZ. 
			//The number of saturated pixels of the MaxZ can be changed, this might be changed.
			getMinAndMax(min, max);
			close();
			setMinAndMax(0, max);//set the maxZ contrast to the whole image
			run("8-bit"); //convert the 32bit image to 8bit to save space
			run("32_colors edit"); //this is a custom LUT I made, you may need to install it
			zdtparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg dZ";
			saveAs("Tiff", zdtparent);
			runMacro("Garbage");

//if a maxdzt is to be made, i.e. maxz of the derivative 
			if (summary==1) {
				Stack.getDimensions(Wd,Ht,Ch,Sl,F);
				print("sl",Sl);
				print("F",F);
				frames=maxOf(Sl, F);
				print("Frames:",frames);
				slices=frames/maxdz;
				print("original slices",slices);
				residual=slices-floor(slices);
				roundslices=floor(slices);
				//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
				if (residual!=0) {
					endofstack=roundslices*maxdz;
					start=1;
					end=endofstack;
					name="slices="+start+"-"+end+" delete";
					run("Make Substack...", name);
					close("\\Others");
					}
			//actually run the grouped Z projection
				mid="projection=[Max Intensity] group="+maxdz;
				run("Grouped Z Project...", mid);
				zdmaxtparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg dZMAX";
				saveAs("Tiff", zdmaxtparent);
				close("*");
				runMacro("Garbage");
		}
		//This generates some useful summary images for circling ROIs
		if (summary==1) {
			File.openSequence(SaveD);
			Stack.getDimensions(Wd,Ht,Ch,Sl,F);
			print("sl",Sl);
			print("F",F);
			frames=maxOf(Sl, F);
			print("Frames:",frames);
			slices=frames/SDp;
			print("original slices",slices);
			residual=slices-floor(slices);
			roundslices=floor(slices);
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
			if (residual!=0) {
				endofstack=roundslices*SDp;
				start=1;
				end=endofstack;
				name="slices="+start+"-"+end+" delete";
				run("Make Substack...", name);
				close("\\Others");
				}
		//actually run the grouped Z projection
			mid="projection=[Standard Deviation] group="+SDp;
			run("Grouped Z Project...", mid);
			zdmaxtparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg SD";
			saveAs("Tiff", zdmaxtparent);
			close("*");
		}
		//make the structural average
		if (summary==1) {
			File.openSequence(SaveD);
			Stack.getDimensions(Wd,Ht,Ch,Sl,F);
			print("sl",Sl);
			print("F",F);
			frames=maxOf(Sl, F);
			print("Frames:",frames);
			slices=frames/structavg;
			print("original slices",slices);
			residual=slices-floor(slices);
			roundslices=floor(slices);
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
			if (residual!=0) {
				endofstack=roundslices*structavg;
				start=1;
				end=endofstack;
				name="slices="+start+"-"+end+" delete";
				run("Make Substack...", name);
				close("\\Others");
				}
		//actually run the grouped projection
			mid="projection=[Average Intensity] group="+structavg;
			run("Grouped Z Project...", mid);
			zdmaxtparent=ParentD+"plane"+p+"/Plane"+p+" "+"structural avg";
			saveAs("Tiff", zdmaxtparent);
			close("*");
			runMacro("Garbage");	
		}
		//at the end of each plane, if there are frames still in the residual folder, report how many are deleted
		close("*");
		runMacro("Garbage");
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
SaveD=ParentD+"plane"+p+"/"+avg+"x avg/";
InputPath=SaveD;
list=getFileList(InputPath);
print(list.length);
for (i=0; i<list.length; i++) { 
	file=list[i];
	npath=InputPath+file;
	File.delete(npath);
}
File.delete(SaveD);
runMacro("Garbage");
if (fullmerge==1) {
	SaveD=ParentD+"plane"+p+"/reg_tif/";
	File.openSequence(SaveD);
	midparent=ParentD+"plane"+p+"/Plane"+p+" Full";
	saveAs("Tiff", midparent);
	close();	
}
}
File.delete(ResidualD+"/residual.tif");		
runMacro("Garbage");

//for each red channel plane
if (RG==1) {
	for(p=0; p<planes; p++) {
		InputPath=ParentD+"plane"+p+"/reg_tif_chan2/";
		print("open directory:",InputPath);
		list=getFileList(InputPath);
		print(list.length);
		//for each file within the specific plane
		for (i=0; i<list.length; i++) { 
			file=list[i];
			npath=InputPath+file;
			print(npath);
			open(npath);
			//checks for a residual file, opens, and the concatenates it to the opened file
			if (File.exists(ResidualD+"/residual.tif")) {
				open(ResidualD+"/residual.tif");
				concat="  image1=residual.tif image2="+file;
				print(concat);
				run("Concatenate...", concat);
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
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
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
			//actually run the grouped Z projection
			mid="projection=[Average Intensity] group="+avg;
			run("Grouped Z Project...", mid);
			close("F*");
			
			//Saving the split stacks to the hardrive
			SaveD=ParentD+"plane"+p+"/"+avg+"x avg Red/";
			print("Save directory:", SaveD);
			File.makeDirectory(SaveD)
			output=SaveD+"avg_"+originalname;//where it's being saved and how it's being named
			saveAs("Tiff", output);
			close();
			runMacro("Garbage");
			}
			//when all files are finished within the specified plane, then combined them all into 1 continuous tiff
			File.openSequence(SaveD);
			midparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg Red";
			print("merged file save location:", midparent);
			saveAs("Tiff", midparent);
			close();	
			//make a RG Merge file
			File.openSequence(SaveD); //open the red channel
			Stack.getDimensions(Wd,Ht,Ch,Sl,F);
			print("sl",Sl);
			print("F",F);
			frames=maxOf(Sl, F);
			print("Frames:",frames);
			slices=frames/structavg;
			print("original slices",slices);
			residual=slices-floor(slices);
			roundslices=floor(slices);
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
			if (residual!=0) {
				endofstack=roundslices*structavg;
				start=1;
				end=endofstack;
				name="slices="+start+"-"+end+" delete";
				run("Make Substack...", name);
				close("\\Others");
				rename("Red");
				}
		//actually run the grouped projection
			mid="projection=[Average Intensity] group="+structavg;
			run("Grouped Z Project...", mid);
			rename("Red");
			close("\\Others");
			Green=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg.tif";
			open(Green); //open the green channel
			Stack.getDimensions(Wd,Ht,Ch,Sl,F);
			print("sl",Sl);
			print("F",F);
			frames=maxOf(Sl, F);
			print("Frames:",frames);
			slices=frames/structavg;
			print("original slices",slices);
			residual=slices-floor(slices);
			roundslices=floor(slices);
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder and save it for later
			if (residual!=0) {
				endofstack=roundslices*structavg;
				start=1;
				end=endofstack;
				name="slices="+start+"-"+end+" delete";
				run("Make Substack...", name);
				close("*P");
				rename("Plane");
				}
		//actually run the grouped projection
			mid="projection=[Average Intensity] group="+structavg;
			run("Grouped Z Project...", mid);
			rename("Green");
			close("P*");
			run("Merge Channels...", "c1=[Red] c2=[Green] create ignore");
			SaveD=ParentD+"plane"+p+"/";
			output=SaveD+"Plane"+p+" "+"Structural RG Composite.tif";
			saveAs("Tiff", output);	
			run("Z Project...", "projection=[Average Intensity]");
			refimg=ParentD+"plane"+p+"Ref.tif";
			saveAs("Tiff", refimg);	
			close("*");
			SaveD=ParentD+"plane"+p+"/"+avg+"x avg Red/";
			print(SaveD);
			InputPath=SaveD;
			list=getFileList(InputPath);
			print(list.length);
			for (i=0; i<list.length; i++) { 
				file=list[i];
				npath=InputPath+file;
				File.delete(npath);
				}
			File.delete(SaveD);
			//remove the green only composite if the RG is present
			path=ParentD+"plane"+p+"/"+"Plane"+p+" "+"structural avg.tif";
			if((File.exists(output))){
				File.delete(path);
				}
	}
for(p=0; p<planes; p++) {
	npath=ParentD+"plane"+p+"Ref.tif";
	open(npath);
	File.delete(npath);
	}
run("Concatenate...", "all_open open");
refimg=ParentD+"RG Refence.tif";
saveAs("Tiff", refimg);	
close("*");
}
//at this point it's finished all planes and images and this removes the directory it created
	File.delete(ResidualD);
	print("All planes processed");
