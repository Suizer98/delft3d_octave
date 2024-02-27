function D = nc_cf_harvest_tuple2matrix(d,varargin)
%NC_CF_HARVEST_TUPLE2MATRIX  convert meta-data tuple-array to struct with matrices
%
%  matrix = nc_cf_harvest_tuple2matrix(tuple,matrix,i) adss tuple to matrix
%  at position
%
%See also: nc_cf_harvest, nc_cf_harvest_matrix2tuple

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011-2013 Deltares for Nationaal Modellen en Data centrum (NMDC),
%                           Building with Nature and internal Eureka competition.
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_cf_harvest_tuple2matrix.m 11827 2015-03-24 14:02:38Z gerben.deboer.x $
% $Date: 2015-03-24 22:02:38 +0800 (Tue, 24 Mar 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11827 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/nc_cf_harvest/nc_cf_harvest_tuple2matrix.m $
% $Keywords$

OPT.featuretype   = 'timeseries';    %'timeseries' % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries
OPT.platform_id   = 'platform_id';   % CF-1.6, older: 'station_id'  , harvested when OPT.featuretype='timeseries'
OPT.platform_name = 'platform_name'; % CF-1.6, older: 'station_name', harvested when OPT.featuretype='timeseries'

nextarg = 1;
if nargin > 1
   D = varargin{1};nextarg = 2;
   if isempty(D)
   D = nc_cf_harvest_matrix_initialize(1);
   end
   else
   D = nc_cf_harvest_matrix_initialize(1);
end

if nargin > 2
   i = varargin{2};nextarg = 3;
   else
   i = 1;
end

OPT = setproperty(OPT,varargin{nextarg:end});

% URL

        D.number_of_observations                  (i) = d.number_of_observations;
        D.urlPath                                 {i} =                d.urlPath;
        D.dataSize                                (i) =               d.dataSize;
        D.date                                    (i) =                   d.date;

% What: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#controlledVocabulary   

        D.Conventions{i}   =      d.Conventions;
        D.variable_name{i} = ['"',str2line(d.variable_name,'s','" "'),'"']; % can contain spaces, ...
        D.standard_name{i} = ['"',str2line(d.standard_name,'s','" "'),'"']; % or be empty, ...
        D.units{i}         = ['"',str2line(d.units        ,'s','" "'),'"']; % so embrace with brackets, ...
        D.long_name{i}     = ['"',str2line(d.long_name    ,'s','" "'),'"']; % and reverse with strtokens2cell

% Where: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#geospatialCoverage

        D.geospatialCoverage_northsouth_start     (i) = d.geospatialCoverage.northsouth.start     ;
        D.geospatialCoverage_northsouth_size      (i) = d.geospatialCoverage.northsouth.size      ;
        D.geospatialCoverage_northsouth_resolution(i) = d.geospatialCoverage.northsouth.resolution;
        D.geospatialCoverage_northsouth_end       (i) = d.geospatialCoverage.northsouth.end       ;

        D.geospatialCoverage_eastwest_start       (i) = d.geospatialCoverage.eastwest.start       ;
        D.geospatialCoverage_eastwest_size        (i) = d.geospatialCoverage.eastwest.size        ;
        D.geospatialCoverage_eastwest_resolution  (i) = d.geospatialCoverage.eastwest.resolution  ;
        D.geospatialCoverage_eastwest_end         (i) = d.geospatialCoverage.eastwest.end         ;

        D.geospatialCoverage_updown_start         (i) = d.geospatialCoverage.updown.start         ;
        D.geospatialCoverage_updown_size          (i) = d.geospatialCoverage.updown.size          ;
        D.geospatialCoverage_updown_resolution    (i) = d.geospatialCoverage.updown.resolution    ;
        D.geospatialCoverage_updown_end           (i) = d.geospatialCoverage.updown.end           ;

        D.geospatialCoverage_x_start              (i) = d.geospatialCoverage.x.start              ;
        D.geospatialCoverage_x_size               (i) = d.geospatialCoverage.x.size               ;
        D.geospatialCoverage_x_resolution         (i) = d.geospatialCoverage.x.resolution         ;
        D.geospatialCoverage_x_end                (i) = d.geospatialCoverage.x.end                ;

        D.geospatialCoverage_y_start              (i) = d.geospatialCoverage.y.start              ;
        D.geospatialCoverage_y_size               (i) = d.geospatialCoverage.y.size               ;
        D.geospatialCoverage_y_resolution         (i) = d.geospatialCoverage.y.resolution         ;
        D.geospatialCoverage_y_end                (i) = d.geospatialCoverage.y.end                ;

% When: http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/v1.0.2/InvCatalogSpec.html#timeCoverage

        D.timeCoverage_start                      (i) = d.timeCoverage.start     ;
        D.timeCoverage_duration                   (i) = d.timeCoverage.duration  ;
        D.timeCoverage_resolution                 (i) = d.timeCoverage.resolution;
        D.timeCoverage_end                        (i) = d.timeCoverage.end       ;

% Timeseries

   if strcmpi(OPT.featuretype,'timeseries')

        D.number_of_observations(i)   =    d.number_of_observations;
        D.(OPT.platform_id){i}   =    d.(OPT.platform_id);
        D.(OPT.platform_name){i} =    d.(OPT.platform_name);

   end

%           D.projectionEPSGcode{i} =     d.projectionEPSGcode;
%                        D.title{i} =                  d.title;
%                  D.institution{i} =            d.institution;
%                       D.source{i} =                 d.source;
%                      D.history{i} =                d.history;
%                   D.references{i} =             d.references;
%                        D.email{i} =                  d.email;
%                      D.comment{i} =                d.comment;
%                      D.version{i} =                d.version;
%                  D.Conventions{i} =            d.Conventions;
%                D.terms_for_use{i} =          d.terms_for_use;
%                   D.disclaimer{i} =             d.disclaimer;
