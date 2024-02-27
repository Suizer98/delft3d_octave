function S=streakbar(X,Y,U,V,unit,colmap,varargin)
% H=streakbar(X,Y,U,V,unit) creates a colorbar for (but not exclusively)
% the function streakarrow.
% The arrays X and Y defines the coordinates for U and V.
% U and V are the same arrays used for streakarrow.
% The string variable unit is the unit of the vector magnitude
% Example:
%   streakbar(X,Y,U,V,'m/s')

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jan 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: streakbar.m 10053 2014-01-22 14:07:31Z bartgrasmeijer.x $
% $Date: 2014-01-22 22:07:31 +0800 (Wed, 22 Jan 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 10053 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/streakbar.m $
% $Keywords: $

%%

colormap(colmap)
Vmag=sqrt(U.^2+V.^2);

OPT.min=min(Vmag(:));
OPT.max=max(Vmag(:));
OPT.fontsize = 8;
OPT.shiftx = 0.02;
OPT.topclabel = [];
% return defaults (aka introspection)
% if nargin>6;
%     varargout = {OPT};
%     return
% end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

% Vmin=min(Vmag(:)); Vmax=max(Vmag(:));
Vmin = OPT.min;
Vmax = OPT.max;

P=get(gca,'position');
%axes('position',[P(1)+P(3)+.02  P(2)+0.01  .01  P(4)-0.02]')
axes('position',[P(1)+P(3)+OPT.shiftx  P(2)  .02  P(4)/2]')
[X,Y]=meshgrid( [0 1], linspace(Vmin,Vmax,64));
Q= [1:64; 1:64];
S=pcolor(X', Y',Q); shading flat; set(gca,'XTickLabel',[],  'Yaxislocation',...
    'right','fontsize',OPT.fontsize)
% clim([Vmin Vmax]);
tit = title(unit);
set(tit,'Position',[0.9 OPT.max+0.05*(OPT.max-OPT.min) 1]); %set(tit,'Position',[0.4167 0.002 1]);
if ~isempty(OPT.topclabel)
    clabels = {get(gca,'YTickLabel')};
    clabels{1}(end,1:length(OPT.topclabel)) = OPT.topclabel;
    set(gca,'YTickLabel', clabels{1})
end

