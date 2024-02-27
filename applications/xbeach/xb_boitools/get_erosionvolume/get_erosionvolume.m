function [EROVOL,X,Z0,Z1] = get_erosionvolume(x,zi,ze,maxWL)
%
% FUNCTION get_erosionvolume
%
% FUNCTION xbBOI_safetyindicators
%	Returns EROVOL + updated profile data (X,Z0,Z1)
%
%       Input:	[x,zi,ze]   >> initial + erosion profile
%               maxWL       >> max. offshore stormsurge level
%
% ------------------------------------------------------------------------
%   Deze code is ontwikkeld voor het project BOI Zandige Waterkeringen.
%
%   Versie script:      18-02-2022
%
%   Ontwikkeld door:	Deltares & Arcadis
%   Contactpersoon:     Robbin van Santen (Arcadis)
%
%

%% Prepare (function) output
EROVOL      = NaN;
[X,Z0,Z1]   = deal(NaN);

%% Prepare profiles - pre (0) and post (1)

% % Set data precision (to check: is this necessary?)
p           = 8;        % number of decimals in round() >> data = round(data,p)
[x,zi,ze]	= deal(round(x,p),round(zi,p),round(ze,p));

% % Synchronize profiles (add crossings & add maxwl-crossings)
[~,~,x0,z0]  	= findCrossings(x,zi , x([1 end]),[1;1].*maxWL);
[~,~,x1,z1]     = findCrossings(x,ze , x([1 end]),[1;1].*maxWL);
[~,~,X,Z0,~,Z1]	= findCrossings(x0,z0,x1,z1,'synchronizegrids');

% % Profiles above maxwl
[Z0WL,Z1WL]  	= deal(max(maxWL,Z0) , max(maxWL,Z1));

%% Total erosion volume above maxWL
xp              = [X ;flipud(X)];
zpero           = [Z1WL;flipud(max(Z0WL,Z1WL))];
EROVOL          = polyarea(xp,zpero);


%%
return

%%
%% EXAMPLE CODE ::
%%
% % % Calculate erosion volume above maxwl (based on polygons/patches)
% xp          = [X ;flipud(X)];
% 
% % % Erosion and sedimentation (total)
% zperototal  = [Z1;flipud(max(Z0,Z1))];
% zpsedtotal  = [Z1;flipud(min(Z0,Z1))];
% erovoltotal = polyarea(xp,zperototal);
% sedvoltotal = polyarea(xp,zpsedtotal);
% 
% % % Erosion and sedimentation (above maxwl)
% [Z0a,Z1a]	= deal(max(maxWL,Z0),max(maxWL,Z1));
% zpero       = [Z1a;flipud(max(Z0a,Z1a))];
% zpsed       = [Z1a;flipud(min(Z0a,Z1a))];
% erovol      = polyarea(xp,zpero);
% sedvol      = polyarea(xp,zpsed);
% 
% % % Erosion and sedimentation (below maxwl)
% [Z0b,Z1b]	= deal(min(maxwl,Z0),min(maxwl,Z1));
% zperobelow  = [Z1b;flipud(max(Z0b,Z1b))];
% zpsedbelow  = [Z1b;flipud(min(Z0b,Z1b))];
% erovolbelow = polyarea(xp,zperobelow);
% sedvolbelow = polyarea(xp,zpsedbelow);
% 
% % % Plot erosion and sedimation patches
% figure();hold on;grid on;box on
% patch(xp,zperototal, [1. .98 .98], 'EdgeColor','none')
% patch(xp,zpsedtotal, [.98 1. .98], 'EdgeColor','none')
% h1=patch(xp,zpero,   [1. .80 .80], 'EdgeColor','none','disp',['Ero. volume above max. SSL: ' num2str(erovol,'%.1f') ' m^3/m']);
% h2=patch(xp,zpsed,   [.80 1. .80], 'EdgeColor','none','disp',['Sed. volume above max. SSL: ' num2str(sedvol,'%.1f') ' m^3/m']);
% h3=plot(x([1 end]),[1 1].*maxwl,'--b','disp','Max. SSL');
% h4=plot(x,ze,'r','disp','Erosion profile');
% h5=plot(x,zi,'k','disp','Initial profile');
% legend([h1,h2,h5,h4,h3],'Location','NorthWest','Box','off')
% clear h1 h2 h3 h4 h5
