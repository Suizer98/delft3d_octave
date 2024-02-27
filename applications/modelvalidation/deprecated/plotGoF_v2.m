function varargout = plotGoF_v2(STATS, varargin)
%PLOTGOF plots target diagram
%
% plots 'Goodness of Fit' target diagramas explained in:
% <a href="http://dx.doi.org/10.1016/j.jmarsys.2008.05.014">Jason K. Jolliff et al., 2009.</a> Summary diagrams for coupled hydrodynamic-
% ecosystem model skill assessment, Journal of Marine Systems 76 (2009) 64-82 .
%
%    plotGoF(STATS)
%
% where STATS is the result of GoFStats:
% STATS = GoFStats(D3DTimePoints, D3DValues, NetCDFTime, NetCDFValues, Info);
%
% Example:
% plotGoF(STATS, 'figure', 2);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFSTATS, GOFTIMESERIES, http://dx.doi.org/10.1016/j.jmarsys.2008.05.014

% $Id: plotGoF_v2.m 7255 2012-09-20 12:30:02Z blaas $
% $Date: 2012-09-20 20:30:02 +0800 (Thu, 20 Sep 2012) $
% $Author: blaas $
% $Revision: 7255 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/modelvalidation/deprecated/plotGoF_v2.m $
% $Keywords: $

%% Default values
load Data.mat %load matfile from GoFStats_v2.m or when directly used after GoFStats_vs, no need and comment load.

stations=fieldnames(Data);

substances={'E','N','NH4','NO3','O2','P','PO4','SiO2','concentration_of_chlorophyll_in_water','concentration_of_suspended_matter_in_water',...
    'sea_water_salinity'};

for isubs=1:length(substances) %loop over substances
    OPT.figure   = 1;
    OPT.R1       = 0.67;
    OPT.R2       = 0.1; %radius innermost crcle
    OPT.limfct   = 0.1;
    OPT.tickvec  = -10:1:10; %default             tickvec=[-3:0.5:3];
    OPT.colvec   = ['b', 'r', 'g', 'k'];
    OPT.markvec  = ['<'; '+'; 'o'; '*'; 'x'; 's'; 'd'; 'p'; 'h'; '^'; 'v'; '>'];
    OPT.mrksiz   = [6; 7; 7; 7; 7; 7; 7; 7; 7; 6; 6; 6];
    OPT.xmin     = -2; OPT.xmax = 2;
    OPT.ymin     = -2; OPT.ymax = 2;
    
    
    %% Plot statistics
    figure(isubs);
    hold on;
    axis([OPT.xmin OPT.xmax OPT.ymin OPT.ymax]);
    set(gca, 'FontSize', 12);
    plot(cos(0:0.1:2.1*pi), sin(0:0.1:2.1*pi), '-k', 'LineWidth', 0.5);
    plot(0,0,'.k');
    plot(sqrt(1-OPT.R1^2)*cos(0:0.1:2.1*pi), ...
        sqrt(1-OPT.R1^2)*sin(0:0.1:2.1*pi), '--k');
    xlabel('RMSD''*');
    ylabel('Bias*');
    
    if strcmpi(substances{isubs},'concentration_of_chlorophyll_in_water')
        title('Chlfa');
    elseif strcmpi(substances{isubs},'sea_water_salinity')
        title('Salinity');
        elseif strcmpi(substances{isubs},'concentration_of_suspended_matter_in_water')
        title('TIM');
    else
        title(substances{isubs});
    end
    
    iCount = 1;
    for iStation = 1:length(stations)
        
        if isfield(Data.(stations{iStation}),substances{isubs})
            
            if ((isreal(Data.(stations{iStation}).(substances{isubs}).xTarget)) && ...
                    (Data.(stations{iStation}).(substances{isubs}).xTarget >= OPT.xmin) && ...
                    (Data.(stations{iStation}).(substances{isubs}).xTarget <= OPT.xmax) && ...
                    (Data.(stations{iStation}).(substances{isubs}).yTarget >= OPT.ymin) && ...
                    (Data.(stations{iStation}).(substances{isubs}).yTarget <= OPT.ymax))
                iCol = 1 + mod(ceil(iCount/length(OPT.colvec)), ...
                    length(OPT.colvec));
                iMark = 1 + mod(iCount, length(OPT.markvec));
                plot(Data.(stations{iStation}).(substances{isubs}).xTarget, Data.(stations{iStation}).(substances{isubs}).yTarget, ...
                    [OPT.colvec(iCol) OPT.markvec(iMark)], ...
                    'MarkerFaceColor', OPT.colvec(iCol), ...
                    'MarkerSize', OPT.mrksiz(iMark));
                text(Data.(stations{iStation}).(substances{isubs}).xTarget, Data.(stations{iStation}).(substances{isubs}).yTarget, ...
                    ['  ' Data.(stations{iStation}).(substances{isubs}).obs_name], ...
                    'Color', OPT.colvec(iCol));
                iCount = iCount + 1;
            end
        end
    end
    
    hold off;
    print(['GOF_' substances{isubs} '.png'], '-dpng');
    close
    
end

%% EOF
