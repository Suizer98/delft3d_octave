%DINEOF Matlab wrapper for DINEOF
%
% DINEOF is an EOF-based method to fill in missing data from  
% geophysical fields, such as clouds in sea surface temperature. 
%
% For more information on how DINEOF works, please refer to 
% <a href="http://dx.doi.org/10.1016/j.ocemod.2004.08.001">Alvera-Azcarate et al (2005)</a> and <a href="http://dx.doi.org/10.1175/1520-0426(2003)020<1839:ECADFF>2.0.CO;2">Beckers and Rixen (2003)</a>. 
% The multivariate application of DINEOF is explained in 
% <a href="dx.doi.org/10.1029/2006JC003660">Alvera-Azcarate et al (2007)</a>, and in <a href="dx.doi.org/10.5194/osd-3-735-2006">Beckers et al (2006)</a> the
% error calculation using an optimal interpolation approach is explained.
% To use this DINEOF Matlab toolbox please download DINEOF.exe 3.0 
% from http://modb.oce.ulg.ac.be/mediawiki/index.php/DINEOF and
% put it in the DINEOF matlab toolbox directory
% \OpenEarthTools\matlab\applications\+dineof\
%
% This DINEOF toolbox uses the native matlab netcdf toolbox
% availble since R2008b. DINEOF itself is also shipped with a Matlab 
% toolbox, that depends on the Octave netcdf toolbox through:
% http://modb.oce.ulg.ac.be/mediawiki/index.php/NetCDF_toolbox_for_Octave
% This has the same syntax as the outdated, unsupported netcdf toolbox
% in mexcdf (http://sourceforge.net/projects/mexcdf/)
%
% high-level
%   run                            - run DINEOF (via memory, without explicit file IO)
%   display                        - display DINEOF results with plot
%   L2bin2nc                       - write netCDF file of image time series fit for DINEOF
%
% low-level
%   init                           - initialises     DINEOF setings
%   initread                       - reads file with DINEOF setings
%   initwrite                      - saves file with DINEOF setings
%   unpack                         - explode vector to full matrix using and apply land mask
%
%See also: 