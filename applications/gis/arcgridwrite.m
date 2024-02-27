function arcgridwrite(fileName,X,Y,Z,varargin)
%ARCGRIDWRITE save gridded data set in ArcGIS ASCII format
%
%   arcgridwrite(fileName,X,Y,Z)- converts data in a matlab
%   grid (as produced by eg. meshgrid and griddata) into a text file
%   in Arc ASCII Grid Format. The file can also be automatically
%   converted to raster on PC's with ARCINFO installed.
%
%   Note that the xll and yll are half a cell size to the left and to the
%   bottom of the minimum x and y in the input data (bug fix since revision
%   7969)
%
%   Important optional argument is 'flipud'
%   when Y is going up in the input you should set this to 1 (default)
%   when Y is going down in the input you should set this to 0 (usually you
%   would use this if you read the data from an ESRI ArcGIS file and want 
%   to write it to a new ArcGIS file)
%
%   INPUTS
%       fileName:  output filename including extension
%       X:         X coordinates (m x n) or 1D stick (n)
%       Y:         Y coordinates (m x n) or 1D stick (m)
%       Z:         gridded data  (m x n)
%
%   SYNTAX AND OPTIONS
%       arcgridwrite('D:\tools\bathyGrid.asc',X,Y,Z)
%
%       arcgridwrite('D:\tools\bathyGrid.asc',X,Y,Z,'flipud',0); % assumes
%       Y is going down in the input
%
%       arcgridwrite('D:\tools\bathyGrid.asc',X,Y,Z,'precision',5); % 
%       changes default floating point output from 3 to 5 decimal places.
%
%        arcgridwrite('D:\tools\bathyGrid.asc',X,Y,Z,'convert',1) -
%           attempts to convert the ASCII text file to raster using
%           the ARCINFO command ASCIIGRID.  This option currently
%           only works on a pc with ARCINFO installed.
%
%   EXAMPLE - create a raster grid of the peaks function
%       [X,Y,Z]=peaks(100);
%       arcgridwrite('peaksArc.asc',X,Y,Z,'precision',3,...
%           'convert',1)
%
%   NOTES
%   1) Because the Arc ASCII format has only one parameter for cell size,
%   both X and Y must have the same, non-varying grid spacing.
%
% A.Stevens @ USGS 7/18/2007, astevens@usgs.gov
%
% SEE ALSO: ARCGIS

% Copyright (c) 2010, Andrew Stevens
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: arcgridwrite.m 12754 2016-05-31 14:27:20Z nederhof $
% $Date: 2016-05-31 22:27:20 +0800 (Tue, 31 May 2016) $
% $Author: nederhof $
% $Revision: 12754 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/gis/arcgridwrite.m $
% $Keywords: $

%%
%check number of inputs
if nargin < 4
    error('Not enough input arguments');
end

OPT.flipud = 1;
% when Y is going up in the input you should set this to OPT.flipud = 1
% when Y is going down in the input (as is default in ArcGisRead.m) you
% should set this to OPT.flipud = 0;
OPT.precision = 7;
OPT.convert = 0;
OPT.nodata = -9999; % you could also use -32768
OPT = setproperty(OPT,varargin{:});


[mz,nz,zz]=size(Z);
[mx]=size(X);
[my]=size(Y);

minX=min(X(:));
minY=min(Y(:));
if isvector(X)
dx=abs(diff(X(:)));
dy=abs(diff(Y(:)));
else
dx=abs(diff(X(1,:)));
dy=abs(diff(Y(:,1)));
end

maxDiff=5; %threshold for varying dx and dy.  increase or
%decrease this parameter if necessary.

%check input dimensions and make sure x and y
%spacing are the same.
if any(diff(dx)>maxDiff) || any(diff(dy)>maxDiff)
    error('X- and Y- grid spacing should be non-varying');
else
    dx=dx(1);
    dy=dy(1);
end

xll = minX-0.5*dx;
yll = minY-0.5*dy;

if ischar(fileName)~=1
    error('First input must be a string')
elseif zz>1
    error('Z must be 2-dimensional');
elseif mx~=nz
    error('X, Y and Z should be same size');
elseif my~=mz
    error('X, Y and Z should be same size');
elseif abs(dx-dy)>maxDiff;
    error('X- and Y- grid spacing should be equal');
end


convert=OPT.convert;
dc=OPT.precision; %default number of decimals to output
% if isempty(varargin)~=1
%     [m1,n1]=size(varargin);
%     opts={'precision';'convert'};
%
%     for i=1:n1;
%         indi=strcmpi(varargin{i},opts);
%         ind=find(indi==1);
%         if isempty(ind)~=1
%             switch ind
%                 case 1
%                     dc=varargin{i+1};
%                 case 2
%                     convert=1;
%             end
%         else
%         end
%     end
% end


%replace NaNs with NODATA value
Z(isnan(Z)) = OPT.nodata;
if OPT.flipud
%     disp('Assumed input Y going up, therefore output Z = flipud(Z)')
    Z=flipud(Z);
else
    disp('Assumed input Y going down (ESRI default), therefore output Z same as input')
end

%define precision of output file
if isnumeric(dc)
    dc=['%.',sprintf('%d',dc),'f'];
elseif isnumeric(dc) && dc==0
    dc=['%.',sprintf('%d',dc),'d'];
end

fid=fopen(fileName,'wt');

%write header
fprintf(fid,'%s\t','ncols');
fprintf(fid,'%d\n',nz);
fprintf(fid,'%s\t','nrows');
fprintf(fid,'%d\n',mz);
fprintf(fid,'%s\t','xllcorner');
fprintf(fid,[dc,'\n'],xll);
fprintf(fid,'%s\t','yllcorner');
fprintf(fid,[dc,'\n'],yll);
fprintf(fid,'%s\t','cellsize');
fprintf(fid,[dc,'\n'],dx);
fprintf(fid,'%s\t','NODATA_value');
fprintf(fid,'%d\n',OPT.nodata);

fclose(fid);

%write data
dlmwrite(fileName, Z, '-append','delimiter','\t')

%if requested, try to convert to raster using ARCINFO command ASCIIGRID
if convert==1
    if ispc~=1;
        disp('"Convert" option only works on a pc')
        return
    end
    %configure filename and path
    [pname,fname,ext] = fileparts(fileName);
    if isempty(pname)==1;
        pname=pwd;
    end

    if strcmpi(pname(end),filesep)~=1
        pname=[pname,filesep];
    end
    dos(['ARC ASCIIGRID ',pname,fname,ext, ' ',...
        pname,fname, ' FLOAT']);
end


