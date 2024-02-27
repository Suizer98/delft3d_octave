% Toolbox for ESRI (http://www.esri.com/) ArcGis data files
%
% GRID files: ascii
%  info: both:   http://en.wikipedia.org/wiki/Esri_grid
%  info: ascii:  http://www.gdal.org/frmt_various.html#AAIGrid
%  arcgrid              - (delft3d_matlab toolbox) read grid file        [(x=1,y=1) at Upper Left as in GIS]
%  ArcGisRead           - Read gridded data set in Arc ASCII Grid Format [(y=1,x=1) at Upper Left as in GIS]
%  arc_asc_read         - Read gridded data set in Arc ASCII Grid Format [(y=1,x=1) at Lower Left as in math]
%  arcgridwrite         - save gridded data set in ArcGIS ASCII format
%  arcgridread          - (matlab mapping toolbox) Read gridded data set in Arc ASCII Grid Format
%
% GRID files: binary
%  info: binary: http://support.esri.com/en/knowledgebase/techarticles/detail/30616
%  info: binary: http://home.gdal.org/projects/aigrid/aigrid_format.html
%  arc_info_binary      - Read gridded data set in Arc Binary Grid Format (*.adf)
%  arc_info_binary2kml  - Example script to save ESRI grid (ascii or adf) file as kml
%
% SHAPE files: 
%  info: http://www.gdal.org/ogr/drv_shapefile.html
%  info: http://www.esri.com/library/whitepapers/pdfs/shapefile.pdf
%
%  m_shaperead          - read shapefiles (part of m_map, native m code)
%  shape                - open, read and write shape file (part of delf3d, native m code)
%  arc_shape_read       - Read vector features and attributes, does not yet handle char attributes (mex code)
%  shapeinfo            - (matlab mapping toolbox) Information about shapefile
%  shaperead            - (matlab mapping toolbox) Read vector features and attributes from shapefile
%  shapewrite           - (matlab mapping toolbox) Write geographic data structure to shapefile
%
%  arc_shape2kml        - save ESRI shape file as Google Earth file
%  ldbTool              - FYI: GUI interface for manipulation shape files (aka landboundaries)
%
% OGC WEB SERVICES
%  wms                  - construct and validate OGC WMS request from Web Mapping Service server 
%  wcs                  - construct and validate OGC WCS request from Web Coverage Service server 
%  wfs                  - construct and validate OGC WFS request from Web Feature Service server 
%
%See also: convertCoordinates, googlePlot, nc_cf_grid, nc_cf_gridset, grid_2D_orthogonal
