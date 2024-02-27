function data=readPRNfast(varargin)
%read PRN : Reads PRN-files and puts data into a struct (faster)
%   
%   Syntax:
%     function [data]=readPRNfast(PRNfilename,INIswitch)
%   
%   Input:
%     PRNfilename    (optional) string with filename 
%   
%   Output:
%     data       struct with contents of prn file
%                     .files       : String with filename
%                     .timestep    : Time steps
%                     .year        : Years
%                     .no          : Index of coastline points
%                     .x           : X-coordinate [m]
%                     .y           : Y-coordinate [m]
%                     .z           : Offset of coastline from reference line [m]
%                     .zminz0      : Offset of coastline from initial coastline [m]
%                     .sourceyear  : Yearly source volume in each cell [10^3 m3/yr]
%                     .sourcetotal : Total source volume in each cell [10^6 m3]
%                     .stored      : Stored volume in each cell [10^6 m3]
%                     .ray         : Index of transport points (in-between coastline points)
%                     .alfa        : Coastline angle (normal to coast) [°N]
%                     .transport   : Sediment transport [10^3 m3/yr]
%                     .volume      : Volume passed [10^6 m3]
%                     .xdist       : Distance along model for transport points [m]
%                     .xdist2      : Distance along model for coastline points [m]
%   
%   Example:
%     [data]=readPRN;
%     [data]=readPRN(dir('*.PRN'));
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

% $Id: readPRN.m 11826 2015-03-24 13:53:01Z huism_b $
% $Date: 2015-03-24 14:53:01 +0100 (Tue, 24 Mar 2015) $
% $Author: huism_b $
% $Revision: 11826 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readPRN.m $
% $Keywords: $

if nargin>=1
    PRNfilename  = varargin{1};
    [pathname,filen1,filen2]=fileparts(PRNfilename);
    filenames = [filen1,filen2];
end

if nargin==0
    % Get file
    try
        [filenames, pathname] = uigetfiles('*.prn','PRN-files (*.prn)');
    catch
        [filenames, pathname] = uigetfile('*.prn','PRN-files (*.prn)');
        filenames={filenames};
    end
end


%if ~iscell(files);
%    files=cellstr(files);
%end

data.files=filenames;
for ii=1:length(filenames)
    %-----------inlezen--------------
    fid = fopen([pathname,filesep,filenames{ii}],'r');
    inh=fread(fid);
    fclose(fid);
    
    % check line ends
    id10=find(inh==10);
    % read size of blocks 
    header=str2num(char(inh(id10(7)+1:id10(8)-1))');
    nrgridcells=header(1);
    
    % determine number of time steps
    nrsteps = round((length(id10)-2)/(2* nrgridcells +1+6+6));
    
    % read the data
    for tt=1:nrsteps
        
        iTIME =  3  +               + (2* nrgridcells +1+6+6) * (tt-1);
        iXY1  =  8  +               + (2* nrgridcells +1+6+6) * (tt-1);
        iXY2  =  9  + nrgridcells-1 + (2* nrgridcells +1+6+6) * (tt-1);
        iQS1  =  8  + nrgridcells+6 + (2* nrgridcells +1+6+6) * (tt-1);
        iQS2  =  9  + 2*nrgridcells+6 + (2* nrgridcells +1+6+6) * (tt-1);

        TIMEblock = str2num(char(inh(id10(iTIME):id10(iTIME+1)))');
        XYblock = str2num(char(inh(id10(iXY1)+1:id10(iXY2)-1))');
        QSblock = str2num(char(inh(id10(iQS1)+1:id10(iQS2)-1))');

        data.timestep(1,tt) = TIMEblock(1);
        data.year(1,tt)     = TIMEblock(2);
    
        data.no(:,tt) = [];%XYblock(:,1);
        data.xdist2=(QSblock(1:end-1,2)+QSblock(2:end,2))/2;
        data.x(:,tt) = XYblock(:,2);
        data.y(:,tt) = XYblock(:,3);
        data.z(:,tt) = XYblock(:,4);
        data.zminz0(:,tt) = XYblock(:,5);
        data.sourceyear(:,tt)= [];%XYblock(:,6);
        data.sourcetotal(:,tt)= [];%XYblock(:,7);
        data.stored(:,tt)= [];%XYblock(:,8);
        
        data.ray(:,tt) = [];%QSblock(:,1);
        data.xdist(:,1) = QSblock(:,2);       
        data.alfa(:,tt) = QSblock(:,3);
        data.transport(:,tt) = QSblock(:,4);
        data.volume(:,tt) = []; %QSblock(:,5);
    end
    
end