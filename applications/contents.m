% Application-specific tools in <a href="http://www.OpenEarth.eu">OpenEarthTools</a>
%
% OpenEarthTools application-specific toolboxes.
%
% GUIS for model pre-and postprocessing
%   DelftDashBoard     - DelftDashBoard
%   muppet             - GUI for postprocessing of delft3d and other models
%   d3d_qp             - Official GUI for <a href="http://www.delft3d.nl">Delft3d</a> and many other models/datafiles.
%
% Libraries for model pre-and postprocessing
%   delft3d            - model: <a href="http://www.delft3d.nl">Delft3d</a>
%   delft3d_matlab     - external include of official <a href="https://svn.oss.deltares.nl/repos/delft3d/trunk/src/tools_lgpl/matlab/quickplot/progsrc">Delft3D matlab toolbox</a> (no write access allowed)
%   sobek              - model: <a href="http://www.SOBEK.nl">SOBEK</a>
%   SWAN               - model: <a href="http://www.SWAN.tudelft.nl">SWAN</a>  (see also: waves)
%   xbeach             - model: <a href="http://XBeach.org">XBeach</a>
%
% Coastal morphology and sediment transport
%   CoastalMorphologyModeling - exercises/examples of <a href="http://www.worldscientific.com/worldscibooks/10.1142/7712">Roelvink & Reniers, 2011</a>
%   cmg                       - tools from <a href="http://marine.usgs.gov/">Coastal Morphology Group of USGS</a>
%   cosmos                    - framework to run operational combinations of nested models
%   detran                    - GUI for postprocessing of delft3d sediment transport
%   DuneErosionLibrary        - general dune erosion library
%   TASS                      - model: <a href="http://dredgingdays.org/content.asp?page=6&owner=3">Turbidity Assessment Software</a>
%   DUROS                     - model: duros
%   durosta                   - model: durosta
%   pontos                    - model: <a href="http://www.alkyon.nl/Tools/Pontos.htm">PonTos</a>
%
% Data processing
%   grid_2D_orthogonal - library to use    tiled sets of orthogonal netCDF grids
%   nc_processing      - library to create tiled sets of orthogonal netCDF grids, generation 1: to be phased out
%   nc_gen             - library to create tiled sets of orthogonal netCDF grids, generation 2: recommended
%   UCIT               - GUI     to use    tiled sets of orthogonal netCDF grids (Universal Coastal Intelligence Toolkit)
%   KNMI               - download and parse datasets from <a href="http://www.knmi.nl">KNMI</a> 
%   Rijkswaterstaat    - download and parse datasets from <a href="http://www.Rijkswaterstaat.nl">Rijkswaterstaat</a> 
%   *  JarKus          - JarKus coastal profiles bathymetry dataset
%   *  vaklodingen     - vaklodingen coastal bathymetry dataset
%   *  MATROOS         - operational <a href="http://matroos.deltares.nl/">MATROOS</a> datasets
%   OceanDataView      - library for working with datasets from <a href="http://www.SeaDataNet.org">www.SeaDataNet.org</a>, <a href="http://www.nodc.nl">www.nodc.nl</a>.
%   oceancolor         - library for working with datasets from <a href="http://modis.gsfc.nasa.gov/">MODIS</a>, <a href="http://oceancolor.gsfc.nasa.gov/SeaWiFS/">SeaWiFS</a>, <a href="http://envisat.esa.int/instruments/meris/">MERIS</a>
%
% Dedicated toolboxes
%   bzip               - bzip compression/decompression <a href="http://www.bzip.org">www.bzip.org</a>
%   dineof             - tools to perform EOF analysis on time series of matrices
%   FEWS-World         - visualize <a href="http://vanbeek.geo.uu.nl/suppinfo/vanbeekbierkens2009.pdf">PCR-GLOBWB </a> hydrological climate scenarios
%   knowledgegraphs    - tool to make knowledgegraphs
%   modelvalidation    - tools to make Taylor model performance diagrams
%   probabilistic      - application
%   statistic          - frequency of exceedance toolbox
%   netica             - tools for Bayesian software <a href="http://www.norsys.com/">NETICA</a>
%   textpad            - program: <a href="http://www.textpad.com">textpad</a>
%   tide               - tidal analysis and associated tools incl.
%    t_tide            - <a href="http://www.eos.ubc.ca/~rich/#T_Tide">t_tide</a>
%    UTide             - <a href="http://www.po.gso.uri.edu/~codiga/utide/utide.htm">UTtide</a>
%   waves              - waves related functions (see also: swan)
%
% GIS & Google Earth
%   arcgis             - tools to read Arc ASCII Grid Format
%   ldbTool            - GUI to manipulate land boundaryes (coastlines, shapefiles)
%   mm                 - multimedia tools
%   m_map              - viewer: mapping toolbox <a href="http://www.eos.ubc.ca/~rich/map.html">m_map</a> from Rich Pawlowicz.
%   googlePlot         - viewer: Google Earth Toolbox, with options for curvi-linear grids
%   SuperTrans         - GUI     for global coordinate transformations
%   convertcoordinates - library for global coordinate transformations
%
% See also: OpenEarthTools: general, io

% Except for the see also line this file '../applications/contents.m' is the same as:
% '../applications/oet_applications.m'