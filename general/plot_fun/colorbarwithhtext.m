function [varargout]=colorbarwithhtext(colorbartxt,varargin)
%COLORBARWITHhTEXT  (re)draws the colorbar with horizontal text inside it.
%
%         colorbarwithhtext(colorbartxt,<ctick>) 
%
%  (re)draws the colorbar with text inside it <with tick marks at positions ctick>.
%
%   [<ax>, h] =colorbarwithhtext(colorbartxt) 
%
%   returns the handle h of the colorbar and optionally the
%   handle ax of the axes. NOTE that with 2 output arguments ax 
%   is returned first to follow the syntax of ax = colorbar.
%   [ax, h,txt] = colorbarwithx(...) returns also the handle of the text object. 
%
%      colorbarwithhtext(colorbartxt,      arguments)
%      colorbarwithhtext(colorbartxt,[]   ,arguments)
%      colorbarwithhtext(colorbartxt,ctick,arguments) 
%
%   passes arguments to colorbar. E.g. to to locate a colorbar 
%   in a pre-defined axis with handle AX, use
%
%      colorbar('position',get(AX,'position'))
%
%   Example:  
%
%      caxis([0 360])
%      [ax, h]=colorbarwithhtext('wind direction',[0:90:360],'horiz') 
%      set(ax,'YTickLabel',{'E','N','W','S'})
%
%      logticks = [1 2 5 10 20 50]
%      clim(logticks([1 end]))
%      [ax, h]=colorbarwithhtext('SPM [mg/l]',logticks,'horiz');
%      set(ax,'xTickLabel',logticks);
%
%   See also: COLORBAR, SET(gca), GET(gca), COLORBARWITHvTEXT,
%             COLORBARWITHxLABEL, COLORBARWITHyLABEL, COLORBARWITHTITLE

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   -------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: colorbarwithhtext.m 14023 2017-12-05 08:34:58Z rho.x $
% $Date: 2017-12-05 16:34:58 +0800 (Tue, 05 Dec 2017) $
% $Author: rho.x $
% $Revision: 14023 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/colorbarwithhtext.m $
% $Keywords: $

% Defaults
    OPT.position = 'text';
    OPT.rotation = 0;
    OPT.peer     = gca;
    OPT.fontsize = 8;
    
% Overrule defaults
OPT2 = setproperty(OPT, varargin, 'onExtraField','silentAppend');

% Filter fields position and rotation from OPT2
OPT.position = OPT2.position;
OPT.rotation = OPT2.rotation;

fields = {'position','rotation'};
OPT2 = rmfield(OPT2,fields);
ctick   = [];
 
%     nextarg = 1;
%     ctick   = [];
% if nargin>1
% 
%     %% note that 0 is also a handle,
%     %% so we cannot use ishandle(), and we use istype()
% 
%     if isnumeric(varargin{1}) & ~istype(varargin{1},'axes');
%     nextarg = 2;
%     ctick   = varargin{1};
%     end    
% 
%     if isempty(varargin{1})
%     nextarg = 2;
%     ctick   = varargin{1}; % [] default
%     end   
%         
%     
% end
% Handles.axes        = colorbar(varargin{nextarg:end});
varargs               = struct2arg(OPT2);
Handles.axes          = colorbar(varargs{:});

Handles.colorbar       = get(Handles.axes,'children');
if     strcmp(OPT.position,'title' );Handles.txt = get(Handles.axes,'title');
elseif strcmp(OPT.position,'xlabel');Handles.txt = get(Handles.axes,'xlabel');
elseif strcmp(OPT.position,'ylabel');Handles.txt = get(Handles.axes,'ylabel');
elseif strcmp(OPT.position,'text'  );
    if verLessThan('matlab','8.5')
        Handles.txt = ...
        text(0.5,0.5,colorbartxt,'units','normalized',...
                              'rotation',OPT.rotation,...
                   'horizontalalignment','center',...
                              'fontsize',OPT.fontsize,...
                                'Parent',Handles.axes);
    else % 2015a: Error using text / While setting the 'Parent' property of Text: / Text cannot be a child of ColorBar.
        newax = axes('position',get(Handles.axes,'position'));
        Handles.txt = ...
        text(0.5,0.5,colorbartxt,'units','normalized',...
                              'rotation',OPT.rotation,...
                   'horizontalalignment','center',...
                              'fontsize',OPT.fontsize,...
                                'Parent',newax);
        set(newax,'XColor','none')
        set(newax,'YColor','none')
        set(newax,'color','none')
    end
end

%for i=1:length(Handles.colorbar)
%   get(Handles.colorbar(i))
%   disp('--------------')
%end

if ~isempty(ctick)
   if isempty(get(Handles.axes,'xtick'))
   set(Handles.axes,'ytick',[ctick]);    
   elseif isempty(get(Handles.axes,'ytick'))
   set(Handles.axes,'xtick',[ctick]);    
   end
end

set(Handles.txt,'string',colorbartxt);

if     nargout==1;varargout={Handles.colorbar};
elseif nargout==2;varargout={Handles.axes,   Handles.colorbar};
elseif nargout==3;varargout={Handles.axes,   Handles.colorbar,Handles.txt};
elseif nargout>3
   error('requires only 0,1,2 or 3 output parameters.');
end
