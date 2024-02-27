% OpenEarth SWAN toolbox.
% SWAN is the TU Delft Civil Engineering Department spectral wave model
% Simulating Waves Near Shore, available at http://swan.tudelft.nl
% 
%SWAN semantics
% swan_defaults                  - returns SWAN default SET settings
% swan_keyword                   - read swan keywords from text line 
% swan_keyword2longname          - get SWAN long  name (OVLNAM) from associated SWAN code (OVKEYW)
% swan_keyword2shortname         - get SWAN short name (OVSNAM) from associated SWAN code (OVKEYW)
% swan_keyword2texname           - get SWAN LaTeX name (TEXNAM) from associated SWAN code (OVKEYW)
% swan_quantity                  - returns default properties of SWAN output parameters
% swan_quantitytex               - returns LaTaX names of SWAN output parameters
% swan_shortname2keyword         - get SWAN SWAN code (OVKEYW) from associated short name (OVSNAM)
%
%SWAN mesh file IO (note latest release also has netCDF files)
% swan_io_bot                    - read/write SWAN ASCII bottom file
% swan_io_grd                    - read/write SWAN ASCII grid file  
% swan_io_ele                    - read/write SWAN/triangular unstructured element file
% swan_io_node                   - read/write SWAN/triangular unstructured node file  
%
%SWAN data file IO (note latest release also has netCDF files)
% swan_io_table                  - read SWAN ASCII output table
% swan_io_mergesp2               - Merge multiple sp2 files into 1 sp2 file
% swan_io_spectrum               - Read SWAN 1D or 2D spectrum file
% swan_io_spectrum_write         - Writes a 1D SWAN spectrum file
%
%SWAN netCDF: the latest SWAN writes netCDF-CF for spectra and blocks
% swan_io_table2nc               - Writes a SWAN ASCII output table to netCDF-CF file (SWAN does not write netCDF for tables)
% swan_io_spectrum2nc            - Writes a SWAN 1D or 2D spectrum file to netCDF-CF file (same as SWAN does)
%
%SWAN input files
% swan_io_input                  - read SWAN input file into struct (to automate postprocessing)
%
%SWAN parameters calculation incl. high-freq. tail (energy not present in spectral matrix)
% swan_hs                        - calculates significant wave height from wave spectrum as in SWAN
% swan_tm01                      - calculates average absolute period Tm01 from wave spectrum as in SWAN
% swan_tm02                      - calculates average absolute period Tm01 from wave spectrum as in SWAN
%
%SWAN plotting
%pcolor_spectral                 - plot directional spectrum in polar coordinates
%
%Boundary conditions:
% ftp://polar.ncep.noaa.gov/history/waves/README
%
%See also: waves, xbeach, delft3d
