function OPT = grid_orth_getSandBalance(varargin)
%GRID_ORTH_GETSANDBALANCE  This script computes a sediment budget for an indicated dataset for all polygons that are listed in a polygon directory. 
%
%  They are subdivided per UCIT datatype folder (see example). The year
%  with best coverage is used as reference year.
%
%   Syntax:     grid_orth_getSandBalance
%
%   Input:      polygons     =   specified in polygons directory
%               ref          =   minimal coverage treshold for a year to be used in the budget computation
%               monthsmargin =   number of months to look back for additional data
%
%   Output:     RAW: Output is stored in files. The coverage of each polygon is
%               stored in the 'polygon' directory. The depth data is stored
%               in 'datafiles' and the temporal sediment budget is stored in
%               'results'.
%               POSTPROCESSING: Separate scripts visualize the results. See
%               different types of plots at postprocessing.
%
%   See also UCIT_findCoverage, batchViewResults

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares, TUDelft
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vanKoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_getSandBalance.m 4356 2011-03-26 13:59:39Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-26 21:59:39 +0800 (Sat, 26 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4356 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getSandBalance.m $
% $Keywords: $

% TODO: make the search process more efficient by inventorying the available years.
% TODO: a number of input variable in the OPT struct are obsolete (such as OPT.cellsize ... check and remove)

warningstate = warning;
warning off %#ok<WNOFF>

%% set defaults
OPT.dataset                 = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
OPT.tag                     = [];
OPT.ldburl                  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir                 = pwd;
OPT.polygondir              = [pwd filesep 'polygons'];
OPT.polygon                 = [];
OPT.cellsize                = [];                               % cellsize is assumed to be regular in x and y direction and is determined automatically
OPT.datathinning            = 1;                                % stride with which to skip through the data
OPT.inputtimes              = [];                               % starting points (in Matlab epoch time)
OPT.starttime               = [];                               % indicate datenum to start sediment budget calculation
OPT.stoptime                = [];                               % indicate datenum to stop sediment budget calculation
OPT.searchinterval          = -30;                              % acceptable interval to include data from (in days)
OPT.min_coverage            = .25;                              % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult              = 1;                                % 0 = off; 1 = on;
OPT.warning                 = 1;                                % 0 = off; 1 = on;
OPT.postProcessing          = 1;                                % 0 = off; 1 = on;
OPT.postProcessingFcn       = @(OPT, results, Volumes, n) grid_orth_plotSandbalance(OPT, results, Volumes, n);
OPT.whattodo(1)             = 1;                                % volume plots
OPT.type                    = 1;
OPT.counter                 = 0;
OPT.urls                    = [];
OPT.x_ranges                = [];
OPT.y_ranges                = [];
OPT.intervals               = []; % entry needed for adding dredging and dumping data
OPT.polynames               = []; % entry needed for adding dredging and dumping data
OPT.data                    = []; % entry needed for adding dredging and dumping data

OPT = setproperty(OPT, varargin{:});

if isempty(OPT.tag); OPT.tag = OPT.dataset; end

%% generate sediment budget information
for n = 1:size(OPT.min_coverage,2)
    % make dirs for output
    mkpath(OPT.polygondir);
    mkpath([OPT.workdir filesep 'datafiles' filesep 'timewindow = ',num2str(OPT.searchinterval)]);
    mkpath([OPT.workdir filesep 'coverage'  filesep 'timewindow = ' num2str(OPT.searchinterval)]);
    mkpath([OPT.workdir filesep 'results'   filesep 'timewindow = ' num2str(OPT.searchinterval) filesep 'ref=' num2str(OPT.min_coverage(n)) ])
    
    % get coverage info
    [batchvar, OPT] = grid_orth_findCoverage(OPT, n);
    
    % find polygons directory
    fns = dir(fullfile(OPT.polygondir,'*.mat'));
    
    if ~isempty(batchvar)
        for i = 1:size(batchvar,1)
            multiWaitbar('Processing end results (per polygon) ...',i/size(batchvar,1), 'Color', [0.2 0.9 0.3])
            if batchvar{i,1}==1
                disp(' ')
                disp(['*** Processing ' batchvar{i,3} ' - coverage percentage: ' num2str(OPT.min_coverage(n)) '% with timewindow: ',num2str(OPT.searchinterval),' days'])
                
                load(fullfile(OPT.polygondir, fns(i,1).name));
                OPT.polygon = polygon;
                
                % load coverage
                [OPT.inputtimes, OPT.coverages] = textread(fullfile(OPT.workdir, 'coverage', ['timewindow = ' num2str(OPT.searchinterval)], [num2str(fns(i,1).name(1:end-4)) '_coverage.dat']),'%f%f','headerlines',1);
                OPT.inputtimes = OPT.inputtimes(OPT.coverages > OPT.min_coverage(n));
                OPT.coverages  = OPT.coverages (OPT.coverages > OPT.min_coverage(n));
                
                if isempty(OPT.inputtimes)
                    OPT = grid_orth_getTimeInfoInPolygon(OPT);
                end
                
                if ~isempty(OPT.inputtimes)
                    % determine reference year
                    OPT.reference_year = OPT.inputtimes(find(OPT.coverages == max(OPT.coverages),1,'first'));
                    
                    % find ids that are present in all years (for method 2 JdR)
                    for j = 1:length(OPT.inputtimes)
                       
                        load([OPT.workdir filesep 'datafiles' filesep 'timewindow = ' num2str(OPT.searchinterval) filesep fns(i,1).name(1:end-4) '_' datestr(OPT.inputtimes(j)) '.mat']);
                        id_of_year  = ~isnan(d.Z);
                        if j == 1
                            OPT.id = id_of_year;
                        else
                            OPT.id = OPT.id & id_of_year;
                        end
                    end
                    
                    % compute volume
                    [VolumeOverview, Volumes] = deal([]);
                    for k = 1 : 2 % use 2 methods
                        OPT.type = k;
                        for j = 1:size(OPT.inputtimes,1)
                            results = grid_orth_computeGridVolume(OPT.reference_year, OPT.inputtimes(j), fns(i,1).name(1:end-4), OPT);
                            VolumeOverview(j,1) = results.year;  %#ok<*AGROW>
                            VolumeOverview(j,2) = results.volume;
                            VolumeOverview(j,3) = results.coverage;
                            VolumeOverview(j,4) = results.area;
                            VolumeOverview(j,5) = results.volume/results.area;
                        end
                        
                        Volumes{k} = VolumeOverview;
                        
                        % write text file
                        fid = fopen([OPT.workdir filesep 'results' filesep 'timewindow = ' num2str(OPT.searchinterval) filesep 'ref=' num2str(OPT.min_coverage(n)) filesep fns(i,1).name(1:end-4) '_method' num2str(OPT.type) '.dat'],'w');
                        fprintf(fid,'%s\n',' Year      Volume     Coverage     Area     Vol/Area');
                        fprintf(fid,'%5.0f %12.0f %9.2f   %9.0f %9.2f \n', VolumeOverview');
                        fclose(fid);
                    end
                    
                    % make volume plots
                    if OPT.postProcessing && OPT.whattodo(1)
                        OPT.postProcessingFcn(OPT, results, Volumes, n);
                    end
                    disp(['Data written to: ' OPT.workdir '\results']);
                else
                    errordlg(['Selected minimal coverage for ' fns(i,1).name(1:end-4) ' too high!']);
                    disp('No data written; coverage criteria too high!')
                end
                
            end
        end
    end
end

warning(warningstate)

%% EOF