function varargout = prob_checkinput(varargin)
%PROB_CHECKINPUT  check input of Monte Carlo and FORM functions.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_checkinput(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_checkinput
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_checkinput.m 4595 2011-05-24 15:37:45Z hoonhout $
% $Date: 2011-05-24 23:37:45 +0800 (Tue, 24 May 2011) $
% $Author: hoonhout $
% $Revision: 4595 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/prob_checkinput.m $
% $Keywords: $

%%
ST = dbstack;
if length(ST) > 1
    callerfun = ST(2).name;
end

%% Resistance no longer used as separate propertyName-propertyValue pair
if any(strcmp(varargin(cellfun(@ischar, varargin)), 'Resistance'))
    error([upper(callerfun) ':Resistance'], 'Resistance no longer used as separate propertyName-propertyValue pair; include this in "variables" and modify z-function')
end

%% backward compatible input
first_input_is_stochast = nargin > 0 && isstruct(varargin{1});
if first_input_is_stochast
    stochastid = false(size(varargin));
    stochastid(3:2:end) = strcmp(varargin(2:2:end), 'stochast');
    if any(stochastid)
        warning([upper(callerfun) ':stochast_defined_twice'], 'variable "stochast" is defined twice')
        if ~isequalwithequalnans(stochast, varargin{stochastid})
            error([upper(callerfun) ':stochast_defined_twice'], 'definitions of "stochast" are different')
        else
            varargin = varargin(2:end);
        end
    else
        varargin = [{'stochast'} varargin];
    end
end

%% modify stochast for backward compatibility
stochastid = false(size(varargin));
stochastid(2:2:end) = strcmp(varargin(1:2:end), 'stochast');

if ~any(stochastid)
    error([upper(callerfun) ':stochast_not_defined'], 'stochast is not defined')
else
%     if ~isfield(varargin{stochastid}, 'propertyName')
%         stochast = varargin{stochastid};
%         for istochast = 1:length(stochast)
%             stochast(istochast).propertyName = false;
%         end
%         varargin{stochastid} = stochast;
%     end
end
varargout = {varargin};