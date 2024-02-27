function XB = XB_read_bcfile(XB, varargin)
%XB_READ_BCFILE  read XBeach wave boundary conditions input file
%
%   Routine to read wave boundary conditions file for XBeach and provide
%   the info in the XB structure
%
%   Syntax:
%   varargout = XB_read_bcfile(varargin)
%
%   Input:
%   XB        = XBeach communication structure
%   varargin  = PropertyName-PropertyValue pairs:
%                   'path'  -  path to find bcfile
%
%   Output:
%   XB        = XBeach communication structure
%
%   Example
%   XB_read_bcfile
%
%   See also CreateEmptyXBeachVar

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 31 Mar 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: XB_read_bcfile.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XB_read_bcfile.m $
% $Keywords: $

%%
if nargin == 0
    error('Not enough input arguments')
end

OPT = struct(...
    'path', cd);

OPT = setproperty(OPT, varargin{:});

%%
if isstruct(XB)
    bcfile = XB.settings.Waves.bcfile;
elseif ischar(XB)
    bcfile = XB;
    XB = CreateEmptyXBeachVar;
    XB.settings.Waves.bcfile = bcfile;
end

bcfile = fullfile(OPT.path, bcfile);

%%
[rt dtbc inpfile bc] = deal([], [], cell(0), struct([]));

fid = fopen(bcfile);
while ~feof(fid)
    txt = fgetl(fid);
    try
        [rt(end+1) dtbc(end+1) inpfile(end+1)] = strread(txt, '%f %f %s');
    catch
        continue
    end
    
    if ~isscalar(inpfile) > 1 && any(strcmp(inpfile(end), inpfile(1:end-1)))
        % copy bc info from identical record
        bc(end+1) = bc(find(strcmp(inpfile(end), inpfile(1:end-1)), 1, 'first'));
    else
        % read actual bcfile
        fid2 = fopen(fullfile(OPT.path, inpfile{end}));
        [vars vals] = deal(cell(0), []);
        while ~feof(fid2)
            txt2 = fgetl(fid2);
            [vars(end+1) vals(end+1)] = strread(txt2, '%s = %f');
            if isscalar(vars)
                % first var: create new record
                bc(end+1).(vars{end}) = vals(end);
            else
                % next vars: continue filling current record
                bc(end).(vars{end}) = vals(end);
            end
        end
        fclose(fid2);
    end
end
fclose(fid);

Hrms = cell2mat({bc.Hm0});
Hrms = [cumsum([0; rt']) [Hrms Hrms(end)]'];
XB.settings.Waves.Hrms = Hrms;

Trep = 1./cell2mat({bc.fp});
Trep = [cumsum([0; rt']) [Trep Trep(end)]'];
XB.settings.Waves.Trep = Trep;