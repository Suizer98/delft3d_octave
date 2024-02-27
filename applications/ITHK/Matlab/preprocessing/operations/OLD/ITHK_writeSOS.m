function ITHK_writeSOS(filename, varargin)
%write SOS : Writes a unibest sources and sinks file
%
%   Syntax:
%     ITHK_writeSOS(filename, SOSdata)
%
%   Input:
%     filename             string with output filename
%     SOSdata              (optional) structure with SOS data
%                            .XW: [8x1 double]
%                            .YW: [8x1 double]
%                            .CODE: [8x1 double]
%                            .Qs: [8x1 double]
%                            .COLUMN: [8x1 double]
%
%   Output:
%     .sos files
% 
%   Example:
%     ITHK_writeSOS(filename, {[1000,2000,0,22000,0],[500,1000,0,12000,0]})  % at x=1000,y=2000,Qs=22000 and at x=500,y=1000,Qs=12000
%     ITHK_writeSOS(filename, {[1000,2000,1,0,1],[500,1000,1,0,2]})  % at x=1000,y=2000,use tabfile1,column1 and at x=500,y=1000,use tabfile1,column2
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

% $Id: ITHK_writeSOS.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeSOS.m $
% $Keywords: $

%-----------Write data to file--------------
%-------------------------------------------

err=0;
if nargin==1
    SOSdata = {};
elseif nargin==2
    SOSdata = varargin{1};
else
    fprintf('\n Number of input parameters is incorrect!\n')
    err=1;
end

if err==0
    fid = fopen(filename,'wt');
    %write header
    if isfield(SOSdata(1),'headerline')
        fprintf(fid,'%s\n',SOSdata(1).headerline);
    else
        fprintf(fid,'Sources and Sinks\n');
    end
    %write number of sources/sinks
    for nn=1:length(SOSdata)
        no_sourcesandsinks(nn) = length(SOSdata(nn).XW);
    end
    fprintf(fid,'%4.0f\n',sum(no_sourcesandsinks));
    fprintf(fid,' Xw      Yw       File/Code       Qs[m3/y]         column \n');
    %write data
    for nn=1:length(SOSdata)
        for ii=1:length(SOSdata(nn).XW)
            fprintf(fid,' %9.1f %9.1f %9.0f %9.3f %9.0f\n',SOSdata(nn).XW(ii),SOSdata(nn).YW(ii),SOSdata(nn).CODE(ii),SOSdata(nn).Qs(ii),SOSdata(nn).COLUMN(ii));
        end
    end
    fclose(fid);    
else
    fprintf('\n incorrect number of input parameters!\n');
end