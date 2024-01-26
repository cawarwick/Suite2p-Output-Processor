//Before using make sure to copy the Garbage.ijm macro into the macro folder in order to remove the memory leaks
//save location. Need to change this depending on the computer and intention
ParentD="Y:/DRGS project/#505 12-18-23/SDH Recording/Final FOV/Functional/P4 only/suite2p/"; //the directory of your suite2p folder which contains stabilized files for averaging
planes=1; //Number of Z planes;
batchsize=2500; //frames within each file (this is set in suite2p)
avg=20; //grouped Z amount average.
dzt=1; //set this to 1 to make a derivative image of the average image. Otherwise set it to 0 to not. If using, it applies a custom LUT which you'll need to install.
summary=1; //set this to 1 to make summary images
SDp=10; //number of frames to take of the average for the SD projection, e.g. 40*10= 400frame projection
maxdz=10; //number of frames to take of the average for the SD projection, e.g. 40*10= 400frame projection (both of these are ~2-5 minutes depending)
structavg=20; //number of frames to take of the average for strucutral image (should be large on the order of >10 minutes)
RG=1; //set this to 1 to make an RG composite image to identify SPBNs
fullmerge=1; //set this to 1 to make a single tiff which contains all the full frame rate files for each plane. 
avg_hyperstack=0; //set this to 1 to pull the averages into a single hyperstack
LUT=1; //enable application of custom LUT to specific outputs
MontageFull=0; //whether to montage the output files. CAUTION: This is not RAM otimized, check file sizes before using.
		//With montaging I've only tested 5 and 6 planes, haven't tested above or below this
MontageAvg=0; //Montage the average only
tiling=0; //whether to montage as a single column (set to 0) or arrange in a grid, eg 3x2
dz=0; //set this to 1 to make a derivative image of the MONTAGE or 0 to not. If using, it applies a custom LUT whicNormalized.h you'll need to install.

 
ResidualD=ParentD+"residual/"; //where the residual/leftover frames are stored 
File.makeDirectory(ResidualD)  //make the new directory

//for each plane
for(p=0; p<planes; p++) {
	InputPath=ParentD+"plane"+p+"/reg_tif/";
	print("open directory:",InputPath);
	list=getFileList(InputPath);
	print(list.length);
	//for each file within the specific plane
	filename=0;
	frame=0;
	for (i=0; i<list.length; i++) { 
		if (i==0) {
			filename = "file00000_chan0.tif";
		} else {
			frame = i*batchsize;
			filename = "file00" + frame + "_chan0.tif";
		}
		npath=InputPath+filename;
		open(npath);
		print("directory of file",i," is ",npath);
		//checks for a residual file, opens, and the concatenates it to the opened file
		if (File.exists(ResidualD+"/residual.tif")) {
			open(ResidualD+"/residual.tif");
			concat="  image1=residual.tif image2="+file;
			print("residual exists")
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
		//actually run the average grouped Z projection
		mid="projection=[Average Intensity] group="+avg;
		run("Grouped Z Project...", mid);
		close("f*");
		close("S*");
		
		//Saving the averaged files to the hardrive
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
		if (LUT==1) {
			run("oslo");
		}
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
			//grouped MaxZ projection
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
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder
			if (residual!=0) {
				endofstack=roundslices*SDp;
				start=1;
				end=endofstack;
				name="slices="+start+"-"+end+" delete";
				run("Make Substack...", name);
				close("\\Others");
				}
		//Grouped Standard Deviation projection
			mid="projection=[Standard Deviation] group="+SDp;
			run("Grouped Z Project...", mid);
			zdmaxtparent=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg SD";
			if (LUT==1) {
				run("oslo");
			}
			saveAs("Tiff", zdmaxtparent);
			run("Z Project...", "projection=[Max Intensity]");
			zdmaxtparent=ParentD+"plane"+p+"/Plane"+p+" CellPose";
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
			//if the stack does not divide in evenly (i.e. there is a residual) cut off the remainder
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
//at this point you're done with making the averages so you need to delete the files and then the folder you created to house them
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
//end of main program

//for each red channel plane
if (RG==1) {
	for(p=0; p<planes; p++) {
		InputPath=ParentD+"plane"+p+"/reg_tif_chan2/";
		print("open directory:",InputPath);
		list=getFileList(InputPath);
		print(list.length);
		//for each file within the specific plane
		for (i=0; i<list.length; i++) { 
			if (i==0) {
				file="file00000_chan1.tif";
			} else {
				frame = i*batchsize;
				file = "file00" + frame + "_chan1.tif";
			}
			npath=InputPath+file;
			open(npath);
			print("directory of file",i," is ",npath);
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
			close("S*");
			close("f*");
			
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
		//actually run the grouped projection for the structural average
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

if (avg_hyperstack==1) {
	for(p=0; p<planes; p++) {
		npath=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg.tif";
		open(npath);
		}
	run("Concatenate...", "all_open open");
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	if (LUT==1) {
		run("oslo");
	}
	refimg=ParentD+"Hyperstack "+avg+"x avg.tif";
	saveAs("Tiff", refimg);
	run("Z Project...", "projection=[Max Intensity] all");
	refimg=ParentD+"Hyperstack "+avg+"x avg MaxZ.tif";
	saveAs("Tiff", refimg);	
	close("*");
}

//at this point it's finished all planes and images and this removes the directory it created
	File.delete(ResidualD+"/residual.tif");
	File.delete(ResidualD);
	print("All planes processed");



//////Montage Maker/////////
if (MontageFull==1) {
	runMacro("Garbage");
	for(p=0; p<planes; p++) {
		InputPath=ParentD+"plane"+p+"/Plane"+p+" "+"Full.tif";
		print("open directory:",InputPath);
		open(InputPath);
		List.set(p, File.name);
	}
	if (planes/2!=(round(planes/2))) {
		print("odd number of planes, add an extra");
		print("p value",p);
		open(InputPath);
		rename("plane"+p+"/Plane"+p+" "+"Full.tif");
		t=getInfo("window.title");
		List.set(p, t);
	}
	print(List.size);
	concat="open";
	for (i = 0; i <List.size; i++) {
		string=List.get(i);
		print("1st name",string);
		imagei=" image"+(i+1)+"=["+string+"]";
		print(imagei);
		concat=concat+imagei;
		print(concat);
		
	}
	
	run("Concatenate...", concat);
	
	//run("Concatenate...", "open image1=[Plane0 40x avg.tif] image2=[Plane1 40x avg.tif] image3=[Plane2 40x avg.tif] image4=[Plane3 40x avg.tif] image5=[Plane4 40x avg.tif]");
	
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	rename("Interleaved.tif");
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	print("number of frames",F);
	run("Hyperstack to Stack");
	run("Make Montage...", "columns=2 rows=3 scale=1 border=1");
	rename("Template.tif");
	selectWindow("Interleaved.tif");
	run("Slice Remover", "first=1 last=6 increment=1");
	runMacro("Garbage");
	for (i=2; i<F; i++) {
		selectWindow("Interleaved.tif");
		run("Make Montage...", "columns=2 rows=3 scale=1 border=1");
		run("Concatenate...", "  title=Template.tif image1=Template.tif image2=Montage image3=[-- None --]");
		selectWindow("Interleaved.tif");
		run("Slice Remover", "first=1 last=6 increment=1");
		}
		
	close("Interleaved.tif");
	//blank out the extra plane if there is an odd number
	if (planes==5) {
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		makeRectangle(1+((Wd-1)/2), (1+2*(Ht)/3), ((Wd)/2), ((Ht)/3)); //goes xy coorindate, then xy size
		setForegroundColor(15, 15, 15);
		run("Fill", "stack");
		}
	if (LUT==1) {
		run("oslo");
	}
	saveAs("Tiff", ParentD+"Montage Full");
	close("*");
}


if (MontageAvg==1) {
	runMacro("Garbage");
	//open the averages from each folder
	for(p=0; p<planes; p++) {
		InputPath=ParentD+"plane"+p+"/Plane"+p+" "+avg+"x avg.tif";
		print("open directory:",InputPath);
		open(InputPath);
		List.set(p, File.name);
	}
	if (planes/2!=(round(planes/2))) {
		print("odd number of planes, add an extra");
		print("p value",p);
		open(InputPath); //if it's an odd number, open the last file (as a dummy) to make the montage work correctly
		rename("plane"+p+"/Plane"+p+" "+avg+"x avg.tif");
		t=getInfo("window.title");
		List.set(p, t);
	}
	print(List.size);
	concat="open";
	for (i = 0; i <List.size; i++) {
		string=List.get(i);
		print("1st name",string);
		imagei=" image"+(i+1)+"=["+string+"]";
		print(imagei);
		concat=concat+imagei;
		print(concat);	
	}
	run("Concatenate...", concat);
	run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
	rename("Interleaved.tif");
	Stack.getDimensions(Wd,Ht,Ch,Sl,F);
	print("number of frames",F);
	run("Hyperstack to Stack");
	run("Make Montage...", "columns=2 rows=3 scale=1 border=1");
	rename("Template.tif");
	selectWindow("Interleaved.tif");
	run("Slice Remover", "first=1 last=6 increment=1");
	runMacro("Garbage");
	for (i=2; i<F; i++) {
		selectWindow("Interleaved.tif");
		run("Make Montage...", "columns=2 rows=3 scale=1 border=1");
		run("Concatenate...", "  title=Template.tif image1=Template.tif image2=Montage image3=[-- None --]");
		selectWindow("Interleaved.tif");
		run("Slice Remover", "first=1 last=6 increment=1");
		}
		
	close("Interleaved.tif");
	//blank out the extra plane if there is an odd number
	if (planes==5) {
		Stack.getDimensions(Wd,Ht,Ch,Sl,F);
		makeRectangle(1+((Wd-1)/2), (1+2*(Ht)/3), ((Wd)/2), ((Ht)/3)); //goes xy coorindate, then xy size
		setForegroundColor(15, 15, 15);
		run("Fill", "stack");
		}
	if (LUT==1) {
		run("oslo");
	}
	saveAs("Tiff", ParentD+"Montage "+avg+"x avg.tif");
	if (dz==1) {
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
		zdparent=ParentD+"Montage "+avg+"x avg dZ";
		saveAs("Tiff", zdparent);
		close("*");
			}
	runMacro("Garbage");
	close("*");
}
