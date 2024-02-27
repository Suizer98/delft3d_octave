function D = kustlidar_definition(varargin)
%KUSTLIDAR_DEFINITION  One line description goes here.
%
%   Function returns by default a structure with all available kustlidar
%   tiles. When providing the function with a x-y coordinate by means of
%   propertyname-propertyvaluepairs, a string with the tilename is
%   returned.
%
%   At www.kadaster.nl the "Bladwijzer 10000.pdf" shows the boxes on land
%   from which the kustlidar boxes are a seaward generalisaton.
%   Because the kadaster makes a mess out of all sea-adjacent areas,
%   the kustlidar boxes use their own naming convention.
%
%   Transforms all data on the default 1000 column x 1250 row tiles
%   of the official "kaartbladen of the Geografische Dienst".
%   where each halftile of XX is subdivided in twice into 4 subtiles
%   ab-dc-ef-gh > n1-n1-z1-z2 (see www.ahn.nl for the locations of XX)
%   For example, the upper left tile in the sketch below is called XXan1.
%         
%         n1   n2 : n1   n2 || n1   n2 : n1   n2
%            a    :    b    ||    e    :    f
%         z1   z2 : z1   z2 || z1   z2 : z1   z2
%         ==================XX==================
%         n1   n2 : n1   n1 || n1   n2 : n1   n2
%            c    :    d    ||    g    :    h
%         z1   z2 : z1   z2 || z1   z2 : z1   z2
%
%   Syntax:
%   varargout = kustlidar_definition(varargin)
%
%   Input:
%   varargin  = 'level' : 0 for main tiles only (numbers)
%                         1 for main tiles including 8 subtiles (a-h)
%                         2 to additionally include n-z and 1-2 division
%               'x'     : x-coordinate
%               'y'     : y-coordinate
%
%   Output:
%   varargout =
%
%   Example
%   kustlidar_definition
%
%   See also vaklodingen_definition

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
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
% Created: 21 Aug 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: kustlidar_definition.m 7244 2012-09-14 09:16:46Z heijer $
% $Date: 2012-09-14 17:16:46 +0800 (Fri, 14 Sep 2012) $
% $Author: heijer $
% $Revision: 7244 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/kustlidar/kustlidar_definition.m $
% $Keywords: $

%%
OPT = struct(...
    'level', 2,...
    'x', [],...
    'y', []);

OPT = setproperty(OPT, varargin);

%% define all kaartbladen
% lower-left corner of main tile 1
x_origin     = 140000;
x_factor     = 1;
y_origin     = 6e5;%606250;
y_factor     = -1;
% x and y range of whole tiled area
x_min = x_origin-4*40000;
x_max = x_origin+4*40000;
y_min = y_origin-12*25000;
y_max = y_origin+25000;

D.ncols        = 1000*4*2 * 2^(sign(-OPT.level)-OPT.level); % nx
D.nrows        = 1250*4 * 2^(-OPT.level); % ny
D.cellsize     = 5;  % dx = dy by definition
D.xllcorner    = x_min:D.cellsize*D.ncols:x_max;
D.yllcorner    = y_min:D.cellsize*D.nrows:y_max;
if all(isfinite([OPT.x OPT.y])) && ~isempty([OPT.x OPT.y])
    D.xllcorner = OPT.x;
    D.yllcorner = OPT.y;
end

[D.xllcorner,...
    D.yllcorner]=meshgrid(D.xllcorner,D.yllcorner);

% pre-allocate all names
D.name = repmat({''}, size(D.xllcorner));

D.name_main = nan(size(D.xllcorner)); %main number
D.name_sub1 = repmat({''}, size(D.xllcorner)); %a -- h
D.name_sub2 = repmat({''}, size(D.xllcorner)); %n or z
D.name_sub3 = nan(size(D.xllcorner)); %1 or 2


main_colid = floor((x_factor * (D.xllcorner - x_origin)) / (1000*4*2*D.cellsize));
main_rowid = ceil((y_factor * (D.yllcorner - y_origin)) / (1250*4*D.cellsize));

man_factor = nan(size(D.xllcorner));

man_factor(main_rowid==0 & main_colid >= 0 & main_colid<3) = 1;
man_factor(main_rowid==0 & main_colid == 3) = 71;
man_factor(main_rowid==1 & main_colid >= -1) = 4;
man_factor(main_rowid==2 & main_colid >= -1) = 8;
man_factor(main_rowid==3 & main_colid >= -1) = 12;
man_factor(main_rowid==4 & main_colid >= -1) = 16;
man_factor(main_rowid==4 & main_colid == -2) = 70;
man_factor(main_rowid==5 & main_colid >= -2) = 21;
man_factor(main_rowid==6 & main_colid >= -2) = 26;
man_factor(main_rowid==7 & main_colid >= -3) = 32;
man_factor(main_rowid==8 & main_colid >= -2) = 37;
man_factor(main_rowid>=8 & main_rowid<=9 & main_colid == -3) = 59;
man_factor(main_rowid==9 & main_colid == -4) = 65;
man_factor(main_rowid==9 & main_colid >= -2) = 42;
man_factor(main_rowid==10 & main_colid >= -4 & main_colid <= -3) = 60;
man_factor(main_rowid==10 & main_colid >= -2) = 47;

D.name_main = ...
    main_rowid + main_colid + man_factor;

if OPT.level > 0
    %a -- h
    sub1_colid = floor((x_factor * (D.xllcorner - x_origin)) / (1000*2*D.cellsize));
    sub1_rowid = ceil((y_factor * (D.yllcorner - y_origin)) / (1250*2*D.cellsize));
    oddrows = odd(sub1_rowid);
    mod4cols = mod(sub1_colid,4);
    abid = oddrows & mod4cols < 2;
    cdid = ~oddrows & mod4cols < 2;
    efid = oddrows & mod4cols > 1;
    ghid = ~oddrows & mod4cols > 1;
    D.name_sub1(abid) = cellfun(@char, num2cell(97+mod(sub1_colid(abid),4)),...
        'uniformoutput', false);
    D.name_sub1(cdid) = cellfun(@char, num2cell(99+mod(sub1_colid(cdid),4)),...
        'uniformoutput', false);
    D.name_sub1(efid) = cellfun(@char, num2cell(99+mod(sub1_colid(efid),4)),...
        'uniformoutput', false);
    D.name_sub1(ghid) = cellfun(@char, num2cell(101+mod(sub1_colid(ghid),4)),...
        'uniformoutput', false);
end

if OPT.level > 1
    %n or z
    sub2_rowid = ceil((y_factor * (D.yllcorner - y_origin)) / (1250*D.cellsize));
    oddrows = odd(sub2_rowid);
    D.name_sub2(oddrows) = deal({'n'});
    D.name_sub2(~oddrows) = deal({'z'});
    %1 or 2
    sub3_colid = floor((x_factor * (D.xllcorner - x_origin)) / (1000*D.cellsize));
    D.name_sub3 = mod(sub3_colid,2)+1;
end

D.name = cellfun(@(main_name,sub1,sub2,sub3) sprintf('%02i%s%s%i', main_name,sub1,sub2,sub3), num2cell(D.name_main),...
    D.name_sub1, D.name_sub2, num2cell(D.name_sub3),...
    'uniformoutput', false);

if all(isfinite([OPT.x OPT.y])) && ~isempty([OPT.x OPT.y])
    D = D.name{:};
    return
end

D.name(isnan(D.name_main)) = {''};