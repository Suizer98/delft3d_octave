% DELFT3D - tools related to <a href="http://www.delft3d.nl">Delft3d</a>
%
% Delft3D-FLOW and its associated Mastlab toolboxes are  open source since 
% jan 1st 2011, see http://oss.deltares.nl for details. For most OpenEarth 
% Delft3D functionality, you need the official Delft3D Matlab toolbox 
% first. It is part of the official Delft3D release: addpath('C:\Delft3D\w32\matlab\')
% Note functions in the private subfolder only work when you copy
% them one level up. The development version is of this loaded by default as 
% external source into OpenEarthTools, so you already have it:
%
%  delft3d_matlab - Official Delft3D-MATLAB toolbox included as read-only (!) external.
%
% Files
%   d3d_sigma           - Calculates the relative vertical sigma positions in %
%   d3d_z               - Calculates the absolute z-layer positions in m
%   delft3d_grid_image  - Show ASCII image of Delft3D grid matrix
%   delft3d_io_ann      - Read annotation files in a nan-separated list struct (*.ann)  (BETA VERSION)
%
% NEFIS file format related
%   vs_get_constituent_index   - Read index information required to read constituents by name.
%   vs_get_elm_def             - Read NEFIS Element data
%   vs_get_elm_size            - Read size of NEFIS Element data
%   vs_get_grp_def             - Read NEFIS Element data
%   vs_get_grp_size            - Read size of NEFIS Element data
%   vs_time                    - Read time information from NEFIS file
%
% NEFIS map file format related (trim*,dat)
% ! vs_trim2nc                 - Convert part of a Delft3D trim file to netCDF (BETA)
%                                Note that the Rijkswaterstaat 'getData' tool to convert their 
%                                SIMONA SDS files to netCDF can also handle NEFIS files.
%   vs_area                    - read INCORRECT cell areas from com-file.
%   vs_getmnk                  - Read the grid size from NEFIS file.
%   vs_let_scalar              - Read scalar data defined on grid centers from a trim- or com-file.
%   vs_let_vector_cen          - Read U,V vector data to centers from a trim- or com-file.
%   vs_let_vector_cor          - Read U,V vector data to corners from a trim- or com-file.
%   vs_mask                    - Read active/inactive mask of Delft3D results in trim- or com-file.
%   vs_meshgrid2dcorcen        - Read 2D time-independent grid info from NEFIS file.
%   vs_meshgrid3dcorcen        - Read 3D time-dependent grid info from NEFIS file.
%   vs_mnk                     - Read the grid size from NEFIS file.
%   vs_select_deepest_cell     - From z-layer model select locally deepest cell
%   vs_trim_station            - Read timeseries from one location from map file
%
% NEFIS history file format related (trih*,dat)
% ! vs_trih2nc                 - Convert part of a Delft3D trih file to netCDF (BETA)
%                                We recommend use netCDF, and avoid using the slow trih file.
%   adcp_plot                  - plot result as ASCP data
%   vs_trih_crosssection       - Read NEFIS cross-section data for one transect.
%   vs_trih_crosssection_index - Read index NEFIS cross-section properties.
%   vs_trih_station            - Read [x,y,m,n,name] information of history stations (obs point)
%   vs_trih_station_index      - Read index of history station (obs point)
%
% Visualise Delft3D 3D in Matlab
%   delft3d_3d_visualisation_example     - Example to make 3D graphics image
%
% Visualise delft3d input/output in Google Earth:
%   As you can from the number of examples see this is work in progres.
%   We aim to built these tools generically on a netCDF conversion of 
%   the NEFIS trim file. All examples use GooglePlot for basic Google Earth plotting.
%
%   delft3d_grd2kml                      - plot grid, depth as vector objects
%   delft3d_mdf2kml                      - plot also thin dams, dry points, sources and stations as vector objects
%   delft3d_3d2kml_visualisation_example - plot scalar as 3D moving flying carpet + 3D velocities
%   vs_trim2kml                          - plot scaler as 2D tiles
%   vs_trim_to_kml_tiled_png             - plot scaler as 2D tiles (via netCDF)
%   vs_trim2nc2kml                       - plot scaler + the works as 2D objects (via netCDF)
%
% Toolboxes
%   part      - tools related to Delft3D-PART
%   tide      - tools related to Delft3D-TIDE
%   waq       - tools related to Delft3D-WAQ
%   flow      - tools related to Delft3D-FLOW
%   dflowfm   - tools related to D-Flow FM (Flexible Mesh); Flow for unstructured grid
%   delft3d_kelvin_wave - generating frictional kelvin wave boundaries for idealized rectangular models
%
%See also: SWAN, googlePlot, convertcoordinates, flow, waq, python module "openearthtools.io.delft3d"

