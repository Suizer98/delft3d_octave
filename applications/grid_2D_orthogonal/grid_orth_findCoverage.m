function [batchvar, OPT] = grid_orth_findCoverage(OPT, n)
%GRID_ORTH_FINDCOVERAGE  Finds data coverages in netcdf database for arbitrary number of polygons
%
%
%   Syntax:     batchvar    =   findCoverage(datatype, ref_cov, timewindow)
%
%   Input:      datatype    =   type of data
%               ref_cov     =   minimal coverage treshold for a year to be used in the budget computation
%               timewindow  =   number of months to look back for additional data
%
%   Output:     batchvar    =   a list of years to be used for the budget
%                               conmputation
%               coverage    =   the coverage per year is stored in the
%                               coverage directory
%
%   See also grid_orth_getSandbalance, grid_orth_findCoverage, UCIT_batchViewResults

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
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

% $Id: grid_orth_findCoverage.m 4356 2011-03-26 13:59:39Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-26 21:59:39 +0800 (Sat, 26 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4356 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_findCoverage.m $
% $Keywords: $

warningstate = warning;
warning off

%% identify which polygons are availabel in the polygon directory
fns = dir(fullfile(OPT.polygondir, '*.mat'));
if isempty(fns)
    warning on
    warning('grid_orth_findCoverage:noPolygonsAvailable', ...
        'No polygons available in polygon directory')
    OPT = grid_orth_getOverview(OPT);
    OPT = grid_orth_getPolygon(OPT);

    fns = dir(fullfile(OPT.polygondir, '*.mat'));
    if isempty(fns)
    warning on
    warning('grid_orth_findCoverage:noPolygonsAvailable', ...
        'You need to make sure a saved polygon is available!')
    return
    end
end

%% Set input for sandbalance
%  executeyes/no, thinning, polyname, plotcolor, linewidth, years
if ~isempty(fns)
    % find mapurls
    if isempty(OPT.urls)
        OPT = mergestructs(OPT,grid_orth_getMapInfoFromDataset(OPT.dataset));
    end
    
    % initialise temporary batchvar1
    for r = 1:length(fns)
        batchvar1(r,:) = {1,OPT.datathinning, fns(r,1).name(1:end-4)     , 'b', 1, [] }; %#ok<AGROW>
    end
    
    % get coverage
    for i = 1:size(batchvar1,1)
        if batchvar1{i,1}==1
            multiWaitbar('Gathering coverage info (per polygon) ...',i/size(batchvar1,1), 'Color', [1.0 0.4 0.0])

            % load polygon from polygon directory
            load(fullfile(OPT.polygondir, fns(i,1).name));
            
            if ~exist(fullfile(OPT.workdir, 'coverage', ['timewindow = ' num2str(OPT.searchinterval)], [fns(i,1).name(1:end-4) '_coverage.dat']),'file')
                if isempty(OPT.inputtimes)
                    OPT.polygon = polygon; %#ok<NODEF>
                    OPT = grid_orth_getTimeInfoInPolygon(OPT);
                end
                if ~isempty(OPT.starttime)
                    OPT.inputtimes = OPT.inputtimes (OPT.inputtimes>= OPT.starttime);
                end
                if ~isempty(OPT.stoptime)
                    OPT.inputtimes = OPT.inputtimes (OPT.inputtimes<= OPT.stoptime);
                end
                for j = 1:length(OPT.inputtimes)
                    
                    if exist(fullfile(OPT.workdir, 'datafiles', ['timewindow = ' num2str(OPT.searchinterval)], [fns(i,1).name(1:end-4) '_' datestr(OPT.inputtimes(j)) '.mat']),'file')
                        multiWaitbar('Collecting data (each timestep per polygon) ...',j/length(OPT.inputtimes), 'Color', [0.1 0.5 0.8], 'Label', 'Collecting data (from cached results) ...')
                        load(fullfile(OPT.workdir, 'datafiles', ['timewindow = ' num2str(OPT.searchinterval)], [fns(i,1).name(1:end-4) '_' datestr(OPT.inputtimes(j)) '.mat']));
                    else
                        multiWaitbar('Collecting data (each timestep per polygon) ...',j/length(OPT.inputtimes), 'Color', [0.1 0.5 0.8], 'Label', 'Collecting data (from OpenDap server) ...')
                        [X, Y, Z, Ztime] = grid_orth_getDataInPolygon(...
                            'dataset'       , OPT.dataset, ...
                            'starttime'     , OPT.inputtimes(j), ...
                            'searchinterval', OPT.searchinterval, ...
                            'datathinning'  , OPT.datathinning,...
                            'plotresult'    , 0, ...
                            'polygon'       , polygon, ...
                            'urls'          , OPT.urls, ...
                            'x_ranges'      , OPT.x_ranges, ...
                            'y_ranges'      , OPT.y_ranges);
                        
                        in = inpolygon(X, Y, polygon(:,1), polygon(:,2));
                        d.name              = fns(i,1).name(1:end-4);
                        d.time              = OPT.inputtimes(j);
                        d.X                 = X;
                        d.Y                 = Y;
                        d.Z                 = Z;
                        d.Ztemps            = Ztime;
                        d.inpolygon         = in;
                        
                        save(fullfile(OPT.workdir, 'datafiles', ['timewindow = ' num2str(OPT.searchinterval)], [d.name '_' datestr(d.time) '.mat']),'d');
                    end
                    
                    % compute coverage
                    total                   = sum(sum(d.inpolygon));
                    cov(j).year             = sum(sum((~isnan(d.Z))))/total; %#ok<AGROW> % coverage per jaar voor polygoon j
                    results(j,:)            = ([OPT.inputtimes(j) cov(j).year]); %#ok<AGROW>
                end
                
                % scale coverage info so that the maximum coverage is set to 100 %
                maxCov                      = max(results(:,2));
                covfactor                   = 100/maxCov(1);
                results(:,2)                = results(:,2).*covfactor;
                
                % save to text file
                fid = fopen(fullfile(OPT.workdir , 'coverage' , ['timewindow = ' num2str(OPT.searchinterval)], [num2str(d.name) '_coverage.dat']),'w');
                fprintf(fid,'%s\n','Year      Coverage');
                fprintf(fid,'%5.0f %9.2f\n',results');
                fclose(fid);
                
            else
                % step waitbar quickly because here all timesteps are gathered at once from a cached file
                multiWaitbar('Collecting data (each timestep per polygon) ...', 0.5, 'Color', [0.1 0.5 0.8], 'Label', 'Collecting data (from cached results) ...')
                [results(:,1),results(:,2)] = textread(fullfile(OPT.workdir, 'coverage', ['timewindow = ' num2str(OPT.searchinterval)], [num2str(fns(i,1).name(1:end-4)) '_coverage.dat']),'%f%f','headerlines',1);
                multiWaitbar('Collecting data (each timestep per polygon) ...', 1.0, 'Color', [0.1 0.5 0.8], 'Label', 'Collecting data (from cached results) ...')
            end
            
            %% generate best years
            yearstemp                       = unique( results( results(:,2) >= OPT.min_coverage(n) ,1)' );
            
            if ~isempty(yearstemp)
                % create batchvar
                bestyear                    = results(find(max(results(:,2)),1,'first'),1);
                yearsofgoodcov              = {yearstemp}; % dit moet cell array zijn, anders omdat bij elke i een andere grootte: Subscripted assignment dimension mismatch
                batchvar(i,:)               = {1, OPT.datathinning, fns(i,1).name(1:end-4) , 'g', 1, yearsofgoodcov, find(yearsofgoodcov{:}==bestyear,1,'first')}; %#ok<AGROW>
                
            else
                disp([fns(i,1).name(1:end-4), ' - No years found matching coverage criteria']);
%                 batchvar = [];
            end
            clear results;
        end
    end
end

warning(warningstate)

%% EOF
