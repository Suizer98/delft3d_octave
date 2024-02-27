function html = tooltiphtml(varargin);
%TOOLTIPHTML  return html code for tooltip 
%
%  fews.tooltiphtml(<keyword,value>)
%
%See also: FEWS 
      
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares for internal Eureka competition.
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: tooltiphtml.m 8389 2013-03-29 07:42:24Z boer_g $
% $Date: 2013-03-29 15:42:24 +0800 (Fri, 29 Mar 2013) $
% $Author: boer_g $
% $Revision: 8389 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+fews/tooltiphtml.m $
% $Keywords$


OPT.ID      = 1;
OPT.name    = 1;
OPT.max     = 1;
OPT.timeIn  = [];
OPT.timeOut = [];
OPT.eol     = '';

OPT = setproperty(OPT,varargin);
      
   html    = [...
   '<html>',OPT.eol,...
   '<table bordercolor="blue" bgcolor="white" border="0">',OPT.eol];
   
   if OPT.ID
   html = [html,'<tr>',OPT.eol,...
   '	<td width="100" valign="top">ID</td>',OPT.eol,...
   '	<td width="5" valign="top">:</td>',OPT.eol,...
   '	<td width="200" valign="top">%ID%</td>',OPT.eol,...
   '</tr>',OPT.eol];
   end
   
   if OPT.name
   html = [html,'<tr>',OPT.eol,...
   '	<td width="100" valign="top">Name</td>',OPT.eol,...
   '	<td width="5" valign="top">:</td>',OPT.eol,...
   '	<td width="200" valign="top">%NAME%</td>',OPT.eol,...
   '</tr>',OPT.eol];
   end
   
   if OPT.max
   html = [html,'<tr>',OPT.eol,...
   '	<td width="100" valign="top">Maximum value</td>',OPT.eol,...
   '	<td width="5" valign="top">:</td>',OPT.eol,...
   '	<td width="200" valign="top">%MAXIMUM_VALUE%</td>',OPT.eol,...
   '</tr>',OPT.eol,...
   '<tr>',OPT.eol,...
   '	<td width="100" valign="top">Time (max val.)</td>',OPT.eol,...
   '	<td width="5" valign="top">:</td>',OPT.eol,...
   '	<td width="200" valign="top">%MAXIMUM_VALUE_TIME%</td>',OPT.eol,...
   '</tr>',OPT.eol];
   end
   
   if ~isempty(OPT.timeIn)
   html = ...
   [html,'<tr>',OPT.eol,...
   '	<td width="100" valign="top">Start time</td>',OPT.eol,...
   '	<td width="5" valign="top">:</td>',OPT.eol,...
   '	<td width="200" valign="top">',datestrnan(OPT.timeIn,29,' '),'</td>',OPT.eol,...
   '</tr>',OPT.eol];
   end
   
   if ~isempty(OPT.timeOut)
   html = ...
   [html,'<tr>',OPT.eol,...
   '	<td width="100" valign="top">End time</td>',OPT.eol,...
   '	<td width="5" valign="top">:</td>',OPT.eol,...
   '	<td width="200" valign="top">',datestrnan(OPT.timeOut,29,' '),'</td>',OPT.eol,...
   '</tr>',OPT.eol];
   end

   html = [html,'</table>',OPT.eol,'</html>'];
