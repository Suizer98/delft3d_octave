function varargout = plotGoF(STATS, varargin)
%PLOTGOF plots target diagram
%
% plots 'Goodness of Fit' target diagramas explained in:
% <a href="http://dx.doi.org/10.1016/j.jmarsys.2008.05.014">Jason K. Jolliff et al., 2009.</a> Summary diagrams for coupled hydrodynamic-
% ecosystem model skill assessment, Journal of Marine Systems 76 (2009) 64-82 .
%
%    plotGoF(STATS)
%
% where STATS is the result of GoFStats:
% STATS = GoFStats(ModelTimePoints, ModelValues, ObsTime, ObsValues, Info);
%
% Example:
% plotGoF(STATS, 'figure', 2);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFSTATS, GOFTIMESERIES, http://dx.doi.org/10.1016/j.jmarsys.2008.05.014

% $Id: plotGoF.m 6849 2012-07-11 07:31:31Z gaytan_sa $
% $Date: 2012-07-11 15:31:31 +0800 (Wed, 11 Jul 2012) $
% $Author: gaytan_sa $
% $Revision: 6849 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/modelvalidation/plotGoF.m $
% $Keywords: $

%% Default values
OPT.figure   = 1;
OPT.R1       = 0.67;
OPT.R2       = 0.1; %radius innermost crcle
OPT.limfct   = 0.1;
OPT.tickvec  = -10:1:10; %default             tickvec=[-3:0.5:3];
OPT.colvec   = ['b', 'r', 'g', 'k'];
%OPT.markvec = ['x'];
OPT.markvec  = ['<'; '+'; 'o'; '*'; 'x'; 's'; 'd'; 'p'; 'h'; '^'; 'v'; '>'];
OPT.mrksiz   = [6; 7; 7; 7; 7; 7; 7; 7; 7; 6; 6; 6];
OPT.xmin     = -2; OPT.xmax = 2;
OPT.ymin     = -2; OPT.ymax = 2;

if nargin==0
   varargout = {OPT};
   return
end
OPT = setproperty(OPT, varargin{:});

%% Plot statistics
figure(OPT.figure);
%%clf('reset');
% set(gcf, 'PaperPositionMode', 'manual');
% set(gcf, 'PaperUnits', 'inches');
% set(gcf, 'PaperPosition', [2 1 4 4]);
hold on;
axis([OPT.xmin OPT.xmax OPT.ymin OPT.ymax]);
set(gca, 'FontSize', 12);
plot(cos(0:0.1:2.1*pi), sin(0:0.1:2.1*pi), '-k', 'LineWidth', 0.5);
plot(0,0,'.k');
plot(sqrt(1-OPT.R1^2)*cos(0:0.1:2.1*pi), ...
    sqrt(1-OPT.R1^2)*sin(0:0.1:2.1*pi), '--k');
xlabel('RMSD''*');
ylabel('Bias*');
iCount = 1;
for iStation = 1:length(STATS)
    if ((isreal(STATS(iStation).xTarget)) && ...
            (STATS(iStation).xTarget >= OPT.xmin) && ...
            (STATS(iStation).xTarget <= OPT.xmax) && ...
            (STATS(iStation).yTarget >= OPT.ymin) && ...
            (STATS(iStation).yTarget <= OPT.ymax))
        iCol = 1 + mod(ceil(iCount/length(OPT.colvec)), ...
            length(OPT.colvec));
        iMark = 1 + mod(iCount, length(OPT.markvec));
        plot(STATS(iStation).xTarget, STATS(iStation).yTarget, ...
            [OPT.colvec(iCol) OPT.markvec(iMark)], ...
            'MarkerFaceColor', OPT.colvec(iCol), ...
            'MarkerSize', OPT.mrksiz(iMark));
        text(STATS(iStation).xTarget, STATS(iStation).yTarget, ...
            ['  ' STATS(iStation).obs_name], ...
            'Color', OPT.colvec(iCol));
        iCount = iCount + 1;
    end
end
hold off;

return;
end
%% EOF