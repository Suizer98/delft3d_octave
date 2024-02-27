''Digital Grain Size Graphical User Interface''
A tool for the automated estimation of size-distribution in images 
of sediment and other granular material

Version 3.0
Written by Daniel Buscombe, various times in 2012 and 2013
while at
School of Marine Science and Engineering, University of Plymouth, UK
then
Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
please contact:
dbuscombe@usgs.gov
for lastest code version please visit:
https://github.com/dbuscombe-usgs
see also (project blog):
http://dbuscombe-usgs.github.com/
====================================
  This function is part of 'dgs-gui' software
  This software is in the public domain because it contains materials that originally came 
  from the United States Geological Survey, an agency of the United States Department of Interior. 
  For more information, see the official USGS copyright policy at 
  http://www.usgs.gov/visual-id/credit_usgs.html#copyright
====================================

%---------------------------------------------------------------
Before you begin:
%---------------------------------------------------------------

This is a program written for MATLAB, therefore you need a copy of the software to use this program at all. 
Please note it is not designed, and will probably not work, for Octave (but I'm working on it)

Please ensure you have the following files in the same directory as the main program, 'dgs_gui.m':

Please do not modify this file structure or move these programs. 
They may be viewed in a text editor and modified (but at your own risk!)


%---------------------------------------------------------------
Brief instructions for use:
%---------------------------------------------------------------

1. Open MATLAB and navigate to this directory, which will be your current working directory (~/DGS_gui). 
This folder can be anywhere on your computer

2. Type 'dgs_gui' (without the apostrophes) in the command window to initiate the program

3. Start by loading images into the program. 
These images can be located anywhere on your computer that you can navigate to

4. Select an image resolution (mm/pixel) by typing into the 'Tools - Set resolution' panel. 
Calculate this by measuring the length in pixels of an object of known size such as a ruler. Press 'Enter'. 
Or you could choose to leave this as 1. This will give you results in units of pixels rather than mm.
You can amend your results at a later date by multiply by mm/pixel

5. Next define the ROI (region of interest) which is the portion of the image you wish to be processed.
Either draw a ROI (or multiple ROIs) on the image by pressing the 'draw ROI' button, or 
else choose the whole image by pressing the 'ROI whole' button.
    
6. Next you have the option to flatten and filter the images. 
Flattening means removing a linear trend surface from the image to remove large wavelengths of light
which can affect the results.
Filtering means using fourier fiters to remove low wavelengths. 
If you choose to filter then you can accept the default parameters (recommended) or use your own (advanced)
Neither of these steps are crucial but you may acheieve better results using them.

7. Next calculate grain size distribution. You can either do this for each image individually or all in one go

8. When the results are in, the grain size distribution will be shown in the bottom right window. 
In the top right window a close-up of the sediment image with a bar the length of the median diameter is drawn

9. Before you exit the program, make you sure you save the results. 
Results are saved as csv files in the output/data folder. The file name will contain the image name, as will the file
You may also choose to print each processed result screen. 
These screenshots will be saved in the output/prints folder

10. To quit the program, use 'File, Quit'. You will be reminded to save results if you have not already done so





