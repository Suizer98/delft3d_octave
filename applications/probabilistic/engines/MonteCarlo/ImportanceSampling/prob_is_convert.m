function OPT = prob_is_convert(OPT)
%PROB_IS_CONVERT  Converts the old input format for importance sampling to new
%
%   Converts the old input format for importance sampling to the new format
%   using an importance sampling struct.
%
%   Syntax:
%   OPT = prob_is_convert(OPT)
%
%   Input:
%   OPT       = Options structure
%
%   Output:
%   OPT       = Modified options structure
%
%   Example
%   OPT = prob_is_convert(OPT)
%
%   See also MC, prob_is, exeampleISVar

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 20 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: prob_is_convert.m 4598 2011-05-25 09:57:40Z hoonhout $
% $Date: 2011-05-25 17:57:40 +0800 (Wed, 25 May 2011) $
% $Author: hoonhout $
% $Revision: 4598 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/ImportanceSampling/prob_is_convert.m $
% $Keywords: $

%% convert input

if ~isfield(OPT, 'IS') || isempty(fieldnames(OPT.IS))
    if isfield(OPT, 'ISvariable') && ~isempty(OPT.ISvariable)
        
        warning('OET:probabilistic:deprecated', [ ...
            'The importance sampling input format you are using is deprecated. ' ...
            'Please use the new format using the "IS" option and ' ...
            'an importance sampling structure array. ' ...
            'See for an example the exampleISVar function.']);
        
        if isfield(OPT, 'f1') && OPT.f1 < Inf && ...
           isfield(OPT, 'f2') && OPT.f1 > 0
       
            idx     = strcmp({OPT.stochast.Name}, OPT.ISvariable);

            OPT.IS = struct(                                        ...
                'Name',     OPT.ISvariable,                         ...
                'Method',   @prob_is_uniform_OLD,                   ...
                'Params',   {{OPT.stochast(idx) OPT.f1 OPT.f2}}     ...
            );
        
            OPT = rmfield(OPT, {'f1' 'f2'});

        elseif isfield(OPT, 'W') && OPT.W ~= 1
            
            OPT.IS = struct(                        ...
                'Name',     OPT.ISvariable,         ...
                'Method',   @prob_is_factor,        ...
                'Params',   {{OPT.W}}               ...
            );
        
            OPT = rmfield(OPT, 'W');
        
        end
        
        OPT = rmfield(OPT, 'ISvariable');
    end
end
