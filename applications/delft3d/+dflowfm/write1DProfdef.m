function varargout = write1DProfdef(varargin)
% write1DProfdef  Write a profile definition text file for a Delft3D Flexible Mesh 1D simulation
%
%   Syntax:
%   dflowfm.write1DProfdef(profnr,type,varargin)
%
%   Input: For <keyword,value> pairs call writeProfdef() without arguments.
%   fname   = filename of text file
%   profnr  = nx1 array of profile numbers
%   type    = nx1 array of profile types
%   width   = nx1 array of profile widths (ignored if type is not 1-7)
%   height  = nx1 array of profile heights (ignored if type is not 1-7)
%   base    = nx1 array of profile bases (ignored if type is not 6-7)
%
%   Output:
%   text file with header with definitions
%
%   Example
%   fname   = 'profdef.txt';
%   profnr  = 1:10;
%   type    = 200.*size(profnr);
%   dflowfm.write1DProfdef(fname,profnr,type)
%
%   See also
%   dflowfm.read1DProfdef_crs

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 Deltares
%       schrijve
%
%       Reinier.Schrijvershof@Deltares.nl
%
%       Deltares
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
% Created: 25 Mar 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: write1DProfdef.m 15544 2019-07-01 03:48:45Z schrijve $
% $Date: 2019-07-01 11:48:45 +0800 (Mon, 01 Jul 2019) $
% $Author: schrijve $
% $Revision: 15544 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/write1DProfdef.m $
% $Keywords: $

%% Settings

% Default
OPT.fname   = 'profdef.txt';
OPT.profnr  = [];
OPT.type    = [];
OPT.width   = [];
OPT.height  = [];
OPT.base    = [];

% return defaults (aka introspection)
if nargin==0
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

fid = fopen(OPT.fname,'w');

% Write header
fprintf(fid,'* TYPE=1  : PIPE\n');
fprintf(fid,'* TYPE=2  : RECTAN   ,  HYDRAD = AREA / PERIMETER                           ALSO SPECIFY: HEIGHT=\n');
fprintf(fid,'* TYPE=3  : RECTAN   ,  HYDRAD = 1D ANALYTIC CONVEYANCE = WATERDEPTH        ALSO SPECIFY: HEIGHT=\n');
fprintf(fid,'* TYPE=4  : V-SHAPE  ,  HYDRAD = AREA / PERIMETER                           ALSO SPECIFY: HEIGHT=\n');
fprintf(fid,'* TYPE=5  : V-SHAPE  ,  HYDRAD = 1D ANALYTIC CONVEYANCE                     ALSO SPECIFY: HEIGHT=\n');
fprintf(fid,'* TYPE=6  : TRAPEZOID,  HYDRAD = AREA / PERIMETER                           ALSO SPECIFY: HEIGHT=  BASE=\n');
fprintf(fid,'* TYPE=7  : TRAPEZOID,  HYDRAD = 1D ANALYTIC CONVEYANCE                     ALSO SPECIFY: HEIGHT=  BASE=\n');
fprintf(fid,'* TYPE=100: YZPROF   ,  HYDRAD = AREA / PERIMETER\n');
fprintf(fid,'* TYPE=101: YZPROF   ,  HYDRAD = 1D ANALYTIC CONVEYANCE METHOD\n');
fprintf(fid,'* TYPE=200: XYZPROF  ,  HYDRAD = AREA / PERIMETER\n');
fprintf(fid,'* TYPE=201: XYZPROF  ,  HYDRAD = 1D ANALYTIC CONVEYANCE METHOD\n');
fprintf(fid,'\n');

% Write data
for i = 1:length(OPT.profnr)
    profnr  = OPT.profnr(i);
    type    = OPT.type(i);
    
    if type == 1
        fprintf(fid,'PROFNR=%d\tTYPE=%d\n',OPT.profnr(i),OPT.type(i));
    elseif type > 2 && type <= 5
        width   = OPT.width(i);
        height  = OPT.width(i);
        fprintf(fid,'PROFNR=%d\tTYPE=%d\tWIDTH=%d\tHEIGHT=%d\n',profnr,type,width,height);
    elseif type == 6 || type == 7
        width   = OPT.width(i);
        height  = OPT.width(i);
        base    = OPT.base(i);
        fprintf(fid,'PROFNR=%d\tTYPE=%d\tWIDTH=%d\tHEIGHT=%d\tBASE=%d\n',profnr,type,width,height,base);
    elseif type >= 8
        fprintf(fid,'PROFNR=%d\tTYPE=%d\n',OPT.profnr(i),OPT.type(i));
    end
end
fclose(fid);

