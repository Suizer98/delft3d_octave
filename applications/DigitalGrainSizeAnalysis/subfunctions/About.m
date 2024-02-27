About

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

This toolbox contains some functions not written by myself:
- idctn.m and dctn.m by Damien Garcia 
(http://www.biomecardio.com/matlab/)
- inpaintn.m by Damien Garcia 
(http://www.mathworks.co.uk/matlabcentral/fileexchange/27994-inpaint-over-missing-data-in-n-d-arrays)
- keep.m by David Yang (http://www.mathworks.co.uk/matlabcentral/fileexchange/181)
- polyfitn.m and polyvaln.m by John D'Errico 
(http://www.mathworks.co.uk/matlabcentral/fileexchange/34765-polyfitn)
- wave_bases.m by  Christopher Torrence and Gilbert P. Compo 
(http://paos.colorado.edu/research/wavelets/)
- highboostfilter.m and normalise.m by Peter Kovesi 
(http://www.csse.uwa.edu.au/~pk/research/matlabfns/)
- popupmessage.m by Samuel Cheng
(http://www.mathworks.co.uk/matlabcentral/fileexchange/7396-display-a-text-file)


The following matlab files are distributed under the MIT software license (http://opensource.org/licenses/MIT):

    subfunctions/highboostfilter.m
    subfunctions/normalise.m
Copyright (c) 1996-2005 Peter Kovesi

    subfunctions/wave_bases.m
Copyright (C) 1995-1998, Christopher Torrence and Gilbert P. Compo

The following matlab files are distributed under the BSD License (http://opensource.org/licenses/BSD-2-Clause)

    subfunctions/polyvaln.m
    subfunctions/polyfitn.m
Copyright (c) 2012, John D'Errico
All rights reserved.

    subfunctions/popupmessage.m
Copyright (c) 2005, Samuel Cheng
All rights reserved.

    subfunctions/dctn.m
    subfunctions/idctn.m
Copyright (c) 2009, Damien Garcia
All rights reserved.

    subfunctions/inpaintn.m
Copyright (c) 2010, Damien Garcia
Copyright (c) 2009, Damien Garcia
All rights reserved.

    subfunctions/keep.m
Copyright (c) 1998-1999,  Xiaoning (David) Yang 
All rights reserved.


History of Algorithm Development:

1. Rubin, D.M. (2004) A simple autocorrelation algorithm for determining grain size from digital 
images of sediment. Journal of Sedimentary Research, 74, 160–165

2. Buscombe, D., Rubin, D.M., and Warrick, J.A. (2010) 
Universal Approximation of Grain Size from Images of Non-Cohesive Sediment. 
Journal of Geophysical Research - Earth Surface 115, F02015

3. Buscombe, D., and Rubin, D.M. (2012) 
Advances in the Simulation and Automated Measurement of Well-Sorted Granular Material, 
Part 2: Direct Measures of Particle Properties. 
Journal of Geophysical Research - Earth Surface 117, F02002

4. Buscombe, D. (2013, in press) 
Transferable Wavelet Method for Grain-Size Distribution from Images of Sediment Surfaces 
and Thin Sections, and Other Natural Granular Patterns
Sedimentology, in press
