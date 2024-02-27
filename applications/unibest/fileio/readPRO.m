function [PROdata] = readPRO(PROfilename)
%read PRO : Read a unibest profile file
%
%   Syntax:
%     function [PROdata] = readPRO(PROfilename)
% 
%   Input:
%     PROfilename          string with profile filename
% 
%   Output:
%     PROdata              structure with profile data
%
%   Example:
%       
%     [PROdata] = readPRO(PROfilename)
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
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readPRO.m 8631 2013-05-16 14:22:14Z heijer $
% $Date: 2013-05-16 22:22:14 +0800 (Thu, 16 May 2013) $
% $Author: heijer $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readPRO.m $
% $Keywords: $

%-----------read data to file--------------
%-------------------------------------------
fid = fopen(PROfilename,'rt');
linestr = fgetl(fid);PROdata.codeDIR    = readLINE(linestr,'%f');  % Code X-Direction: +1/-1  Landwards/Seawards
linestr = fgetl(fid);PROdata.cpntcoast  = readLINE(linestr,'%f');  % reference X-point coastline
linestr = fgetl(fid);PROdata.xpntdynbnd = readLINE(linestr,'%f');  % X-point dynamic boundary
linestr = fgetl(fid);PROdata.xpnttrunc  = readLINE(linestr,'%f');  % X-point trunction transpor_CFSt
linestr = fgetl(fid);PROdata.codeZ      = readLINE(linestr,'%f');  % Code Z-Direction; +1/-1 Bottom-Level/Depth
linestr = fgetl(fid);PROdata.reflevel   = readLINE(linestr,'%f');  % Reference level
linestr = fgetl(fid);PROdata.gridNR     = readLINE(linestr,'%f');  % Number of points for Dx
linestr = fgetl(fid);                                              %          X    dx
for jj=1:PROdata.gridNR
    linestr = fgetl(fid);DATA = readLINE(linestr,'%f %f');
    PROdata.gridX(jj,1)  = DATA{1};
    PROdata.gridDX(jj,1)  = DATA{2};
end
linestr = fgetl(fid);PROdata.profNR     = readLINE(linestr,'%f');  % Number of points for Profile
linestr = fgetl(fid);                                              % X         Depth   (In any order)\n');
for jj=1:PROdata.profNR
    linestr = fgetl(fid);DATA = readLINE(linestr,'%f %f');
    PROdata.profX(jj,1)  = DATA{1};
    PROdata.profZ(jj,1)  = DATA{2};
end
fclose(fid);


%% function readLINE
function LINEdata = readLINE(linestring,formatting,readTRAILING)
%Example 1:
%   linestring = ' 100.2323 245 sdjsdssdj 3483 ksdfjksdf';
%   readTRAILING=0;
%   LINEdata1 = readLINE(linestring,'%f %f',readTRAILING);
%Example 1:
%   linestring = ' 100.2323 245 sdjsdssdj 3483 ksdfjksdf';
%   readTRAILING=1;
%   LINEdata2 = readLINE(linestring,'%f %f %s %f',readTRAILING);

if nargin==2
    readTRAILING=0;
end
linestring=linestring(:)';
line= [' ',linestring,' '];

%identify begin and end of data strings in line (using space and tab as seperator)
id1 = findstr(line,' ');
id2 = findstr(line,char(9));
idblanks = union(id1,id2);
idstring1 = idblanks(find(idblanks(2:end)-idblanks(1:end-1)>1))+1;
idstring2 = idblanks(find((idblanks(2:end)-idblanks(1:end-1))>1)+1)-1;

%remove blanks from formatting
formatting = formatting(setdiff([1:length(formatting)],findstr(formatting,' ')));
id1 = findstr(formatting,'%');
id2 = [(id1-1),length(formatting)];id2=id2(id2~=0);
%read text
for ii=1:length(id1)
    readtext = line(idstring1(ii):idstring2(ii));
    try
        LINEdata{ii} = strread(readtext,[formatting(id1(ii):id2(ii))]);
    catch
        LINEdata{ii} = strread(readtext,'%s');
    end
end
%read remaining
if readTRAILING==1
    if length(idstring1)>=ii+1
        readtext = line(idstring1(ii+1):end);
        LINEdata{ii+1} = strread(readtext,'%s');
    end
end
%do not use cell structure if only 1 item is read
if ii==1
    LINEdata=LINEdata{ii};
end

end
end
