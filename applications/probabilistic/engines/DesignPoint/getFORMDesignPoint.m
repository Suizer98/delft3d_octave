function result = getFORMDesignPoint(result, varargin)
% getFORMDesignPoint: Translates Design Point description from FORM routine for comparison with MC routine
%
%   The result structure of the FORM routine contains a description of the
%   found Design Point. The routine approxMCDesignPoint approximates the
%   Design Point based on the result structure of the MC routine. The
%   latter Design Point description is more complete. This routine
%   translates the Design Point description from the FORM routine to a
%   description similar to the one used by the approxMCDesignPoint routine.
%
%   Syntax:
%   result = getFORMDesignPoint(result, varargin)
%
%   Input:
%   result      = result structure from FORM routine
%   varargin    = [for future use]
%
%   Output:
%   result      = original result structure with Design Point description
%                   added
%
%   Example
%   result = getFORMDesignPoint(result)
%
%   See also FORM MC approxMCDesignPoint printDesignPoint plotMCResult

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
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

% Created: 13 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: getFORMDesignPoint.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DesignPoint/getFORMDesignPoint.m $

%% settings

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% get design point

% allocate design point variables
designPoint = struct();

designPoint.u = result.Output.u(end, :);
designPoint.x = result.Output.x(end, :);
designPoint.z = result.Output.z(end, :);
designPoint.iterations = result.Output.Iter;
designPoint.calculations = result.Output.Calc;
designPoint.converged = result.Output.Converged;
designPoint.P = result.Output.P_f;
designPoint.time = 0;

%% return variable

% construct return variable
result.Output.designPoint = designPoint;