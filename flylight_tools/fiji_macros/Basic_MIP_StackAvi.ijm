// Date released:  2014-10-01
// FIJI macro for generating intensity-normalized Movies and MIPs
//
// Argument should be in this format: "Basedir,BrainPrefix,VNCPrefix,BrainPath,VNCPath,Laser,Gain,ChanSpec,ColorSpec,DivSpec,Options"
// 
// Input parameters:
//     Basedir: output directory for MIPs and movies
//     BrainPrefix: output filename prefix for the brain input
//     VNCPrefix: output filename prefix for the VNC input
//     BrainPath: absolute path to the Brain stack 
//     VNCPath: absolute path to the VNC stack (may be blank if there is no VNC)
//     Laser: laser power (BC1) for the signal channel (optional annotation)
//     Gain: detector gain for the signal channel (optional annotation)
//     ChannelSpec: image channel specification
//     ColorSpec: color specification [(R)ed, (G)reen, (B)lue, grey(1), (C)yan, (M)agenta, (Y)ellow]
//     DivSpec: divisor for each channel (optional)
//     Options: colon-delimited list of boolean options, defaults to "mips:legends:hist"
//         mips - generate MIPs 
//         movies - generate movies
//         legends - superimpose intensity legends on all MIPs
//         hist - perform histogram stretching adjustment to normalize brightness
//         gamma - perform gamma correction on signal channels
//         bcomp - calculate and output brightness saturation value for each channel
//
// Calling this macro from the command line looks something like this:
//     /path/to/ImageJ -macro 20x_MIP_StackAvi.ijm /output/dir,brain,vnc,file_brain.lsm,file_vnc.lsm,3,490,rs,MG,12,mips:movies:legends
//

// Global variables

var numChannels;
var numOutputChannels;
var reverseMapping;
var mipFormat = "PNG";
var options = "mips:legends:hist"

// Initialization

setBatchMode(true);
setBackgroundColor(0,0,0);
setForegroundColor(255,255,255);
call("ij.ImagePlus.setDefault16bitRange", 12);

// Arguments

var args = split(getArgument(),",");
var basedir = args[0];
var brainPrefix = args[1];
var vncPrefix = args[2];
var brainImage = args[3];
var vncImage = args[4];
var laser = args[5];
var gain = args[6];
var chanspec = toLowerCase(args[7]);
var colorspec = toUpperCase(args[8]);
var divspec = args[9];
if (args.length > 10) {
    options = toLowerCase(args[10]);
}

var numChannels = lengthOf(chanspec);
var numSignalChannels = numChannels-1;

if (divspec == "") {
    // Default divisor is for ref channel only
    for (i=0; i<numChannels; i++) {
        cc = substring(chanspec,i,i+1);
        if (cc == 'r') {
            divspec = divspec + "2";
        }
        else {
            divspec = divspec + "1";
        }
    }
}

print("Output dir: "+basedir);
print("Output brain prefix: "+brainPrefix);
print("Output VNC prefix: "+vncPrefix);
print("Brain image: "+brainImage);
print("VNC image: "+vncImage);
print("Laser power: "+laser);
print("Detector gain: "+gain);
print("Channel spec: "+chanspec);
print("Color spec: "+colorspec);
print("Divisor spec: "+divspec);
print("Options: "+options);

var createMIPS = false;
var createMovies = false;
var displayLegends = false;
var truehistStretch = false;
var histStretch = false;
var brightnessComp = false;
var gammaCorrection = false;

if (options!="") {
    if (matches(options,".*mips.*")) {
        createMIPS = true;
    }
    
    if (matches(options,".*movies.*")) {
        createMovies = true;
    }
    
    if (matches(options,".*legends.*")) {
        displayLegends = true;
    }
    
    if (matches(options,".*truehist.*")) {
        truehistStretch = true;
    }
    else if (matches(options,".*hist.*")) {
        histStretch = true;
    }
    
    if (matches(options,".*bcomp.*")) {
        brightnessComp = true;
    }
    
    if (matches(options,".*gamma.*")) {
        gammaCorrection = true;
    }
}

if (!createMIPS && !createMovies) {
    print("No outputs selected, exiting.");
    run("Quit");
}

// Figure out how to map the channels in the final image

brainChannelMapping = getChannelMapping("Brain");
vncChannelMapping = getChannelMapping("VNC");
print("Brain channel mapping: "+brainChannelMapping);
print("VNC channel mapping: "+vncChannelMapping);

numRefs = 0;
numSignals = 0;
allChannels = "";
refChannels = "";
signalChannels = "";
singleSignalChannel = newArray(numSignalChannels);
refSignalChannel = newArray(numSignalChannels);
for (k=0; k<numSignalChannels; k++) {
    singleSignalChannel[k] = "";
    refSignalChannel[k] = "";
}

refIndex = -1;
signalIndex = 0;
for (j=0; j<numOutputChannels; j++) {
    i = reverseMapping[j];
    cc = substring(chanspec,i,i+1);
    print("reverse mapped "+j+" -> "+i+ " ("+cc+")");
    allChannels += "1";
    if (cc == 'r') {
        numRefs++;
        refIndex = j;
        refChannels += "1";
        signalChannels += "0";
        for (k=0; k<numSignalChannels; k++) {
            s = singleSignalChannel[k];
            singleSignalChannel[k] = s + "0";
            s = refSignalChannel[k];
            refSignalChannel[k] = s + "1";
        }
    }
    else {
        numSignals++;
        refChannels += "0";
        signalChannels += "1";
        for (k=0; k<numSignalChannels; k++) {
            if (k==signalIndex) {
                s = singleSignalChannel[k];
                singleSignalChannel[k] = s + "1";
                s = refSignalChannel[k];
                refSignalChannel[k] = s + "1";
            }
            else {
                s = singleSignalChannel[k];
                singleSignalChannel[k] = s + "0";
                s = refSignalChannel[k];
                refSignalChannel[k] = s + "0";
            }
        }
        signalIndex++;
    }
}

//print("All channels: "+allChannels);
//print("Reference channels: "+refChannels);
//print("All signal channels: "+signalChannels);
//for (k=0; k<numSignalChannels; k++) {
//    print("Ref+signal"+k+": "+refSignalChannel[k]);
//  print("Signal"+k+": "+singleSignalChannel[k]);
//}

// Open input files

openChannels(brainImage, "Brain");
if (vncImage!="") {
    openChannels(vncImage, "VNC");
}

var defaultMaxValue = 4095;
if (bitDepth()==8) {
    defaultMaxValue = 255;
}

if (brightnessComp) {
    exportBrightnessCompensationValues("Brain", brainPrefix);
    if (vncImage!="") {
        exportBrightnessCompensationValues("VNC", vncPrefix);
    }
}

// Array of the max values for each Brain channel
brainMax=newArray(numChannels);

for (i=0; i<numChannels; i++) {
    
    var bname;
    var vname;
    var minMax = newArray(2);
    
    // Type of channel
    cc = substring(chanspec,i,i+1);
        
    // Process Brain channel, save its intensity
    bname = "C" + (i+1) + "-Brain";
    brainMinMax = getMinMax(bname);
    
    if (vncImage!="") {
        vname = "C" + (i+1) + "-VNC";
        vncMinMax = getMinMax(vname);
        minMax[0] = calcMin(brainMinMax[0],vncMinMax[0]);
        minMax[1] = calcMax(brainMinMax[1],vncMinMax[1]);
    }
    else {
        minMax[0] = brainMinMax[0];
        minMax[1] = brainMinMax[1];
    }
    
    print("Processing "+bname);
    if (cc == 'r') {
        performHistogramAdjustment(bname, brainMinMax);
    }
    else {
        performHistogramAdjustment(bname, minMax);
    }
    
    brainMax[i] = minMax[1]-minMax[0];

    // Process VNC channel 
    if (vncImage!="") {
        print("Processing "+vname);
        
        if (cc == 'r') {
            performHistogramAdjustment(vname, vncMinMax);
        }
        else {
            // Normalize VNC signal channel to corresponding Brain signal channel
            performHistogramAdjustment(vname, minMax);
        }
    }
}

saveMipsAndMovies("Brain", brainPrefix, brainMax, brainChannelMapping);
if (vncImage!="") {
    saveMipsAndMovies("VNC", vncPrefix, brainMax, vncChannelMapping);
}

print("Done");
run("Close All");
run("Quit");


// Open the given image and give it a name. Then split into individual channels. 
function openChannels(image,name) {
    open(image);
    print(image+" "+chanspec+" "+colorspec);
    getDimensions(width, height, channels, slices, frames);
    if (channels!=numChannels) {
        print("Image "+name+" has incorrect number of channels: "+channels+" (Expected "+numChannels+")");
    }
    print(width + "x" + height + "  Slices: " + slices + "  Channels: " + channels);
    print("Splitting and renaming channels");
    if (channels==1) {
        rename("C1-"+name);
    }
    else {
        rename(name);
        run("Split Channels");
    }
}

// Create a channel mapping string for the image with the given name. 
// Also set the global signalChannels variable with a signal channel bitmask. 
function getChannelMapping(name) {
    merge_name = "";
    targets = newArray(numChannels);
    numOutputChannels = 0;
    
    for (i=0; i<numChannels; i++) {
        cname = "C" + (i+1) + "-" + name;
        cc = substring(chanspec,i,i+1);
        col = substring(colorspec,i,i+1);
        
        targetChannel = 0;
        if (col == 'R') {
            targetChannel = 1;
        }
        else if (col == 'G') {
            targetChannel = 2;
        }
        else if (col == 'B') {
            targetChannel = 3;
        }
        else if (col == '1') {
            targetChannel = 4;
        }
        else if (col == 'C') {
            targetChannel = 5;
        }
        else if (col == 'M') {
            targetChannel = 6;
        }
        else if (col == 'Y') {
            targetChannel = 7;
        }
        else {
            // ignore channel in output
        }
        
        targets[i] = targetChannel;
        if (targetChannel > 0) {
            merge_name += "c" + targetChannel + "=" + cname + " ";
            numOutputChannels++;
        }
    }
    
    // Compute reverse mapping
    ordered = Array.copy(targets);
    Array.sort(ordered);
        
    reverseMapping = newArray(numOutputChannels);
    j = 0;
    for (ij=0; ij<numChannels; ij++) {
        if (ordered[ij]>0) {
            for (i=0; i<numChannels; i++) {
                if (ordered[ij]==targets[i]) {
                    reverseMapping[j] = i;
                }
            }   
            j++;
        }
    }
    
    return merge_name;
}

// Save MIPs and movies for the image with the given name. The max intensity value of the each 
// channel should be provided as an array in parameter "maxValues".  
function saveMipsAndMovies(name, prefix, maxValues, merge_name) {
    
    if (numChannels==1) {
        // With a single channel, merge won't create a new image
        // Note that this ignores the color spec, which is a bug.
        selectWindow("C1-"+name);
    }
    else {
        run("Merge Channels...", merge_name+" create ignore");
    }
    
    rename(name);
    
    if (createMIPS) {
        print("Creating MIPs for "+name);
        titleMIP = prefix + "_all";
        titleSignalMIP = prefix + "_signal";
        titleRefMIP = prefix + "_reference";
        titleRefSignalMIP = prefix + "_refsignal";
        
        run("Z Project...", "projection=[Max Intensity]");

        if (refChannels=='1') {
            // Just save the single reference channel
            saveAs(mipFormat, basedir+'/'+titleRefMIP);
            run("Divide...", "value="+parseInt(divspec));
            saveAs(mipFormat, basedir+'/'+titleMIP);
        }
        else {
            // Must process multiple channels    
            all_merge_name = "";
        
            // this replaces ZProject window with one MIP window per channel
            run("Split Channels");
                
            // Save each channel on its own, without any divisor
            all_signal_merge_name = "";
            signalIndex = 1;
            for (j=0; j<numOutputChannels; j++) {
            
                c = j+1;
                wname = "C" + c + "-MAX_"+name;
                i = reverseMapping[j];
                cc = substring(chanspec,i,i+1);
                col = substring(colorspec,i,i+1);
                selectWindow(wname);
                
                if (cc=='R') {
                    run("Duplicate...", "title=duplicate");
            
                    // Apply gamma if necessary
                    performGammaCorrection(64, 3);
                
                    // Save reference channel only
                    saveAs(mipFormat, basedir+'/'+titleRefMIP);
                    
                    close();
                }
                else {
                    // Apply gamma if necessary
                    performGammaCorrection(64, 3);
                    
                    run("Duplicate...", "title=duplicate");
                    run("RGB Color");
                    drawSingleLegend("duplicate", i, 0, col);
                    
                    // Save signal channel only
                    saveAs(mipFormat, basedir+'/'+titleSignalMIP+signalIndex);
                    
                    if (numSignals==1) {
                        // This is the only signal, so also save it to the "all signals" MIP
                        saveAs(mipFormat, basedir+'/'+titleSignalMIP);
                    }
                    
                    close();
                    
                    // Add to signal merge
                    all_signal_merge_name += "c" + c + "=" + wname + " ";
                    
                    signalIndex++;
                }   
                
                // Add to all merge
                all_merge_name += "c" + c + "=" + wname + " ";
            }

            if (numSignals>1) {
                // Save all signal channels together
                print("Merging all signals: "+all_signal_merge_name);
                run("Merge Channels...", all_signal_merge_name+" create keep");
                rename("merged");
                    
                run("RGB Color");
                drawAllLegends("merged (RGB)");
                saveAs(mipFormat, basedir+'/'+titleSignalMIP);
                close();
                close("merged");
            }
                
            // Is there a reference channel?
            if (refIndex >= 0) {
            
                print("Creating refsignal MIPs...");
                    
                // Reference channel MIP window name
                refwname = "C" + (refIndex+1) + "-MAX_"+name;
            
                // Get reference channel divisor
                refi = reverseMapping[refIndex];
                divisor = 1;
                if (refi < lengthOf(divspec)) {
                    divisor =  substring(divspec,refi,refi+1);
                }
                
                // Apply reference channel divisor
                if (divisor != '1') {
                    print("Applying divisor "+divisor+" to reference channel");
                    selectWindow(refwname);
                    run("Divide...", "value="+parseInt(divisor));
                }
                
                // Save each signal channel with the reference
                signalIndex = 1;
                for (j=0; j<numOutputChannels; j++) {
                    c = j+1;
                    wname = "C" + c + "-MAX_"+name;
                    i = reverseMapping[j];
                    cc = substring(chanspec,i,i+1);
                    col = substring(colorspec,i,i+1);
                    
                    if (cc!='R') {
                            
                        // Get channel divisor
                        divisor = 1;
                        if (i < lengthOf(divspec)) {
                            divisor =  substring(divspec,i,i+1);
                        }
                        
                        // Apply channel divisor
                        if (divisor != '1') {
                            print("Applying divisor "+divisor+" to channel "+c);
                            selectWindow(wname);
                            run("Divide...", "value="+parseInt(divisor));
                        }
                        
                        // Save signal+reference
                        merge_name = "c1="+wname+" c2="+refwname;
                        print("Merging refsignal: "+merge_name);
                        
                        run("Merge Channels...", merge_name+" create keep");
                        rename("merged");
                        run("RGB Color");
                        
                        drawSingleLegend("merged (RGB)", i, 0, col);
                        saveAs(mipFormat, basedir+'/'+titleRefSignalMIP+signalIndex);
                        close();
                        close("merged");
                        
                        signalIndex++;
                    }
                }
            }
            
            // Save all channels together
            print("Merging all channels: "+all_merge_name);
            run("Merge Channels...", all_merge_name+" create keep");
            rename("merged");
            run("RGB Color");
            
            drawAllLegends("merged (RGB)");
            saveAs(mipFormat, basedir+'/'+titleMIP);
            close();
            close("merged");
        }
        
        // Close all MIP windows
        for (j=0; j<numOutputChannels; j++) {
            c = j+1;
            wname = "C" + c + "-MAX_"+name;
            close(wname);
        }
    }
    
    if (createMovies) {
        print("Creating movies for "+name);
        titleAvi = prefix + "_all.avi";
        titleSignalAvi = prefix + "_signal.avi";
        titleRefAvi = prefix + "_reference.avi";
        
        padImageDimensions(name);
        
        if (refChannels=='1') {
            run("AVI... ", "compression=Uncompressed frame=20 save="+basedir+'/'+titleAvi);
            run("AVI... ", "compression=Uncompressed frame=20 save="+basedir+'/'+titleRefAvi);
        }
        else {
            run("AVI... ", "compression=Uncompressed frame=20 save="+basedir+'/'+titleAvi);
            Stack.setActiveChannels(signalChannels);
            run("AVI... ", "compression=Uncompressed frame=20 save="+basedir+'/'+titleSignalAvi);
            Stack.setActiveChannels(refChannels);
            run("AVI... ", "compression=Uncompressed frame=20 save="+basedir+'/'+titleRefAvi);
        }
    }
        
    close();
}

// Create a gradient bar with 3 labels (min/mid/max)
function gradientBar(bar_x, bar_y, bar_h, bar_w, min, max, font_size) {
    step = 255/bar_h;
    for(i=0; i<bar_h; i++) {
        makeRectangle(bar_x, bar_y+i, bar_w, 1);
        c = 255-i*step;
        setForegroundColor(c,c,c);
        run("Fill","stack");
    }
    c = 255;
    setForegroundColor(c,c,c);
    tx = bar_x+bar_w+5;
    ty = bar_y;
    setFont("SansSerif",font_size,"antialiased");
    makeText(max, tx, ty);
    run("Draw", "stack");
    makeText(round((max-min)/2), tx, (ty+bar_h/2)-(font_size/2));
    run("Draw", "stack");
    makeText(min, tx, (ty+bar_h)-(font_size));
    run("Draw", "stack");
}

// Position is closewise from upper right: 1=upper right, 2=upper left, 3=lower right, 4=lower left
// Index is the current number of legends on the image. For example, when drawing the second legend, set index=1. 
function drawLegend(min_intensity, max_intensity, laser, gain, position, index) {

    annotation_y_offset=30;
    getDimensions(width,height,channels,slices,frames);

    // distance from edge of image
    margin = 5;

    // bar dimensions
    bar_height = 64;
    bar_width = 10;

    // approximate legend dimensions
    lw = 60;
    lh = bar_height+40;

    if (position==1) {
        x = margin + index * (lw + margin);
        y = margin;
    }
    else if (position==2) {
        x = width - margin - lw - index * (lw + margin);
        y = margin;
    }
    else if (position==3) {
        x = width - margin - lw - index * (lw + margin);
        y = height - margin - lh;
    }
    else if (position==4) {
        x = margin + index * (lw + margin);
        y = height - margin - lh;
    }

    gradientBar(x,y,bar_height,bar_width,min_intensity,max_intensity,12);

    text = "";
    if (laser!="") {
        text = text+"Laser: "+laser;
    }
    if (gain!="") {
        text = text+"\nGain: "+gain;
    }
    
    if (text!="") {
        setFont("SansSerif",12,"antialiased");
        makeText(text, x, y+bar_height+10);
        run("Draw", "stack");
    }
    
}

// Draw the legend for the given channel index, at the legend index.
function drawSingleLegend(window_name, i, offset, col) {
    if (displayLegends) {
        cc = substring(chanspec,i,i+1);
        if (cc != 'r') {
        
            // Create a drawing area
            getDimensions(width,height,channels,slices,frames);
            newImage("Legend", "8-bit black", width, height, 1);
            
            // Draw the legend in the correct color
            run(getColorName(col));
            drawLegend(0, maxValues[i], laser, gain, 3, offset);
            run("RGB Color");
            
            // Copy legend over to the target window
            run("Select All");
            run("Copy");
            setPasteMode("Add");
            selectWindow(window_name);
            run("Paste");
            
            close("Legend");
        }
    }
}

// Draw the legends for all the index channels
function drawAllLegends(window_name) {
    if (displayLegends) {
        si = 0;
        for (j=0; j<numOutputChannels; j++) {
            i = reverseMapping[j];
            cc = substring(chanspec,i,i+1);
            col = substring(colorspec,i,i+1);
            if (cc != 'r') {
                drawSingleLegend(window_name, i, si++, col);
            }
        }
    }
}

// Look up color code and return the full name:
// (R)ed, (G)reen, (B)lue, grey(1), (C)yan, (M)agenta, (Y)ellow]
function getColorName(col) {
    if (col=='R') return "Red";
    if (col=='G') return "Green";
    if (col=='B') return "Blue";
    if (col=='1') return "Grays";
    if (col=='C') return "Cyan";
    if (col=='M') return "Magenta";
    if (col=='Y') return "Yellow";
    return "Grays";
}

function padImageDimensions(window_name) {
    selectWindow(window_name);
    getDimensions(width, height, channels, slices, frames);
    if (height % 2 != 0 || width % 2 != 0) {
        print("Adjusting canvas size for "+window_name);
        newWidth = width;
        newHeight = height;
        if (width % 2 != 0) {
            newWidth = width+1;
        }
        if (height % 2 != 0) {
            newHeight = height+1;
        }
        run("Canvas Size...", "width="+newWidth+" height="+newHeight+" position=Top-Center"); 
    }
}

/*
 * Analyzes the given image and returns an array with two values 
 * containing the min and max intensities of the image. For histStretch, this uses
 * values derived from a 1/5 scale MIP of the image. For truehistStretch, 
 * it just uses the values in the regular MIP. 
 */
function getMinMax(window_name) {
    minMax=newArray(2);
    if (histStretch || truehistStretch) {
        selectWindow(window_name);
        getDimensions(width, height, channels, slices, frames);
        run("Z Project...", "projection=[Max Intensity]");
        if (histStretch) { 
            // Yoshi's histogram stretching algorithm uses 25 averaged pixel values
            W = round(width/5);
            run("Size...", "width="+W+" height="+W+" depth=1 constrain average interpolation=Bilinear");
        }
        run("Select All");
        getStatistics(area, mean, min, max, std, histogram);
        close();
        minMax[0] = min;
        minMax[1] = max;
        print("Found range: "+min+"-"+max);
    }
    else {
        minMax[0] = 0;
        minMax[1] = defaultMaxValue;
    }
    return minMax;
}

function performHistogramAdjustment(window_name, minMax) {
    selectWindow(window_name);
    min = minMax[0];
    max = minMax[1];
    print("Performing histogram stretching to range "+min+"-"+max);
    if(bitDepth==16){
        setMinAndMax(min, max);
        run("8-bit");
    } 
    else {
        scalar = 255/max;
        run("Multiply...", "value=scalar stack");
    }
}

function performGammaCorrection(block_size, max_slope) {
    if (gammaCorrection) {
        print("Performing gamma correction with blocksize="+block_size+" and max_slope="+max_slope);
        run("Enhance Local Contrast (CLAHE)", "blocksize=block_size histogram=256 maximum=max_slope");
    }
}

function exportBrightnessCompensationValues(name, outputPrefix) {
    
    // Analyze image
    channelBrightness = getBrightnessArray(name);
    
    // Create CSV string of brightness values
    brightnessCsv = "";
    for(i=0; i<lengthOf(channelBrightness); i++) {
        if (i>0) brightnessCsv += ",";
        brightnessCsv = brightnessCsv + d2s(channelBrightness[i], 3);
    }
    
    // Write brightness values to file
    propertiesFilepath = basedir+"/"+outputPrefix+".properties";
    print("Writing properties file: "+propertiesFilepath);
    File.delete(propertiesFilepath); 
    File.append("image.brightness.compensation="+brightnessCsv, propertiesFilepath);
}

function getBrightnessArray(name) {

    array = newArray(numChannels);
    for (i=0; i<numChannels; i++) {
        cname = "C" + (i+1) + "-" + name;
        array[i] = getBrightness(cname);
    }
    return array;
}

function getBrightness(window_name) {
    
    selectWindow(window_name);
        
    // Specify bit depth as number of intensity values
    nBins = defaultMaxValue+1;
    
    // Fraction of total pixels desired saturated; drives intensity adjustment
    // Saturation fractions probably only work for 2D or 3D, not both
    saturationFraction = 0.0000015;
        
    getDimensions(width, height, channels, slices, frames);
    totalPixels = width * width * slices;
    
    // Number of pixels to count to before identifying max desired intensity prior to adjustment
    pixelsBelowSaturation = totalPixels - (totalPixels * saturationFraction);
    
    run("Clear Results");
    
    // Reset contrast
    setMinAndMax(0, nBins);
    
    // Initialize histogram
    hMin=0;
    
    // Get histogram if 2D image
    if (slices==1) {
        getHistogram(values, counts, nBins, hMin, nBins);
        for (i=0; i<nBins; i++) {
            setResult("Value", i, values[i]);
            setResult("Count", i, counts[i]);
        }
    } 
    else {
        //Get 3D histogram of image
        for (slice=1; slice<=slices; slice++) {
            selectImage(window_name);
            Stack.setSlice(slice);
            if (bitDepth()==8) {
                getHistogram(values, counts, nBins);
            }
            else {
                getHistogram(values, counts, nBins, hMin, nBins);
            }
            for (i=0; i<nBins; i++) {
                if (slice>1) {
                    count = counts[i] + getResult("Count", i);
                } 
                else {
                    count = counts[i];
                }
                setResult("Value", i, values[i]);
                setResult("Count", i, count);
            }
        }
    }
    
    //refresh the results window.
    updateResults();
    
    // Count pixels by intensity until reaching saturation threshold
    pixelCount = 0;
    j = 0;
    while (pixelCount < pixelsBelowSaturation && j < nBins-1) {
        pixelCount += getResult("Count", j);
        j++;
    }
        
    // Get active intensity value when saturation reached
    maxThreshold = getResult("Value", j);
    
    // Can adjust threshold if want to leave some room above it and final maximum intensity
    adjustedThreshold = maxThreshold / 1;
    
    // Calculate ratio of initial to final intensity; Final image is this ratio brighter
    scalingValue = nBins / (adjustedThreshold + 1);

    // Close measurements window
    run("Clear Results");
    selectWindow("Results");
    run("Close");
    
    print(window_name+ " threshold: " + adjustedThreshold);
    return scalingValue;
}

function calcMin(n1, n2) {
    if (n1>n2) return n2;
    return n1;
}

function calcMax(n1, n2) {
    if (n1>n2) return n1;
    return n2;
}
