function TASS_plotOverflow_drg(varargin)
% TASS_PLOTOVERFLOW_DRG  Routine to read the overflow output file
%
%   Routine reads a overflow output file (*.drg) produced by TASS model.
%   The routine takes a filename as an input file. Output produced is an
%   array with data and a variable with column 
%
%   Syntax:
%       [data, data_info, data_units] = TASS_plotOverflow_drg(varargin)
%
%   Input:
%   For the following keywords, values are accepted (values indicated are the current default settings):
%       'filename', []                  = passive plume output filename
%
%   Output:
%       data                            = 6 column array with output data
%       data_info                       = cell array with column information
%       data_units                      = cell array with column units
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 22 Feb 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: TASS_plotOverflow_drg.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tass/TASS_plotOverflow_drg.m $
% $Keywords: 

%TODO: adapt to more detailed fractions

%% defaults
OPT = struct( ...
    'fh', [], ...
    'ah', [], ...
    'column', [], ...
    'data', [], ...
    'data_info', [], ...
    'data_units', [] ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if isempty(OPT.fh)
    OPT.fh = figure(1); clf; hold on
    OPT.ah = gca;
end
figure(OPT.fh)
axes(OPT.ah)

ph(1) = plot(OPT.data(:,1),OPT.data(:,OPT.column),'displayname','b','displayname',[OPT.data_info{OPT.column} ' [' OPT.data_units{OPT.column} ']' ]);

title(OPT.data_info{OPT.column})
xlabel([OPT.data_units{1}])
ylabel([OPT.data_units{OPT.column}])

lh = legend(ph);
set(lh,'location','NorthWest','fontsize',8);

box on
