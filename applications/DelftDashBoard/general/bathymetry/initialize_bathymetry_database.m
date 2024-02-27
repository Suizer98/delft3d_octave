function initialize_bathymetry_database(varargin)

global bathymetry

if ~isempty(varargin)
    dr=varargin{1};
else
    dr='d:\delftdashboard\data\bathymetry\';
end

% Get metadata from bathymetry databases
% if isempty(bathymetry)
    bathymetry.dir=dr;
    if ~exist(bathymetry.dir,'dir')
        error(['Bathymetry database folder ' bathymetry.dir ' does not exist !']);
    end
    bathymetry=ddb_findBathymetryDatabases(bathymetry);
% end
