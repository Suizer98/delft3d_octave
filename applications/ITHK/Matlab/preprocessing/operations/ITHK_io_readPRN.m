function [PRNdata]=ITHK_io_readPRN(varargin)
%read PRN : Reads PRN-files and puts data into a struct
%   
%   Syntax:
%     function [PRNdata]=ITHK_io_readPRN(PRNfilename)
%   
%   Input:
%     PRNfilename    (optional) struct with path and filenames, in the following fields
%            PRNfilename.path    = string with path
%            PRNfilename.files   = cellstring with filenames
%   
%   Output:
%     PRNdata       struct with contents of prn file
%                     .name    :  string with filename
%                     .path    :  string with path of file
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
%     [PRNdata]=ITHK_io_readPRN;
%     [PRNdata]=ITHK_io_readPRN(dir('*.PRN'));
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

% $Id: ITHK_io_readPRN.m 6502 2012-06-21 09:24:34Z huism_b $
% $Date: 2012-06-21 17:24:34 +0800 (Thu, 21 Jun 2012) $
% $Author: huism_b $
% $Revision: 6502 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/ITHK_io_readPRN.m $
% $Keywords: $

if nargin==1
    PRNfilename  = varargin{1};
    if isstr(PRNfilename)
        [pathname,filen1,filen2]=fileparts(PRNfilename);
        filenames = [filen1,filen2];
    elseif isstruct(PRNfilename)
        if isfield(PRNfilename,'name')
            pathname  = '';        
            for ii=1:length(PRNfilename)
                filenames{ii} = PRNfilename(ii).name;
            end
        else
            pathname  = PRNfilename.path;
            filenames = PRNfilename.files;
        end
    end
    if isstr(filenames)
        filenames = {filenames};
    end
    if isempty(pathname)
        pathname=cd;
    end
else
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

PRNdata.files=filenames;
for ii=1:length(filenames)
    %-----------inlezen--------------
    fid = fopen([pathname,filesep,filenames{ii}],'r');
    for iii=1:2
    tline = fgetl(fid);
    end

    teller =0;
    while 1
        teller = teller +1;
        
        % regel 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end   

        % regel 2
        tline = fgetl(fid); 
        [PRNdata.timestep(teller,ii) PRNdata.year(teller,ii)]=strread(tline,'%f%f');

        % regel 3-6
        for iii=1:4 
        tline=fgetl(fid);
        end
            [rijen kolommen]=strread(tline,'%f%f');
            if teller==1 & ii==1
            % maak lege data matrix
            end
        
        %lees data 1
        for iii=1:rijen
           tline=fgetl(fid); 
           %gridcell  X-coord.  Y-coord.   Y    Y-Y0   source[km3/y]  source[Mm3]  stored[Mm3]
           [data1.no(iii) data1.x(iii) data1.y(iii) data1.z(iii) data1.zminz0(iii) data1.sourceyear(iii) data1.sourcetotal(iii) data1.stored(iii)]=strread(tline,'%f%f%f%f%f%f%f%f');
        end
        PRNdata.no(:,teller,ii)=data1.no(:);
        PRNdata.x(:,teller,ii)=data1.x(:);
        PRNdata.y(:,teller,ii)=data1.y(:);
        PRNdata.z(:,teller,ii)=data1.z(:);
        PRNdata.zminz0(:,teller,ii)=data1.zminz0(:);
        PRNdata.sourceyear(:,teller,ii)=data1.sourceyear(:);
        PRNdata.sourcetotal(:,teller,ii)=data1.sourcetotal(:);
        PRNdata.stored(:,teller,ii)=data1.stored(:);
                
        % skip tussenkop
        for iii=1:6
        fgetl(fid);
        end
        % lees data 2
        for iii=1:rijen+1 
           tline=fgetl(fid); 
           %ray	X	alfa	transport	vol.passed
           [data1.ray(iii) data1.xdist(iii) data1.alfa(iii) data1.transport(iii) data1.volume(iii)]=strread(tline,'%f%f%f%f%f');
        end
        PRNdata.ray(:,teller,ii)=data1.ray(:);
        PRNdata.alfa(:,teller,ii)=data1.alfa(:);
        PRNdata.transport(:,teller,ii)=data1.transport(:);
        PRNdata.volume(:,teller,ii)=data1.volume(:);       
    end
    fclose(fid);
    PRNdata.xdist(:,ii)=data1.xdist(:);
    PRNdata.xdist2(:,ii)=mean([PRNdata.xdist(1:end-1,ii) PRNdata.xdist(2:end,ii)],2);
end