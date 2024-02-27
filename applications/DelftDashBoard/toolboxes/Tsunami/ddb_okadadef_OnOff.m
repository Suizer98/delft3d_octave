function ddb_okadadef_OnOff()
%DDB_OKADADEF_ONOFF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_okadadef_OnOff(())
%
%   Input:
%   () =
%
%
%
%
%   Example
%   ddb_okadadef_OnOff
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_okadadef_OnOff.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/ddb_okadadef_OnOff.m $
% $Keywords: $

%%
global Mw        lat_epi     lon_epi    fdtop      totflength fwidth   disloc     foption

h1 = findobj(gcbo);
ival = get(h1,'Value');

nsg = str2num(get(findobj(gcf,'tag','Nseg'), 'string'));
if (isempty(nsg))
    nsg = 0;
end
if (ival == 0.0)
    set(h1,'tag','SeismoOkada','string','Fault unrelated to epicentre','SelectionHighlight','off');
    foption='Fault unrelated to EQ';
else
    if (nsg == 1)
        set(h1,'tag','SeismoOkada','string','Centre fault around epicentre','SelectionHighlight','on');
        foption='Centre Fault around EQ epicentre';
    elseif (nsg==0)
        set(h1,'Value',0)
        foption='Fault unrelated to EQ';
    end
end

