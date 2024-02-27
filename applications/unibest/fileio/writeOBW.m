function writeOBW(filename, varargin)
%write OBW : Creates an OBW-file
%
%   Syntax:
%     function writeOBW(filename, locations, localrays)
%     function writeOBW(filename, OBW)
% 
%   Input:
%     filename     string with output filename
%     locations    (optional) cellstring with location of OBWs {[A_x1,A_y2,A_x2,A_y2],[B_x1,B_y2,B_x2,B_y2], etc}
%     localrays    (optional) cellstring with local rays for each OBW (leave empty if no local rays) { { }, {10,2,'Bray1';12,1,'Bray2'} }
% 
%   Input: (alternative)
%     filename          string with output filename
%     OBW(nn)           structure with all data of offshore breakwaters (with 'nn' the breakwater number)
%         .Xw           X-coordinates of breakwater [2x]
%         .Yw           Y-coordinates of breakwater [2x]
%         .local        index of type of local climate
%                       0  : no local climate
%                       1  : local climate using pre-computed ray-files
%                       2  : both sides of breakwater seperate (2x number of conditions)
%                       3  : both sides of breakwater vectorial addition after diffraction at both sides (i.e. mean wave angle)
%                       4  : both sides of breakwater seperate (2x number of conditions) & wave transmission
%                       5  : both sides of breakwater vectorial addition after diffraction at both sides (i.e. mean wave angle) & wave transmission
%         .xlocal       (local>=1)  X-locations of local rays [Nx1]
%         .ylocal       (local>=1)  Y-locations of local rays [Nx1]
%         .rayfiles     (local=1)   filenames of local rays {Nx1}
%         .scofiles     (local>=2)  filenames of local sco-file {Nx1}
%         .profiles     (local>=2)  filenames of local pro-file {Nx1}
%         .cfsfiles     (local>=2)  filenames of local cfs-file {Nx1}
%         .cfefiles     (local>=2)  filenames of local cfe-file {Nx1}
%         .dform        (local>=2)  name of diffraction routine {Nx1} (e.g. 'Kamphuis') 
%         .hactive      (local>=2)  active height (m) [Nx1]
%         .nrpoints     (local>=2)  number of computed diffraction points [Nx1]
%         .depth        (local>=4)  depth of breakwater (for computing KH value) (m) [Nx1]
%         .crestwidth   (local>=4)  crest width (m) [Nx1]
%         .crestheight  (local>=4)  crest height w.r.t. water level (m) [Nx1] (e.g. -0.5 m)
%         .beachslope   (local>=4)  beach slope (-) [Nx1]
%
%   Output:
%     .obw file
%
%   Example:
%     writeOBW('test.obw', {[100,200,400,200],[600,150,700,150]}, {{},{600,50,'ray1';750,50,'ray2'}})
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 Deltares
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
% Created: 26 Jul 2019
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeOBW.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 16:01:51 +0800 (Fri, 07 May 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeOBW.m $
% $Keywords: $

%-----------Write data to file--------------
%-------------------------------------------

err=0;
type=1;
if isstruct(varargin{1})
    OBW=varargin{1};
    
else
    locations = varargin{1};
    localrays = {};
    if nargin>=3
        localrays = varargin{2};
    end
    
    OBW=struct;
    for ii=1:length(locations)
        OBW(ii).Xw = locations{ii}([1,3]);
        OBW(ii).Yw = locations{ii}([2,4]);
        OBW(ii).local = 0;
        if ~isempty(localrays)
            if ~isempty(localrays{ii})
                OBW(ii).local = 1;
                OBW(ii).xlocal = localrays{ii}{1};
                OBW(ii).ylocal = localrays{ii}{2};
                OBW(ii).rayfiles = localrays{ii}{3};
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fid = fopen(filename,'wt');
no_obws = length(OBW);
fprintf(fid,'Offshore breakwaters\n');
fprintf(fid,'%1.0f\n',no_obws);
for ii=1:no_obws
    fprintf(fid,'Xw1      Yw1       Xw2       Yw2 \n');
    fprintf(fid,'%9.2f %9.2f %9.2f %9.2f\n',OBW(ii).Xw(1),OBW(ii).Yw(1),OBW(ii).Xw(2),OBW(ii).Yw(2));
    
    if OBW(ii).local==1
        % regular local rays
        fprintf(fid,'   ''LOCAL''\n'); 
        fprintf(fid,'   NUMBER OF TRANSPORT POINTS\n'); 
        fprintf(fid,'   %1.0f\n',length(OBW(ii).rayfiles)); 
        fprintf(fid,'   Xw        Yw        .RAY\n'); 
        for jj=1:length(OBW(ii).rayfiles)
            rayfile = regexprep(OBW(ii).rayfiles{jj},'.ray',''); 
            fprintf(fid,'   %9.2f  %9.2f  ''%s''\n',OBW(ii).xlocal(jj),OBW(ii).ylocal(jj),rayfile); 
        end
        
    elseif OBW(ii).local>=2
        % automatic diffraction of rays
        %'LOCAL2'
        %NUMBER OF TRANSPORT POINTS
        % 2
        %  Xw          Yw      .SCO    .PRO     .CFS      .CFE      dform   hactive nrpoints  Depth  Bcrest  Hcrest  BCHslope
        %3500.00      50.00   'LOC03' 'RECHT' 'DEFAULT' 'DEFAULT' 'kamphuis'   5       6        4      19    -0.25     200
        %6500.00      50.00   'LOC03' 'RECHT' 'DEFAULT' 'DEFAULT' 'kamphuis'   5       6        4      19    -0.25     200
        fprintf(fid,'   ''LOCAL%1.0f''\n',OBW(ii).local);
        fprintf(fid,'   NUMBER OF TRANSPORT POINTS\n');
        fprintf(fid,'   %1.0f\n',length(OBW(ii).xlocal));
        fprintf(fid,'   Xw          Yw        .SCO       .PRO      .CFS      .CFE      dform     hactive   nrpoints');
        if OBW(ii).local==4 || OBW(ii).local==5
        fprintf('   Slope      Cw      Ch    Beachslope ');
        end
        fprintf(fid,'\n');
        
        for jj=1:length(OBW(ii).scofiles)
            scofile = regexprep(OBW(ii).scofiles{jj},'.sco',''); 
            profile = regexprep(OBW(ii).profiles{jj},'.pro',''); 
            cfsfile = regexprep(OBW(ii).cfsfiles{jj},'.cfs',''); 
            cfefile = regexprep(OBW(ii).cfefiles{jj},'.cfe',''); 
            
            if OBW(ii).local==2 || OBW(ii).local==3
                fprintf(fid,'   %9.2f  %9.2f  ''%s'' ''%s'' ''%s'' ''%s'' ''%s'' %8.2f %8.0f \n',OBW(ii).xlocal(jj),OBW(ii).ylocal(jj),...
                scofile,profile,cfsfile,cfefile,OBW(ii).dform{jj},OBW(ii).hactive(jj),OBW(ii).nrpoints(jj)); 
            elseif OBW(ii).local==4 || OBW(ii).local==5
                fprintf(fid,'   %9.2f  %9.2f  ''%s'' ''%s'' ''%s'' ''%s'' ''%s'' %8.2f %8.0f %8.3f %8.2f %8.2f %8.2f \n',OBW(ii).xlocal(jj),OBW(ii).ylocal(jj),...
                scofile,profile,cfsfile,cfefile,OBW(ii).dform{jj},OBW(ii).hactive(jj),OBW(ii).nrpoints(jj),...
                OBW(ii).depth(jj),OBW(ii).crestwidth(jj),OBW(ii).crestheight(jj),OBW(ii).beachslope(jj)); 
            end  
        end
        
    end
    fprintf(fid,'''END''\n');
end
fclose(fid);


