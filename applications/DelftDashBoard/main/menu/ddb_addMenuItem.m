function handles = ddb_addMenuItem(handles, menu1, menu2, varargin)
%DDB_ADDMENUITEM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_addMenuItem(handles, menu1, menu2, varargin)
%
%   Input:
%   handles  =
%   menu1    =
%   menu2    =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_addMenuItem
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

sep='off';
chk='off';
enab='on';
longname=[];
callback=[];
argin=[];
tag=[];


HandleName=menu2;

n=nargin-3;
for i=1:n
    if ischar(varargin{i})
        switch lower(varargin{i}),
            case{'callback'}
                callback=varargin{i+1};
            case{'separator'}
                sep=varargin{i+1};
            case{'checked'}
                chk=varargin{i+1};
            case{'handlename'}
                HandleName=varargin{i+1};
            case{'enable'}
                enab=varargin{i+1};
            case{'longname'}
                longname=varargin{i+1};
            case{'argin'}
                argin=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
        end
    end
end

%h=findobj(gcf,'Type','uimenu','Label',menu1);
h=findobj(gcf,'Type','uimenu','Tag',['menu' menu1]);

if isempty(longname)
    lab=menu2;
else
    lab=longname;
end

if ~isempty(argin)
    g=uimenu(h,'Label',lab,'Callback',{callback,argin},'Separator',sep,'Checked',chk,'Enable',enab);
else
    g=uimenu(h,'Label',lab,'Callback',callback,'Separator',sep,'Checked',chk,'Enable',enab);
end

menu1=strrep(menu1,' ','');
menu1=strrep(menu1,'.','');
menu1=strrep(menu1,'-','');
menu1=strrep(menu1,'/','');
HandleName=strrep(HandleName,' ','');
HandleName=strrep(HandleName,'.','');
HandleName=strrep(HandleName,'-','');
HandleName=strrep(HandleName,'/','');
HandleName=strrep(HandleName,'(','');
HandleName=strrep(HandleName,')','');

handles.GUIHandles.Menu.(menu1).Main=h;
handles.GUIHandles.Menu.(menu1).(HandleName)=g;

tg=['menu' menu1 HandleName];
set(g,'Tag',tg);


