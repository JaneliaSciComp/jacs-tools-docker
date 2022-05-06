ScopeNum=0;
argstr=0;
//for test
//63x
//argstr="/test/Dist_Correction_test/Scope1/GMR_75F10_AE_01-20161007_22_A3~63x/,GMR_75F10_AE_01-20161007_22_A3_Ch3_FLFL_20161125150205110_242445.lsm,/test/Dist_Correction_test/Scope1/GMR_75F10_AE_01-20161007_22_A3~63x/Output/,Scope #1,63x,Thu Dec 08 19:01:25 EST 2016,1024,"+getDirectory("plugins")+"Chromatic_Aberration"+File.separator;//for test

//40x
//argstr="/test/Dist_Correction_test/Scope6_40x/,FLFL_20170411171458477_279354.lsm,/test/Dist_Correction_test/Scope6_40x/Output/,Scope #5,40x";//for test
//argstr="/test/Dist_Correction_test/40x_0/vnc/,FLFL_20170302124503877_268270_ch3.lsm,/test/Dist_Correction_test/40x_0/vnc/Output/,Scope #6,40x";//for test


//argstr="/test/Dist_Correction_test/40x/,I1_ZB49_T1_LC_20170622_62_40X_R1_L18.lsm,/test/Dist_Correction_test/40x/Output/,Scope #9,40x,Thu Dec 08 19:01:25 EST 2016,688,"+getDirectory("plugins")+"Chromatic_Aberration"+File.separator;//for test


//argstr="/test2/distortion/,JPTR_20200128111937966_5537.lsm,/test2/distortion/Output/,Scope #9,40x,Thu Dec 08 19:01:25 EST 2018,688,"+getDirectory("plugins")+"Chromatic_Aberration"+File.separator;//for test

if(argstr!=0)
args = split(argstr,",");
else
args = split(getArgument(),",");

//args will be like this; "dir,filename,outputdir,Scope #1,Objective"

dir=0; filename=0; outputdir=0; ScopeNumST=0; ObjectiveST=0;
dir = args[0];// Imput directory of the LSM files
filename = args[1];// The name of the LSM file
outputdir = args[2];//output directory
ScopeNumST = args[3];// scope number, "Scope #1" "Scope #2" "Scope #3" "Scope #4"" Scope #5" "Scope #6"
ObjectiveST= args[4];//Objective
CapDate=args[5];//Capture Date
Xdimension=args[6];//X Dimension
JSONDIR=args[7];// distortion filed's location

Distlist=getFileList(JSONDIR);


print("dir; "+dir);
print("filename; "+filename);
print("outputdir; "+outputdir);
print("ScopeNumST; "+ScopeNumST);
print("ObjectiveST; "+ObjectiveST);
print("JSONDIR; "+JSONDIR);

exi=File.exists(outputdir);
if(exi!=1){
	File.makeDirectory(outputdir);
	print("outputdir created!");
}
logsum=getInfo("log");
filepath=outputdir+"Distortion_Correction_log_"+filename+".txt";

if(File.exists(filepath)!=1)
File.saveString(logsum, filepath);

print("\\Clear");

exi2=File.exists(dir+filename);
if(exi2!=1){
	print("input file is not existing!  "+dir+filename);
	logsum=getInfo("log");
	filepath=outputdir+"Distortion_Correction_log_error+"+filename+".txt";
	File.saveString(logsum, filepath);
	
	run("Quit");
}
//Fri May 05 08:44:46 EDT 2017

Month="00";
print("");

MonthIndex=indexOf(CapDate, "Jan"); 
if (MonthIndex!=-1)
Month="01";

if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Feb");
	if (MonthIndex!=-1)
	Month="02";
}

if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Mar"); 
	if (MonthIndex!=-1)
	Month="03";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Apr");
	if (MonthIndex!=-1)
	Month="04";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "May");
	if (MonthIndex!=-1)
	Month="05";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Jun");
	if (MonthIndex!=-1)
	Month="06";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Jul");
	if (MonthIndex!=-1)
	Month="07";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Aug");
	if (MonthIndex!=-1)
	Month="08";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Sep");
	if (MonthIndex!=-1)
	Month="09";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Oct");
	if (MonthIndex!=-1)
	Month="10";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Nov");
	if (MonthIndex!=-1)
	Month="11";
}
if(MonthIndex==-1){
	MonthIndex=indexOf(CapDate, "Dec");
	if (MonthIndex!=-1)
	Month="12";
}
if(Month=="00"){
	print("Month is not detected  "+CapDate);
	logsum=getInfo("log");
	filepath=outputdir+"Distortion_Correction_log_error+"+filename+".txt";
	File.saveString(logsum, filepath);
	exit();
	//	run("Quit");
	
}

HourNum=substring(CapDate,MonthIndex+7,MonthIndex+9);
HourNumint=parseFloat(HourNum);//Change string to number

DateNum=substring(CapDate,MonthIndex+4,MonthIndex+6);
DateNumint=parseFloat(DateNum);//Change string to number

//Fri May 05 08:44:46 EDT 2017
YearNum=substring(CapDate,MonthIndex+20,MonthIndex+24);
YearNumint=parseFloat(YearNum);//Change string to number

CapTime=0;
CapTime=YearNum+"_"+Month+DateNum+HourNum;
print("CapTime; "+CapTime);

CapTimeDOB=YearNum+Month+DateNum+HourNum;
CapTimeDOBint=parseFloat(CapTimeDOB);
print("CapTimeDOBint; "+CapTimeDOBint);

//items=newArray("scope1", "scope2", "scope3","scope4", "scope5", "scope6");

if(ScopeNumST=="Scope #1")
ScopeNum="scope1";

else if(ScopeNumST=="Scope #2")
ScopeNum="scope2";

else if(ScopeNumST=="Scope #3")
ScopeNum="scope3";

else if(ScopeNumST=="Scope #4")
ScopeNum="scope4";

else if(ScopeNumST=="Scope #5")
ScopeNum="scope5";

else if(ScopeNumST=="Scope #6")
ScopeNum="scope6";

else if(ScopeNumST=="Scope #9")
ScopeNum="scope9";

else if(ScopeNumST=="Scope #10")
ScopeNum="scope10";

else if(ScopeNumST=="Scope #11")
ScopeNum="scope11";

else if(ScopeNumST=="Scope #12")
ScopeNum="scope12";

else if(ScopeNumST=="Aljoscha")
ScopeNum="scope4";

if(ScopeNum==0){
	print("ScopeNumST; "+ScopeNumST+" is wrong string. It must be Scope #1 ~ Scope #11, or Aljoscha.");

	logsum=getInfo("log");
    filepath=outputdir+"Distortion_Correction_log_error+"+filename+".txt";
	File.saveString(logsum, filepath);
	
	run("Quit");
}

BestJson=" "; BestJsonDOBint=0;

for(jsonScan=0; jsonScan<Distlist.length; jsonScan++){
	jsonname=Distlist[jsonScan];
	
	//print("jsonname; "+jsonname);
	
	ScopeIndex=indexOf(jsonname, ScopeNum);
	if(ScopeIndex!=-1){
		ObjectiveIndex=indexOf(jsonname, ObjectiveST);
		if(ObjectiveIndex!=-1){//40x or 63x
			ClippedName=substring(jsonname,ObjectiveIndex+3,ObjectiveIndex+7);
			XsizeIndex=indexOf(ClippedName,Xdimension);
			if(XsizeIndex!=-1){// 688 or 1024
				
				jsonArray=newArray(jsonname, ObjectiveIndex, 0);
				jsonIntGeneration(jsonArray);
				JsonDOBint=jsonArray[2];
				
				if(BestJson==" "){
					BestJson=jsonname;
					jsonArray=newArray(jsonname, ObjectiveIndex, 0);
					jsonIntGeneration(jsonArray);
					BestJsonDOBint=jsonArray[2];
					
					print("207");
				}else if(CapTimeDOBint>JsonDOBint){
					if(BestJsonDOBint<JsonDOBint){
						BestJson=jsonname;
						jsonArray=newArray(jsonname, ObjectiveIndex, 0);
						jsonIntGeneration(jsonArray);
						BestJsonDOBint=jsonArray[2];// best json is newest
						print("214"); //jsonScan=Distlist.length;
					}
				}//	if(BestJson==" "){
			}
		}//	if(ObjectiveIndex!=-1){
	}
}//for(jsonScan=0; jsonScan<Distlist.length; jsonScan++){

function jsonIntGeneration(jsonArray){
	jsonname=jsonArray[0];
	ObjectiveIndex=jsonArray[1];
	
	ClippedName2=substring(jsonname,ObjectiveIndex+3,lengthOf(jsonname));
	UnderIndex=indexOf(ClippedName2,"_");
	dotindex2=lastIndexOf(ClippedName2,".");
	if(dotindex2==-1)
	dotindex2=lengthOf(ClippedName2);
	
	dob=substring(ClippedName2,UnderIndex+1,dotindex2);//2017_051505 like this
	
	JsonYearNum=substring(dob,0,4);
	JsonDOB=substring(dob,5,lengthOf(dob));//051505 like this
	JsonDOB=JsonYearNum+JsonDOB;//2017051505 like this
	JsonDOBint=parseFloat(JsonDOB);
	
	jsonArray[2]=JsonDOBint;
}

print("BestJson; "+BestJson+"   BestJsonDOBint; "+BestJsonDOBint);

logsum=getInfo("log");
File.saveString(logsum, filepath);

if(BestJson==" "){
	print("No json file for; "+ScopeNumST+"  "+ObjectiveST+"  "+Xdimension+"  "+CapDate);
	logsum=getInfo("log");
	filepath=outputdir+"Distortion_Correction_log_error_"+filename+".txt";
	File.saveString(logsum, filepath);
	run("Quit");
}

JSONPATH=""+JSONDIR+BestJson;
if(File.exists(JSONPATH)==1){
	
	if(endsWith(filename,".lsm")){
		
		imputdir=dir+filename;
		
		print("filename; "+filename+"  transformations= "+JSONDIR+BestJson+"  outputdir; "+outputdir);
		
		run("apply lens", "stack1=["+imputdir+"] transformations=["+JSONDIR+BestJson+"] output=["+outputdir+"] crop_width=0 mip_step_slices=1");
	//	run("apply lens", "stack1=/test2/distortion/JPTR_20200128111937966_5537.lsm transformations=/Applications/Fiji.app/plugins/Chromatic_Aberration/Scope9_40x688_2018_050100.json output=/test2/distortion/Output crop_width=0 mip_step_slices=1");
		
		print("apply lens finished!");
		dotindex=lastIndexOf(filename,".lsm");
		truname=substring(filename,0,dotindex);
		
		exi2ch=File.exists(outputdir+truname+"-1-2.tif");
		exi3ch=File.exists(outputdir+truname+"-1-3.tif");
		
		exi2ch0=File.exists(outputdir+truname+"-1-2-0.tif");
		exi3ch0=File.exists(outputdir+truname+"-1-3-0.tif");
		
		if(exi2ch==1)
		File.rename(outputdir+truname+"-1-2.tif", outputdir+truname+".tif"); // - Renames, or moves, a file or directory. Returns "1" (true) if successful. 
		
		if(exi3ch==1)
		File.rename(outputdir+truname+"-1-3.tif", outputdir+truname+".tif"); // - Renames, or moves, a file or directory. Returns "1" (true) if successful. 
		
		if(exi2ch0==1)
		File.rename(outputdir+truname+"-1-2-0.tif", outputdir+truname+".tif"); // - Renames, or moves, a file or directory. Returns "1" (true) if successful. 
		
		if(exi3ch0==1)
		File.rename(outputdir+truname+"-1-3-0.tif", outputdir+truname+".tif"); // - Renames, or moves, a file or directory. Returns "1" (true) if successful. 
		
		//	setBatchMode(true);
		
		open(outputdir+truname+".tif");
		getDimensions(width, height, channels, slices, frames);
		print("Opened tif"+truname +"  channels"+channels);
		
		run("V3Draw...", "save="+outputdir+truname+".v3draw");
		File.delete(outputdir+truname+".tif");
		
	}
}else{//if(File.exists(JSONPATH)==1){
	print("json file is not existing!!  "+JSONPATH);
	logsum=getInfo("log");
	filepath=outputdir+"Distortion_Correction_log_error_"+filename+".txt";
	File.saveString(logsum, filepath);
	
	run("Quit");
}

"Done"
""
logsum=getInfo("log");
filepath=outputdir+"Distortion_Correction_log_"+filename+".txt";
File.append(logsum, filepath);
run("Quit");