function writeGRO(filename,GROdata,varargin)
%write GRO : Writes a unibest groyne file
%
%   Syntax:
%     function writeGRO(filename, GROdata)
% 
%   Input:
%     filename             string with output filename
%     GROdata              Structure with fields:
%         .Xw                   xy values ([Nx2] matrix or string with filename), note: if xy is empty, it is not required to specify parameters below (i.e. Yoffset, BlockPerc, Yreference)
%         .Yw                   xy values ([Nx2] matrix or string with filename), note: if xy is empty, it is not required to specify parameters below (i.e. Yoffset, BlockPerc, Yreference)
%         .Length               cross-shore distance of groyne ([Nx1] matrix in meters)
%         .BlockPerc            blocking percentage ([Nx1] matrix in percentages)
%         .Yreference           reference of Ycross ([Nx1] matrix with 0 = relative to shoreline (i.e. y(t)) and 1 = absolute, i.e. relative to reference line)
%         .option               type of local rays (specify either 'between&right', 'right', 'left', 'left&right' or 'between')
%                               leave the option parameter empty ('') if you do not want to specify local rays.
%     
%
%
%   Output:
%     .gro file
%
%   Example:
%     GROdata.Yw = 32;
%     GROdata.Length = 3.5;
%     GROdata.BlockPerc = 100;
%     GROdata.Yreference = 0;
%     GROdata.option = 'left&right';
%     GROdata.xyl         = [31,55];
%     GROdata.ray_file1   = {'a1'};
%     GROdata.xyr         = [33,57];
%     GROdata.ray_file2   = {'a2'};
%     writeGRO('test.gro', GROdata)
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

% $Id: writeGRO.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 16:01:51 +0800 (Fri, 07 May 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeGRO.m $
% $Keywords: $

%----------Input data of groynes------------
%-------------------------------------------
% Check structure GROdata
if ~isempty(GROdata)
    Ngroynes = length(GROdata);
    if ~isfield(GROdata,'Xw')
        dispstr = 'ERROR: Field Xw does not exist';
        disp(dispstr)
        return
    elseif ~isfield(GROdata,'Yw')
        dispstr = 'ERROR: Field Yw does not exist';
        disp(dispstr)
        return
    elseif ~isfield(GROdata,'Length')
        dispstr = 'ERROR: Field Length does not exist';
        disp(dispstr)
        return
    elseif ~isfield(GROdata,'BlockPerc')
        dispstr = 'ERROR: Field BlockPerc does not exist';
        disp(dispstr)
        return
    elseif ~isfield(GROdata,'Yreference')
        dispstr = 'ERROR: Field Yreference does not exist';
        disp(dispstr)
        return
    end
else
    dispstr = 'ERROR: GROdata is empty';
    disp(dispstr)
    return
end

% Check for empty fields
for ii = 1:Ngroynes
    if isempty(GROdata(ii).Xw)
        dispstr = ['ERROR: No Xw specified for groyne ' num2str(ii)];
        disp(dispstr)
        return
    elseif isempty(GROdata(ii).Yw)
        dispstr = ['ERROR: No Yw specified for groyne ' num2str(ii)];
        disp(dispstr)
        return
    elseif isempty(GROdata(ii).Length)
        dispstr = ['ERROR: No Length specified for groyne ' num2str(ii)];
        disp(dispstr)
        return
    elseif isempty(GROdata(ii).BlockPerc)
        dispstr = ['ERROR: No BlockPerc specified for groyne ' num2str(ii)];
        disp(dispstr)
        return
    elseif isempty(GROdata(ii).Yreference)
        dispstr = ['ERROR: No Yreference specified for groyne ' num2str(ii)];
        disp(dispstr)
        return        
    end
end

% Check option per groyne
for ii = 1:Ngroynes
    GROdata(ii).BlockPerc = max(GROdata(ii).BlockPerc,0.000001);
    if ~isfield(GROdata(ii),'SIDES')
        GROdata(ii).SIDES={};
    end
    if isfield(GROdata(ii),'option') && isempty(GROdata(ii).SIDES)
        %If option, check which option
        %1= no rays, 2=between&right, 3=right, 4=left, 5=left&right, 6=between
        if strfind(lower(GROdata(ii).option),'between2&right2')
             GROdata(ii).SIDES={'BETWEEN2','RIGHT2'};
        elseif strfind(lower(GROdata(ii).option),'between2&right')
             GROdata(ii).SIDES={'BETWEEN2','RIGHT'};
        elseif strfind(lower(GROdata(ii).option),'between&right2')
             GROdata(ii).SIDES={'BETWEEN','RIGHT2'};
        elseif strfind(lower(GROdata(ii).option),'between&right')
             GROdata(ii).SIDES={'BETWEEN','RIGHT'};
             
        elseif strfind(lower(GROdata(ii).option),'left2&right2')
             GROdata(ii).SIDES={'LEFT2','RIGHT2'};
        elseif strfind(lower(GROdata(ii).option),'left2&right')
             GROdata(ii).SIDES={'LEFT2','RIGHT'};
        elseif strfind(lower(GROdata(ii).option),'left&right2')
             GROdata(ii).SIDES={'LEFT','RIGHT2'};
        elseif strfind(lower(GROdata(ii).option),'left&right')
             GROdata(ii).SIDES={'LEFT','RIGHT'};

        elseif strfind(lower(GROdata(ii).option),'right2')
             GROdata(ii).SIDES={'RIGHT2'};
        elseif strfind(lower(GROdata(ii).option),'right')
             GROdata(ii).SIDES={'RIGHT'};
             
        elseif strfind(lower(GROdata(ii).option),'left2')
             GROdata(ii).SIDES={'LEFT2'};
        elseif strfind(lower(GROdata(ii).option),'left')
             GROdata(ii).SIDES={'LEFT'};

        elseif strfind(lower(GROdata(ii).option),'between2')
             GROdata(ii).SIDES={'BETWEEN2'};
        elseif strfind(lower(GROdata(ii).option),'between')
             GROdata(ii).SIDES={'BETWEEN'};
        end
    end
end


%------------Write data to file-------------
%-------------------------------------------
fid = fopen(filename,'wt');
fprintf(fid,'Groynes\n');
fprintf(fid,'%2.0f\n',Ngroynes);
for ii=1:Ngroynes
    fprintf(fid,'Xw      Yw      TOP      Block (%%)      Key_ar\n');
    fprintf(fid,'%1.2f      %6.2f      %4.2f       %3.0f       %1.0f\n',GROdata(ii).Xw,GROdata(ii).Yw,GROdata(ii).Length,GROdata(ii).BlockPerc,GROdata(ii).Yreference);

    for jj=1:length(GROdata(ii).SIDES)
        SIDE = GROdata(ii).SIDES{jj};
        % 'SIDE' can be 'BETWEEN','LEFT' and 'RIGHT'
        if strcmp(SIDE,'BETWEEN2') || strcmp(SIDE,'LEFT2') || strcmp(SIDE,'RIGHT2')
            if strcmp(SIDE,'BETWEEN2') || strcmp(SIDE,'LEFT2')
                FIELD1 = 'xyl';
                IDS = '1';
            elseif strcmp(SIDE,'RIGHT2') 
                FIELD1 = 'xyr';
                IDS = '2';
            end
            
            Nrays = size(GROdata(ii).(FIELD1),1);
            fprintf(fid,'%s%s%s\n','''',SIDE,'''');
            fprintf(fid,'      Aantal klimaatpunten\n');
            fprintf(fid,'      %1.0f\n',Nrays);
            fprintf(fid,'      Xw      Yw      .RAY\n');
            if Nrays>0
                for kk=1:Nrays
                    xlocal = GROdata(ii).(FIELD1)(kk,1); 
                    ylocal = GROdata(ii).(FIELD1)(kk,2); 
                    fprintf(fid,'      %1.2f  %11.2f ',xlocal,ylocal);
                    fprintf(fid,' ''%1s''',GROdata(ii).(['scofiles',IDS]){kk});
                    fprintf(fid,' ''%1s''',GROdata(ii).(['profiles',IDS]){kk});
                    fprintf(fid,' ''%1s''',GROdata(ii).(['cfsfiles',IDS]){kk});
                    fprintf(fid,' ''%1s''',GROdata(ii).(['cfefiles',IDS]){kk});
                    fprintf(fid,' ''%1s''',GROdata(ii).(['dform',IDS]){kk});
                    fprintf(fid,' %7.2f',GROdata(ii).(['hactive',IDS])(kk));
                    fprintf(fid,' %3.0f',GROdata(ii).(['nrpoints',IDS])(kk));
                    fprintf(fid,' \n');
                end
            end
        else    
            if strcmp(SIDE,'BETWEEN') || strcmp(SIDE,'LEFT')
                FIELD1 = 'xyl';
                FIELD2 = 'ray_file1';
                if ~isfield(GROdata,'ray_file1')
                    FIELD2 = 'rayfiles1';
                end
            elseif strcmp(SIDE,'RIGHT') 
                FIELD1 = 'xyr';
                FIELD2 = 'ray_file2';
                if ~isfield(GROdata,'ray_file2')
                    FIELD2 = 'rayfiles2';
                end
            end
            Nrays = size(GROdata(ii).(FIELD1),1);
            fprintf(fid,'%s%s%s\n','''',SIDE,'''');
            fprintf(fid,'Aantal klimaatpunten\n');
            fprintf(fid,'      %1.0f\n',Nrays);
            fprintf(fid,'      Xw      Yw      .RAY\n');
            if Nrays>0
                for kk=1:Nrays
                    fprintf(fid,'      %1.2f  %11.2f      ''%s''\n',GROdata(ii).(FIELD1)(kk,1),GROdata(ii).(FIELD1)(kk,2),GROdata(ii).(FIELD2){kk});
                end
            end
        end    
    end
    fprintf(fid,'''END''\n');
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



