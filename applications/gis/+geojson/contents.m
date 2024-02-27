% GEOJSON  - IETF standard RF7946
%
% GeoJSON is a format for encoding a variety of geographic data structures.
%
%     {
%      "type": "Feature",
%      "geometry": {
%        "type": "Point",
%        "coordinates": [125.6, 10.1]
%      },
%      "properties": {
%        "name": "Dinagat Islands"
%      }
%     }
%
% GeoJSON supports the following geometry types: 
% Point, LineString, Polygon, MultiPoint, MultiLineString, and MultiPolygon. 
% Geometric objects with additional properties are Feature objects. 
% Sets of features are contained by FeatureCollection objects.
%
% line   - create/write line (Feature) from 1D or 2D matrix
% lines  - create/write set of lines (FeatureCollection) from 1D or 2D matrix
% json   - load a geojson
%
%See also: json, http://www.geotools.org/, http://geojson.org/ 