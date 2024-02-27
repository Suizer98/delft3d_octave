function printSWD(data,switchdetail,dataREF,sedREF)
% function prints the contents of an SWD file, which contains longshore sediment
% distribution over the cross-shore.
%
%   Syntax:
%     printSWD(data,switchdetail,dataREF,sedREF)
% 
%   Input:
%    data           structure with SWD data
%    switchdetail   (optional) switch 0/1 the details per condition (default=0)
%    dataREF        (optional) structure with reference data (for all conditions)
%    sedREF         (optional) reference sediment transport per condition
%  
%   Output:
%     print of SWD data
%
%   Example:
%     SWDdata=readSWD('FILE.SWD');
%     printSWD(SWDdata,1);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% $Id: printSWD.m 3257 2012-01-24 14:43:32Z huism_b $
% $Date: 2012-01-24 15:43:32 +0100 (Tue, 24 Jan 2012) $
% $Author: huism_b $
% $Revision: 3257 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/printSWD.m $
% $Keywords: $

if nargin<2
    switchdetail=0;
end

fprintf('--------%20s-----------\n',data.filename);
if switchdetail==1
    fprintf('                Condition : ');fprintf('%9.0f ',[1:length(data.Qs_nett)]);fprintf('\n');
    fprintf('Hs,schematised     [m^3/yr] = ');fprintf('%9.2f ',data.Hsig_dyn);fprintf('\n');
    fprintf('Tp,schematised     [m^3/yr] = ');fprintf('%9.1f ',data.T);fprintf('\n');
    fprintf('Dir,schematised    [m^3/yr] = ');fprintf('%9.1f ',data.Wave_dir);fprintf('\n');
    fprintf('Dur,schematised    [m^3/yr] = ');fprintf('%9.2f ',data.duration);fprintf('\n');
    fprintf('Qs schematised     [m^3/yr] = ');fprintf('%9.0f ',data.Qs_nett);fprintf('\n');
    if exist('sedREF','var')
        fprintf('Qs full climate    [m^3/yr] = ');fprintf('%9.0f ',sedREF);fprintf('\n');
        fprintf('Calibration factor [-]      = ');fprintf('%9.0f ',data.Qs_nett./sedREF);fprintf('\n');
    end
    fprintf('---------------------------------------------------\n');
end

if exist('dataREF','var')
    fprintf('Qs nett    = %9.0f m^3/yr  (reference is %7.0f m^3/yr for full wave climate)\n',sum(data.Qs_nett'),sum(dataREF.Qs_nett'));
    fprintf('Qs gross1  = %9.0f m^3/yr  (reference is %7.0f  m^3/yr for full wave climate)\n',sum(data.Qs_gross1'),sum(dataREF.Qs_gross1'));
    fprintf('Qs gross2  = %9.0f m^3/yr  (reference is %7.0f  m^3/yr for full wave climate)\n',sum(data.Qs_gross2'),sum(dataREF.Qs_gross2'));
else
    fprintf('Qs nett    = %9.0f m^3/yr\n',sum(data.Qs_nett'));
    fprintf('Qs gross1  = %9.0f m^3/yr\n',sum(data.Qs_gross1'));
    fprintf('Qs gross2  = %9.0f m^3/yr\n',sum(data.Qs_gross2'));
end
fprintf('---------------------------------------------------\n');