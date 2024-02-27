function varargout = XBeach_write_jonswap(varargin)
%XBEACH_WRITE_JONSWAP  Create jonswap wave boundary file for XBeach
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = XBeach_write_jonswap(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeach_write_jonswap
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
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

% Created: 31 Mar 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: XBeach_write_jonswap.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBeach_write_jonswap.m $
% $Keywords:

%%
OPT = struct(...
    ... % wave parameters
    'XB', CreateEmptyXBeachVar,...
    'Hm0', [],...
    'fp', [],...
    'gammajsp', [],...
    's', [],...
    'mainang', [],...
    'fnyq', [],...
    'dfj', [],...
    'instat', 4,... % according to XBeach manual (nov. 2009) 4: standard JONSWAP spectrum based on user-input spectrum coefficients
    ...
    ... % additional information
    'ext', '.inp',...
    'calcdir', cd);

OPT = setproperty(OPT, varargin{:});

%%
doubleID = find(cellfun(@isnumeric, varargin));

inputsize = cellfun(@length, varargin(doubleID));
nrSpectra = max(inputsize);
nrDigits = length(num2str(nrSpectra));

nrSpaces = 11-cellfun(@length, fieldnames(OPT));

for i = 1:nrSpectra
    if nrSpectra == 1
        spectrumfilename{i} = 'jonswap'; %#ok<AGROW>
    else
        spectrumfilename{i} = ['jonswap_' num2str(i, ['%0' num2str(nrDigits) 'i'])]; %#ok<AGROW>
    end
    str = [];
    for param = varargin(doubleID-1)
        if ~isempty(OPT.(param{1}))
            id = min(i, length(OPT.(param{1})));
            str = sprintf('%s%s%s= %g\n', str, param{1}, blanks(nrSpaces(strcmp(param{1}, fieldnames(OPT)'))), OPT.(param{1})(id));
        end
    end
    fid = fopen(fullfile(OPT.calcdir, [spectrumfilename{i} OPT.ext]), 'w');
    fprintf(fid, '%s', str);
    fclose(fid);
end

OPT.XB.settings.Waves.instat = OPT.instat;
if nrSpectra == 1
    OPT.XB.settings.Waves.bcfile = [spectrumfilename{1} OPT.ext];
end

varargout = {spectrumfilename OPT.ext OPT.XB};