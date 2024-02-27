function [cbd] = colorbardiscrete(colorbartitle,levels,varargin)
%COLORBARDISCRETE(colorbartitle,levels) draws a colorbar with discrete
% colors right of the current axes. The number of colors is the same as the
% number of levels. Useful with contourf. 
%WARNING: colorbardiscrete modifies the colormap. Combining several plots
%or applying this function multiple times can lead to unexpected results. 
%
%
%
%   Input:
%       colorbartitle:    title above the colorbar (string)
%       levels:           levels of discrete colors (vector). To include values above
%						  and below the highest and lowest level add respectively
% 						  Inf and -Inf to the levels.
%					
%   Optional keywords
%       unit:       unit string added to the colorbar labels, e.g. 'm/s'
%       fmt:        format string for labels (see SPRINTF for details)
%       dx:         width of the color patches (default is 0.03)
%       dy:         height of the color patches (default is 0.03)
%       hor:        horizontal colorbar position right of peer axes (default is 0)
%       ver:        horizontal colorbar position right of peer axes (default is 0)
%       fontsize:   label fontsize (default is 7)
%       peer:       axes to with which the colorbar should be associated (default
%                   is the current axes)
%       fixed:      uses the fixed colors from the colormap (no
%                   interpolation)
%       yticklabel: cell array of strings with user defined yticklabels
%       reallevels: vector with real levels (changes the labels to these
%                   levels)
%	New optional keywords
%		reclass: 	 if true the color of the class does not depend on the value of the class, but
%					 on its index. (e.g. first class gets first color from colormap).  
%       nrofcolornew:colorbardiscrete generates a new colormap that consists of nrofcolornew colors. 
%					 For correct functioning ( dLevel/(clim(2)-clim(1)) ) >> 1/nrofcolornew. Use NaN
%					 for automatic calculation of this number (default: NaN). 
%
%   Output:
%   cbd = axes handle to the discrete colorbar
%
%% Example 1
%       figure
%       mypeaks = peaks(20); mylevels = [-Inf,-8 -6 -4 -2 0 2 4 6 7,Inf];
%       [c,h] = contourf(mypeaks,mylevels);
%       colorbartitle = 'peaks';
%       cbd = colorbardiscrete(colorbartitle,mylevels);
%       axpos = get(gca,'position'); set(gca,'position',axpos+[-0.05 0 0 0]);
%       cbdpos = get(cbd,'position'); set(cbd,'position',cbdpos+[-0.05 0 0 0]);
%
%% Example 2
%       figure; ax1 = subplot(2,1,1);
%       mypeaks = peaks(20); mylevels1 = [-8 -6 -4 -2 0 2 4 6 7];
%       [c,h] = contourf(mypeaks,mylevels1);
%       colorbartitle = 'peaks';
%       cbd1 = colorbardiscrete(colorbartitle,mylevels1,'unit','m/s','fmt','%6.2f','peer',ax1);
%       ax1pos = get(ax1,'position'); set(ax1,'position',ax1pos+[-0.07 0 0 0]);
%       cbd1pos = get(cbd1,'position'); set(cbd1,'position',cbd1pos+[-0.07 0 0 0]);
%
%% Example 3
%       figure;
%       mylevels = [-10 -5 0 .6 .8 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 10.0];
%       [X,Y,Z] = peaks;
%       Z = reclass(Z,mylevels);
%       pcolor(X,Y,Z);
%       shading flat;
%       mymap = colormap(jet(length(mylevels)-1));
%       clim([1,length(mylevels)]);
%       axis equal; axis tight;
%       hold on;
%       colorbardiscrete('test',[1:length(mylevels)-1],'fixed',true,'reallevels',mylevels);
%
%% Example 4
%       mylevels = [-10 -5 0 .6 .8 1.0 1.25 1.5 1.75 2.0 2.5 3.0 3.5 10.0];
%       [X,Y,Z] = peaks;
%       pcolor(X,Y,Z);
%       shading flat;
%       mymap = colormap(jet(length(mylevels)-1));
%       clim([-10,10]);
%       axis equal; axis tight;
%       hold on;
%       colorbardiscrete('test',mylevels,'reclass',true);
%
%   See also contourf, reclass

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: colorbardiscrete.m 8829 2013-06-18 15:30:20Z ivo.pasmans.x $
% $Date: 2013-06-18 23:30:20 +0800 (Tue, 18 Jun 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8829 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/colorbardiscrete.m $
% $Keywords: $

%% input arguments
levels=reshape(levels,1,[]); 
OPT.fmt = '%6.1f';
OPT.dx = 0.03;
OPT.dy = 0.03;
OPT.hor = 0;
OPT.ver = 0;
OPT.fontsize = 7;
OPT.peer = gca;
OPT.unit = '';
OPT.fixed = false;
OPT.reallevels = [];
OPT.yticklabel = [];
OPT.reclass=true; 
OPT.nrofcolornew=NaN;
OPT.color='k';
[OPT OPTused]=setproperty(OPT,varargin); 

%% read settings from peeraxes
axes(OPT.peer);
cl = clim;
mycolors = colormap;

%% determine colors to be used

%derive colors for the classes from colormap
if OPT.fixed
	%use only the colors in the colormap
    if length(levels)==size(mycolors,1)
		mycolors=[mycolors;mycolors(end,:)]; 
        mydiscretecolors = mycolors(1:end-1,:); 
		if ~isinf(levels(end))
			levels=[levels,Inf]; 
		end
		%scale levels
		levelsCscaled=(levels-cl(1))/(cl(end)-cl(1));
    else
        error('Number of classes should be equal to number of colors if fixed is used.');
    end
else	
	%scale levels such that clim(1)=0 and clim(2)=1
	nrofcolorlevels=size(mycolors,1); 
	if size(mycolors,1)<2
		error('Colormap must contain at least 2 colors.'); 
	else
		colorlevels=[0:1/(nrofcolorlevels-1):1]; 
		levelsCscaled=(levels-cl(1))/(cl(end)-cl(1));
	end
	
	if ~OPT.reclass
		%use mean class limits to determine color class
		meanLevel=0.5*levelsCscaled(1:end-1)+0.5*levelsCscaled(2:end); 
	else
		%interpolate colorscaling from colormap using class index
		if length(levels)<=2
			meanLevel=0.5;
		else
			meanLevel=[0:1/(length(levels)-2):1];
		end
	end
	
	%clip levels outside the colorscaling
	if max(meanLevel)>1 | min(meanLevel)<0
		warning(sprintf('Colors have been clipped. Check if clim settings are ok.')); 
		meanLevel=max(meanLevel,0); 
		meanLevel=min(meanLevel,1);
	end	
	
	%interpolate colorscaling
	mydiscretecolors=interp1(colorlevels,mycolors,meanLevel);
	mydiscretecolors=max(min(mydiscretecolors,1),0); 
	 
end

%Calculate the number of colors in the new colormap if nrofcolornew==NaN
if isnan(OPT.nrofcolornew)
	OPT.nrofcolornew=round(20/min(diff(levelsCscaled))); 
end 

%% create new colormap
colorlevelsnew=[0:1/OPT.nrofcolornew:1-1/OPT.nrofcolornew]; 
colormapnew=nan(length(colorlevelsnew),3); 


for i=1:length(levelsCscaled)-1
	iclass=colorlevelsnew>=levelsCscaled(i);
	if sum(iclass)>0
		colormapnew(iclass,:)=repmat(mydiscretecolors(i,:),[sum(iclass) 1]); 
	end
end
%set color for all values below minimum levels
iclass=colorlevelsnew<=min(levelsCscaled(~isinf(levelsCscaled)));
if sum(iclass)>0
	colormapnew(iclass,:)=repmat(mycolors(1,:),[sum(iclass) 1]); 
end
%set color for all values above maximum level
iclass=colorlevelsnew+1/OPT.nrofcolornew>=max(levelsCscaled(~isinf(levelsCscaled)));
if sum(iclass)>0
	colormapnew(iclass,:)=repmat(mycolors(end,:),[sum(iclass) 1]); 
end
colormap(colormapnew);

nv = length(levels);
nc = size(mydiscretecolors,1);

%% save position of countour plot frame

%  determine position of coordinate system of for legend
pos = get(gca,'position');
outerpos=get(gca,'outerposition');
unt = get(gca,'units');
factor = ( nc*OPT.dy + (nc-1)* 0.25 * OPT.dy) / pos(4);

% make sure that legend does not become larger than contour plot
if factor>1
    OPT.dy = OPT.dy/factor ;
    factor = 1  ;
end

%  set legend hor to the right of the contour plot
posnew = [pos(3)+pos(1)+OPT.hor,pos(2)+OPT.ver,pos(3),factor*pos(4)];
%
hold on; 
cbd = axes('units',unt,'Position', posnew,'visible','off'); axis equal; hold on 


%manually set labels
if ~isempty(OPT.reallevels)
    for i = 1:length(OPT.reallevels)-1
       OPT.yticklabel{i} = [num2str(OPT.reallevels(i)) '-' num2str(OPT.reallevels(i+1))];
    end
    
end

x  = 0; y  = 0;
if (nc == nv-1)
	%number of colors in colorscaling is correct
    for i=1:nc
        %patch color rectangle
        xp = [x, x+OPT.dx, x+OPT.dx, x, x];
        yp = [y, y,    y+OPT.dy, y+OPT.dy, y];
        patch(xp,yp,1e13*ones(size(xp)),mydiscretecolors(i,:),'EdgeColor',OPT.color);
        
        %place texts for v-ranges
        if isempty(OPT.yticklabel)
            if (i==1 & levels(1)==-Inf)
                label= ['<',num2str(levels(2),OPT.fmt),' ',OPT.unit];
			elseif (i==nc & levels(nc+1)==Inf)
				label=  ['>',num2str(levels(i),OPT.fmt),' ',OPT.unit]; 
            else
                label = [num2str(levels(i),OPT.fmt),' - ',num2str(levels(i+1),OPT.fmt),' ',OPT.unit];
            end
        else
            label = OPT.yticklabel{i};
        end
        %
        text (x+1.5*OPT.dx,y,100,label, ...
            'color',OPT.color,...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','bottom','FontSize',OPT.fontsize,'erasemode','background','visible','on');
        
        y = y + 1.25*OPT.dy;
    end
else
    error('Mismatch length values-colors');
end

x_lim = get(gca,'xlim');
lenx = diff(x_lim);
set(cbd,'xlim',[-0.01 lenx],'visible','off');
text(0,y+1*OPT.dy,100,colorbartitle,'FontSize',OPT.fontsize,'erasemode','background','visible','on');
%
% reset handle of figure to contour plot
%
axes(OPT.peer);

return