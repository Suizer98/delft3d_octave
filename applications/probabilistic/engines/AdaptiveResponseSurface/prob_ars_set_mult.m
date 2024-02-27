function ARS = prob_ars_set_mult(u, z_tot, varargin)
%PROB_ARS_SET_MULT One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_ars_total(varargin)
%
%   Input: For <keyword,value> pairs call prob_ars_total() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_ars_total
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 27 Sep 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: prob_ars_set_mult.m 7544 2012-10-22 08:00:25Z hoonhout $
% $Date: 2012-10-22 16:00:25 +0800 (Mon, 22 Oct 2012) $
% $Author: hoonhout $
% $Revision: 7544 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/AdaptiveResponseSurface/prob_ars_set_mult.m $
% $Keywords: $

%% Settings

OPT = struct(...
    'ARS',                  prob_ars_struct_mult,   ...                     % ARS structure
    'DesignPointDetection', true,                   ...                     % Boolean switch for automatic detection of design points                
    'DesignPointFunction',  @prob_ars_split,        ...                     % Design point detection function 
    'ARSsetFunction',       @prob_ars_set3,         ...                     % Function handle to update ARS structure based on a set
                                                    ...                         of vectors u and corresponding z-values
    'ARSsetVariables',      {{}}                    ...                     % Additional variables to the ARSsetFunction
);

OPT = setproperty(OPT, varargin{:});

%% Include points from ARS structure

ARS = OPT.ARS;

if size(z_tot,2) == 1
    ui  = [cat(1,ARS.u); u];
    bi  = [cat(1,ARS.b); sqrt(sum(u.^2,2))];
    zi  = [cat(1,ARS.z); z_tot(:)];
end

%% Design point detection

if OPT.DesignPointDetection
    ARS    = feval(OPT.DesignPointFunction, ARS, ui, bi, zi);
    nr_ARS = length(ARS);
elseif size(z_tot,2) > 1 && ~OPT.DesignPointDetection
    nr_ARS  = size(z_tot,2);
    ui  = [cat(1,ARS(1).u); u];
    bi  = [cat(1,ARS(1).b); sqrt(sum(u.^2,2))];
    zi  = cat(2,ARS.z);
    
    ARS0            = ARS;
    ARS             = repmat(prob_ars_struct_mult, 1, nr_ARS);
    [ARS.b]         = deal(bi);
    [ARS.u]         = deal(ui);
    [ARS.active]    = deal(ARS0.active);
    [ARS.betamin]   = deal(ARS0.betamin);
    [ARS.dbeta]     = deal(ARS0.dbeta);
    [ARS.aggregateFunction]     = deal(ARS0.aggregateFunction);
    
    for i = 1:nr_ARS
        ARS(i).z    = [zi(:,i); z_tot(:,i)];
    end
else
    nr_ARS = 1;

    ARS.u  = ui;
    ARS.b  = bi;
    ARS.z  = zi;
end

%% Generate ARS's

for n = 1:nr_ARS
    ARS(n)  = feval(            ...
        OPT.ARSsetFunction,     ...
        ARS(n).u,               ...
        ARS(n).z,               ...
        'ARS',ARS(n),           ...
        OPT.ARSsetVariables{:}      );
end