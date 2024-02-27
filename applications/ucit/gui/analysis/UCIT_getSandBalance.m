function UCIT_getSandBalance(OPT)
% UCIT_INPUTSANDBALANCE This script computes a sediment budget for all polygons
%                       that are listed in the polygon directory. They are subdivided
%                       per UCIT datatype folder (see example). The year with best coverage
%                       is used as reference year.
%
%   Syntax:     UCIT_getSandBalance
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
%   See also getSandbalance, UCIT_findCoverage, batchViewResults

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
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

warningstate = warning;
warning off


%% define postprocessing

postProcessing              = 1; % 0 = off; 1 = on ;
whattodo(1)                 = 1; % volume plots

%% initial settings

OPT.type  = 1;
curdir    = pwd;
counter   = 0;

%% set defaults

if nargin == 0
    OPT.datatype     = 'jarkus';
    OPT.thinning     = 1;
    OPT.monthsmargin = 12;
    OPT.inputyears   = [2000:2003];
    OPT.min_coverage = 70;
end

%% add metadata to OPT
OPT = UCIT_getMetaData(OPT);

for n = 1:size(OPT.min_coverage,2)
    
    %% make dirs for output
    mkdir([curdir filesep 'datafiles' filesep 'timewindow = ',num2str(OPT.timewindow)]);
    mkdir([curdir filesep 'coverage'  filesep 'timewindow = ' num2str(OPT.timewindow)]);
    mkdir([curdir filesep 'results'   filesep 'timewindow = ' num2str(OPT.timewindow) filesep 'ref=' num2str(OPT.min_coverage(n)) ])
    
    %% get coverage
    batchvar = UCIT_findCoverage(OPT);
    
    if ~isempty(batchvar)
        for i = 1:size(batchvar,1)
            if batchvar{i,1}==1
                disp(['*** Processing ' batchvar{i,3} ' - coverage percentage: ' num2str(OPT.min_coverage(n)) '% with timewindow: ',num2str(OPT.timewindow),' months'])
                
                %% load polygon        
                OPT.polygon = landboundary('read',[OPT.polydir filesep OPT.polyname{i}]);

                %% load coverage
                [OPT.inputyears, OPT.coverages] = textread(['coverage' filesep 'timewindow = ' num2str(OPT.timewindow) filesep num2str(OPT.polyname{i}(1:end-4)) '_coverage.dat'],'%f%f','headerlines',1);
                OPT.inputyears = OPT.inputyears(OPT.coverages*100 > OPT.min_coverage);
                OPT.coverages  = OPT.coverages (OPT.coverages*100 > OPT.min_coverage);
                
                if ~isempty(OPT.inputyears)
                    
                    %% determine reference year
                    OPT.reference_year = OPT.inputyears(find(OPT.coverages == max(OPT.coverages),1,'first'));
                    
                    %% find ids that are present in all years (for method 2 JdR)
                    for j = 1:length(OPT.inputyears)
                        load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep OPT.polyname{i}(1:end-4) '_' num2str(OPT.inputyears(j),'%04i') '_1231.mat']);
                        id_of_year  = ~isnan(d.Z);
                        if j == 1,OPT.id = id_of_year;,else,
                            OPT.id = OPT.id & id_of_year;,end
                    end
                    
                    %% compute volume
                    for k = 1 : 2 % use 2 methods
                        OPT.type = k;
                        for j = 1:size(OPT.inputyears,1)
                            results = UCIT_computeGridVolume(OPT.reference_year, OPT.inputyears(j), OPT.polyname{i}(1:end-4), OPT);
                            VolumeOverview(j,1) = results.year;
                            VolumeOverview(j,2) = results.volume;
                            VolumeOverview(j,3) = OPT.coverages(j);
                            VolumeOverview(j,4) = results.area;
                            VolumeOverview(j,5) = results.volume/results.area;
                        end
                        
                        Volumes{k} = VolumeOverview;
                        
                        %% write text file
                        fid = fopen([ 'results' filesep 'timewindow = ' num2str(OPT.timewindow) filesep 'ref=' num2str(OPT.min_coverage(n)) filesep  OPT.polyname{i}(1:end-4) '_volume_development_method' num2str(OPT.type) '.dat'],'w');
                        fprintf(fid,'%s\n',[' Year      Volume     Coverage     Area     Vol/Area']);
                        fprintf(fid,'%5.0f %12.0f %9.2f   %9.0f %9.2f \n',[VolumeOverview]');
                        fclose(fid);
                        clear VolumeOverview
                    end
                    %% Make volume plot
                    if postProcessing && whattodo(1)
                        UCIT_plotSandbalance(OPT, results, Volumes);
                    end
                    
                    if strcmp(curdir,getenv('TEMP'))
                        delete([getenv('TEMP') '\polygons\*.*']);
                        delete([getenv('TEMP') '\datafiles\' 'timewindow = ' num2str(OPT.timewindow) '\*.*']);
                        delete([getenv('TEMP') '\coverage\' 'timewindow = ' num2str(OPT.timewindow) '\*.*']);
                        delete([getenv('TEMP') '\results\' 'timewindow = ' num2str(OPT.timewindow)  '\ref=' num2str(OPT.min_coverage(n))  '\*.*' ]);
                    else
                        disp(['Data written to: ' pwd '\results']);
                    end
                else
                    errordlg(['Selected minimal coverage for ' OPT.polyname{i}(1:end-4) ' too high!']);
                    disp('No data written; coverage criteria too high!')
                end
            end
        end
    end
  %  clear OPT results volumes
end

warning(warningstate)

%% EOF