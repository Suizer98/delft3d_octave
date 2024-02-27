function varargout = rws_kustvak(varargin)
%RWS_KUSTVAK  routine to switch between area name <-> area code for Rijkswaterstaat Kustvakken
%
%      Output = rws_kustvak(Input)
%
%   returns the
%   - name of coastal area 'Kustvak' along the Dutch coast when input is code
%   - code of coastal area 'Kustvak' along the Dutch coast when input is name
%
%      rws_kustvak()
%
%   displays an overview of all 17 areas, including codes.
%
%   Input: either
%       AreaCode  = number of area 'Kustvak' along the Dutch coast
%       AreaName  = name   of area 'Kustvak' along the Dutch coast
%
%   Output: either
%       AreaCode  = number of area 'Kustvak' along the Dutch coast
%       AreaName  = name   of area 'Kustvak' along the Dutch coast
%
% Examples:
%
%    rws_kustvak(rws_kustvak('Noord-Holland')) = 'Noord-Holland
%    rws_kustvak(rws_kustvak(7)) = 7
%
% See also: jarkus_raaien, jarkus

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
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

% Created: 07 May 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: rws_kustvak.m 8299 2013-03-08 14:07:45Z heijer $
% $Date: 2013-03-08 22:07:45 +0800 (Fri, 08 Mar 2013) $
% $Author: heijer $
% $Revision: 8299 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_kustvak.m $
% $Keywords: $

%%
Areas = {
    'Rottumeroog en Rottumerplaat',...  %1
    'Schiermonnikoog',...               %2
    'Ameland',...                       %3
    'Terschelling',...                  %4
    'Vlieland',...                      %5
    'Texel',...                         %6
    'Noord-Holland',...                 %7
    'Rijnland',...                      %8
    'Delfland',...                      %9
    'Maasvlakte / slufter',...          %10
    'Voorne',...                        %11
    'Goeree',...                        %12
    'Schouwen',...                      %13
    'Oosterschelde / Neeltje Jans',...	%14
    'Noord-Beveland',...                %15
    'Walcheren',...                     %16
    'Zeeuws-Vlaanderen' ...             %17
    };

%% show overview of areas including codes

if nargin == 0 && nargout == 0
    fprintf(1, 'code  name\n')
    for i = 1:length(Areas)
        fprintf(1, '%2i    %s\n', i, Areas{i})
    end
end

%% name <-> code

for i = 1:nargin
    if iscell(varargin{i})
        varargout{i} = feval(mfilename, varargin{i}{:});
    elseif isnumeric(varargin{i})  % area code
        if any(varargin{i} < 1 | varargin{i} > length(Areas))
            error(sprintf('Area codes should be between 1 and %i', length(Areas)))
        end
        for j = 1:length(varargin{i})
            varargout{i}{j} = Areas{varargin{i}(j)}; % return area name
        end
    elseif ischar(varargin{i}) % area name
        areacode = find(strcmpi(Areas, varargin{i})); % return area code
        if isempty(areacode)
            error('"%s" is not a valid kustvak name', varargin{i})
        end
        varargout{i} = areacode; % return area code
    end
end

%% output

if nargin > 1 && nargout < length(varargout)
    varargout = {varargout};
end
