function [inhoudRAY] = printRAY(RAYfilename,outfile)
%print RAY : Print data of RAY file to a text file
%
%   Syntax:
%     function [inhoudRAY] = printRAY(RAYfilename,outfile)
% 
%   Input:
%     RAYfilename     string, cell or struct with filename (and directory) with ray files
%     outfile         string with name of output file with RAY data
% 
%   Output:
%     file with RAY data
%     inhoudRAY       struct with contents of ray file
%                     .name    :  cell with filenames
%                     .path    :  cell with path of files
%                     .info    :  cell with header info of RAY file (e.g. pro-file used)
%                     .equi    :  equilibrium angle degrees relative to 'hoek'
%                     .c1      :  coefficient c1 [-] (used for scaling of sediment transport of S-phi curve)
%                     .c2      :  coefficient c2 [-] (used for shape of S-phi curve)
%                     .h0      :  active height of profile [m]
%                     .hoek    :  coast angle specified in LT computation
%                     .fshape  :  shape factor of the cross-shore distribution of sediment transport [-]
%                     .Xb      :  coastline point [m]
%                     .perc2   :  distance from coastline point beyond which 2% of transport is located [m]
%                     .perc20  :  distance from coastline point beyond which 20% of transport is located [m]
%                     .perc50  :  distance from coastline point beyond which 50% of transport is located [m]
%                     .perc80  :  distance from coastline point beyond which 80% of transport is located [m]
%                     .perc100 :  distance from coastline point beyond which 100% of transport is located [m] 
%
%   Example:
%     printRAY
%     printRAY(dir('*.ray'),'printRAY.txt');
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

% $Id: printRAY.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/printRAY.m $
% $Keywords: $

if nargin==0
    outfile = 'printRAY.txt';
    fprintf('Reading all ray files in directory!\n');
    RAYfilename = dir('*.ray');
    if length(RAYfilename)==0
        fprintf('Error : No ray files in directory!\n');
        return
    end
    fprintf('Printing to default outfile : ''printRAY.txt''.\n');
elseif nargin==1
    fprintf('Reading ray files.\n');
    outfile = 'printRAY.txt';
    fprintf('Printing to default outfile : ''printRAY.txt''.\n');
else
    fprintf('Reading ray files.\n');
    fprintf('Printing to outfile : ''%s''.\n',outfile);
end

%% read contents of ray file
inhoudRAY = readRAY(RAYfilename);

%% print data of RAY files to text file
fid2 = fopen(outfile,'wt');

% PLOT EQUI ANGLE

fprintf(fid2,' %20s %14s %8s %10s %10s\n','naam','equi','hoek','c1','c2');
for ii=1:length(inhoudRAY);
    fprintf(fid2,' %25s ',inhoudRAY(ii).name);

    % PLOT equi
    if inhoudRAY.equi(ii)<0
        fprintf(fid2,' %7.2f',inhoudRAY(ii).equi);
    else
        fprintf(fid2,' %8.2f',inhoudRAY(ii).equi);
    end

    % PLOT hoek
    fprintf(fid2,' %10.2f',inhoudRAY(ii).hoek);

    % PLOT C1
    if inhoudRAY.c1(ii)<0
        fprintf(fid2,'  %8.8f',inhoudRAY(ii).c1);
    else
        fprintf(fid2,'  %9.8f',inhoudRAY(ii).c1);
    end
    
    % PLOT C2
    fprintf(fid2,'  %9.8f',inhoudRAY(ii).c2);

    fprintf(fid2,'\n');
end
fclose(fid2);