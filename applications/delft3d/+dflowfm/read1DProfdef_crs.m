function varargout = read1DProfdef_crs(varargin)
% read1DProfdef_crs read the profiles from a Delft3D-FM 1D simulation 
% (profdefYZ_crs.pliz or profdefXYZ_crs.pliz files) to struct
%
%   Syntax:
%   crs = dflowfm.read1DProfdef_crs(varargin)
%
%   Input: For <keyword,value> pairs call dflowfm.read1DProfdef_crs() without arguments.
%   fname   = filename of profdefxyz_crs.pliz file
%   type    = 'yz' or 'xyz' (NOTE: only xyz implemented at the moment)
%
%   Output:
%   Struct with profiles
%
%   Example
%   fname   = 'profdefxyz_crs.pliz';
%   type    = 'xyz'
%   CRS     = dflowfm.read1DProfdef_crs('fname',fname,'type',type);
%
%   See also

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
% Created: 27 June 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: read1DProfdef_crs.m 16199 2020-01-22 08:50:06Z schrijve $
% $Date: 2020-01-22 16:50:06 +0800 (Wed, 22 Jan 2020) $
% $Author: schrijve $
% $Revision: 16199 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/read1DProfdef_crs.m $
% $Keywords: $

%% Settings

% Default
OPT.fname   = '';
OPT.type    = '';

OPT.fname   = 'profdefxyz_crs.pliz';

% return defaults (aka introspection)
if nargin==0
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
CRS.PROFNR      = [];
CRS.PROFNRmeta  = [];
CRS.data        = [];

fid = fopen(OPT.fname,'r');
if strcmp(OPT.type,'xyz')
    p = 0;
    tLine = fgetl(fid);
    while ~isempty(tLine)
        if ischar(tLine)
            p                   = p+1;
            id1                 = strfind(tLine,'=');
            id2                 = strfind(tLine,'*');
            if ~isempty(id2)
                CRS.PROFNR(p,1)     = str2double(tLine(id1+1:id2-1));
            else
                CRS.PROFNR(p,1)     = str2double(tLine(id1+1:end));
            end
            CRS.PROFNRmeta{p,1} = tLine(id2+1:end);
            rc                  = textscan(fgetl(fid),'%f%f',1);
            xyz                 = textscan(fid,'%f%f%f',rc{1});
            CRS.data(p).x       = xyz{1};
            CRS.data(p).y       = xyz{2};
            CRS.data(p).z       = xyz{3};
            
            tLine = fgetl(fid);
            tLine = fgetl(fid);
        end
        
        if feof(fid)
            break;
        end
        
    end
    fclose(fid);
end
varargout = {CRS};

return

