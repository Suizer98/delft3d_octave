function XBRV_play(varargin)
%XBRV_PLAY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   XBRV_play(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   XBRV_play
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@Deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: XBRV_play.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBRV/XBRV_play.m $
% $Keywords: $

%%
h = guidata(varargin{1});

ddd = h.plotspec.ddd;
if ddd
    id = ':';
else
    id = 2;
end

frnrend = varargin{end};
frnrbeg = varargin{end-1};

ss = false;
if any(strcmpi(varargin,'set'))
    frnrend = frnrbeg;
    ss = true;
end

if ~isnumeric(frnrend) || ~isnumeric(frnrbeg)
    return
end

XB = get(h.fig,'UserData');
XB = XB(h.plotspec.currentdataset);

minn = min(min(min(XB.Output.zb(:,id,:))));

for i=frnrbeg:h.plotspec.dframes:frnrend
    tic
    if ~get(h.control.startpause,'Value') && ~ss
        return
    end
    title(h.plotax,['it = ' num2str(i)]);
    if ddd
        set(h.plothan.hpw,'Zdata',XB.Output.zs(:,id,i));
        set(h.plothan.hpb,'Zdata',XB.Output.zb(:,id,i));
    else
        set(h.plothan.hpw,'Ydata',[minn; XB.Output.zs(:,id,i); minn]);
        set(h.plothan.hw,'YData',XB.Output.zs(:,id,i));
        set(h.plothan.hpb,'Ydata',[minn; XB.Output.zb(:,id,i); minn]);
        set(h.plothan.hb,'YData',XB.Output.zb(:,id,i));
    end
    if h.plotspec.hrmson && ~ddd
        try
            set(h.plothan.hrms1,'YData',XB.Output.Hrms(1:h.plotspec.thin:end,id,i)./2+XB.Output.zs(1:h.plotspec.thin:end,id,i));
            set(h.plothan.hrms2,'YData',-XB.Output.Hrms(1:h.plotspec.thin:end,id,i)./2+XB.Output.zs(1:h.plotspec.thin:end,id,i));
        catch
            set(h.plothan.hrms1,'YData',XB.Output.H(1:h.plotspec.thin:end,id,i)./2+XB.Output.zs(1:h.plotspec.thin:end,id,i));
            set(h.plothan.hrms2,'YData',-XB.Output.H(1:h.plotspec.thin:end,id,i)./2+XB.Output.zs(1:h.plotspec.thin:end,id,i));
        end
    end
    set(h.control.slider,'Value',i);
    drawnow
%     if savemovie
%         filenames{i,1} = [calcdir filesep 'movie_' num2str(count) filesep calcdir(max(strfind(calcdir,filesep))+1:end) '_it_' num2str(i,'%05i') '.png'];
%         print(filenames{i,1},'-dpng','-zbuffer','-r200');
%     end
    pause(h.plotspec.dt-toc);
end

if ~ss
    set(h.control.startpause,'Value',0,...
        'String','play')
end