function ITHK_writeCFE(filename, coeff_gamma, coeff_alfa, fw, kb)
%write CFE : Writes a unibest wave parameter file
%
%   Syntax:
%     function ITHK_writeCFE(filename, coeff_gamma, coeff_alfa, fw, kb)
% 
%   Input:
%    filename             string with filename
%    gamma                Coefficient for wave breaking (gamma) (-)
%    alfa		       Coefficient for wave breaking (alfa) (-)
%    fw                   Coefficient for bottom friction (-)
%    kb                   Bottom roughness (m)
%  
%   Output:
%     .cfe file
%
%   Example:
%     ITHK_writeCFE('test.cfe', 0.8, 1, 0.01, 0.1)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_writeCFE.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeCFE.m $
% $Keywords: $


%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(filename,'wt');

if nargin==5;
    fprintf(fid,'gamma_CFEalfac_CFE fwee_CFE  rkval_CFE\n');
    fprintf(fid,'%6.3f %6.3f %7.4f %7.4f\n',[coeff_gamma, coeff_alfa, fw, kb]');
else
    fprintf('\n incorrect number of input parameters!\n');
end
fclose(fid);