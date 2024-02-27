function setfigsize(fh,figwidth,figheight)
%SETfigsize Sets the figure size to fixed values
%
%   Syntax:
%   setfigsize(fh,figwidth,figheight)
%
%   Input:
%   figwidth  = figure width
%   figheight = figure height
%
%   Example
%   set(gcf,'units','centimeters','paperunits','centimeters');
%   setfigsize(gcf,15,10)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 05 Dec 2013
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: setfigsize.m 9873 2013-12-13 09:10:03Z bartgrasmeijer.x $
% $Date: 2013-12-13 17:10:03 +0800 (Fri, 13 Dec 2013) $
% $Author: bartgrasmeijer.x $
% $Revision: 9873 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/setfigsize.m $
% $Keywords: $

%%
OPT.width=15;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT);
%% code

mypp=get(fh,'position'); pp0=mypp([1,2]);
mypp=[mypp(3) mypp(4)];
mypp=mypp*figwidth/mypp(1); mypp(2)=min(mypp(2),figheight);
% set(fh,'position',[0,0,mypp],'color','white');
set(fh,'papersize',[figwidth,mypp(2)],'paperposition',[0,0,mypp]);

