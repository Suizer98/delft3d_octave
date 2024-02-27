function extractSCO(input_data,path_out,locations,varargin)
%extractSCO : Extracts data from WAVM-file and writes unibest sco-files
%The program extracts SCO-files from WAVM files. These SCO-files are 
%already in UNIBEST format (with tide header with zero tide) and are 
%automatically thinned out (very small wave conditions). It is possible to 
%select more than one WAVM file, if the specified location is not found in 
%WAVM number 1 (on top of the list) the next WAVM file will be used.
%
%   Syntax:
%     function extractSCO(input_data,path_out,locations, SCOfilename,durations,tide_conditions)
% 
%   Input:
%    input_data           struct with filenames, with for each field a string with filename OR cellstring with filenames
%                           - input_data.wavm    : cell string with wawm filenames. 
%                           - input_data.path    : optional, default = '')
%    path_out             string with output_path for sco-files
%    locations            string with filename or matrix [Nx2] of the locations at which wave heights should be derived
%    SCOfilename          string or cellstr with filename of sco-files (optional, default = 'file')
%    durations            string with filename of offshore sco-file or vector [Nx1] with durations for every location
%    tide_conditions      struct with schematised tide conditions (optional, default = [0,0,8,100])
%                           - tide_conditions.DH         [Mx1]
%                           - tide_conditions.Vgetij     [Mx1]
%                           - tide_conditions.refDepth   [Mx1]
%                           - tide_conditions.Occurence  [Mx1]
% 
%   Output:
%     .sco files
%   
%   Example:
%     extractSCO(input_data,path_out,locations)
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

% $Id: extractSCO.m 3773 2015-09-09 13:24:53Z huism_b $
% $Date: 2015-09-09 15:24:53 +0200 (Wed, 09 Sep 2015) $
% $Author: huism_b $
% $Revision: 3773 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/SCOextract/extractSCO.m $
% $Keywords: $

%-------------------------------------------------------------------------
%---------------------------------INPUT-----------------------------------
%-------------------------------------------------------------------------
numOfDays = 365;
tide.DH                = [0];
tide.Vgetij            = [0];
tide.refDepth          = [8];
tide.Occurence         = [100]; % percentage
SCOfilename            = 'ray';
durations              = 0;
numOfDays              = 365;
removeSMALLwaves       = false;
if nargin>=4
    SCOfilename            = varargin{1};
end
if nargin>=5
    durations              = varargin{2};
end
if nargin>=6
    tide                   = varargin{3};
end
if nargin>=7
    numOfDays              = varargin{4};
end
if nargin>=8
    removeSMALLwaves       = varargin{5};
end

if isstr(input_data.wavm)
    input_data.wavm={input_data.wavm};
end
if isstr(input_data.path)
    input_data.path=num2cell(repmat(input_data.path,[length(input_data.wavm),1]),2);
end

% Read locations:
if iscell(locations)
    locations={locations};
end
if isstr(locations)
    locs = readldb(locations);
    locs = [locs.x locs.y];
else
    locs = locations;
end

% make sure to have tide available for every output location
if length(tide)==1
    for ii=1:size(locs,1)
        tide(ii)=tide(1);
    end
end
 
% Read durations:
if iscell(durations)
    durations={durations};
end
if isnumeric(durations)
    dur = durations;
else
    % Derive duration from offshore_SCO
    [h0,Hs,Tp,xdir0,dur,x,y,numOfDays]=readSCO(durations);
end

if isstr(SCOfilename)
    SCOfilename=num2cell([repmat(SCOfilename,[size(locs,1),1]),num2str([1:size(locs,1)]','%03.0f')],2);
end
if length(SCOfilename)>0
    if iscell(SCOfilename{1})
        fprintf('Error : Input of ''SCOfilename'' not suitable!\n');
        return
    end
end
%-------------------------------------------------------------------------
%--------------------------------PROGRAM----------------------------------
%-------------------------------------------------------------------------

%% check which wavm file covers the output location (stored in wavm_select)
IN={};SCO_file2={};
wavm_select = repmat(0,[size(locs,1),1]);
for ii=1:length(input_data.wavm)
    wavm=[input_data.path{ii},input_data.wavm{ii}];
    vs_use(wavm);
    XP = vs_get('map-series',{1},'XP','quiet');
    YP = vs_get('map-series',{1},'YP','quiet');

    % detect if points are inside grid (works only for regular grids)
    xv = [XP(1,1);XP(1,end);XP(end,end);XP(end,1);XP(1,1)]; 
    yv = [YP(1,1);YP(1,end);YP(end,end);YP(end,1);YP(1,1)];
    IN{ii} = inpolygon(locs(:,1),locs(:,2),xv,yv);
    IN{ii}(IN{ii}~=1)=1;
    % procedure for curvi-linear grids (still to be continued)
    % for nn=1:size(locs,1)
    %     dists=sqrt((XP-locs(nn,1)).^2+(YP-locs(nn,2)).^2);
    %     sortDists=sort(dists(:));
    %     [m0,n0]=find(dists==sortDists(1));
    %     x1 = XP(m0,n0);
    %     y1 = YP(m0,n0);
    %     dists2=sqrt((XP-x1).^2+(YP-y1).^2);
    %     sortDists2=sort(dists2(:));
    %     %sortDists(2)
    %     [m1,n1]=find(dists2==sortDists2(4));
    %     x2 = XP(m1,n1);
    %     y2 = YP(m1,n1);
    %     dist3(nn)=sqrt((x2-x1).^2+(y2-y1).^2);
    %     if sortDists(1)<2*dist3
    %         IN{ii}(nn)=1;
    %     else
    %         IN{ii}(nn)=0;
    %     end
    % end
    % xv = [XP(1,1:end-1)';XP(1:end-1,end);XP(end,1:end-1)';XP(1:end-1,1)];
    % yv = [YP(1,1:end-1)';YP(1:end-1,end);YP(end,1:end-1)';YP(1:end-1,1)];

    wavm_select(wavm_select==0 & IN{ii}==1)=ii;
    time = vs_get('map-series','TIME','quiet');
end

if length(dur)==1
    dur = repmat(dur, [length(time),1]); 
end

%% derive sco from wavm and add tide information
fid=fopen('extractSCO.log','wt');
h_wbar = waitbar(0,['Extracting wave data']);
for ii=1:size(locs,1)
    waitbar(ii/size(locs,1));
    SCO_file2{ii} = [path_out,SCOfilename{ii},'.sco'];

    if wavm_select(ii)~=0
        warning off
        wavm=[input_data.path{wavm_select(ii)},input_data.wavm{wavm_select(ii)}];
        wavm2SCOinterp(wavm,locs(ii,1),locs(ii,2),SCO_file2{ii},dur,numOfDays);
        %[h0,Hs,Tp,xdir0,dur0,x,y,numOfDays] = readSCO(SCO_file2{ii});
        %writeSCO(SCO_file2{ii},h0,Hs,Tp,xdir0,dur,x,y,numOfDays)
        
        if removeSMALLwaves
            % BELOW LINE MESSES UP WAVE ROSES AND -CLIMATES, CONDITIONS SHOULD
            % NOT BE REMOVED BUT MINIMUM VALUES SHOULD BE USED (OR DURATIONS OF 
            % REMOVED CONDITIONS SHOULD BE SUBTRACTED FROM TOTAL, PKT 22-12-14
            removeSCOcond(SCO_file2{ii},'Hs',0.01,'Tp',1);  
        end
        
        writeTIDE2SCO(SCO_file2{ii},tide(ii).Vgetij, tide(ii).refDepth, tide(ii).Occurence, tide(ii).DH);
        warning on
        fprintf(fid,[' location %03.0f (%s) extracted from wavm file :  %s\n'],ii,SCO_file2{ii},wavm);
    else
        fprintf([' ------ warning : location ',num2str(ii),' not within any of the grids! ------\n']);
        fprintf(fid,[' location %03.0f (%s) exracted from wavm file :  %s\n'],ii,SCO_file2{ii},'no wavm found!');
    end
end
fclose(fid);
close(h_wbar);

end
