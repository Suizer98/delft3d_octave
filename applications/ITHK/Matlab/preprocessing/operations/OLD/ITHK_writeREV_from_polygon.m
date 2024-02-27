function ITHK_writeREV(rev_filename, revetment, varargin)
%write REV : Writes a unibest rev-file (can also compute cross-shore distance between reference line and revetment)
%
%   Syntax:
%     function ITHK_writeREV(filename, revetment, revtype, reference_line, dx)
%     OR
%     function ITHK_writeREV(filename, revetment, revtype, y_offset)
% 
%   Input option 1: (specify y_offset):
%     rev_filename        string with output filename of rev-file
%     revetment           cellstring with filename of polygon of revetment
%     revtype             (optional) revetment type (relative to shoreline =0 or relative to reference line =1) (default =0)
%     y_offset            (optional) cellstring with values or matrix for each revetment (if not specified, y_offset = 0)
%
%   Input option 2: (specify two landboundaries, i.e. for the revetment and for the shoreline/referenceline):
%     rev_filename        string with output filename of rev-file
%     revetment           cellstring with filename of polygon of revetment
%     revtype             (optional) revetment type (relative to shoreline =0 or relative to reference line =1) (default =0)
%     reference_line      (optional) cellstring with filename(s) of polygon(s) of referenceline(s)
%     dx                  (optional) resolution to cut up baseline (default = 0.05)
%
%   Output:
%     .rev files
% 
%   Example:
%     ITHK_writeREV('default.rev', 'revetment.pol', 1, 'D:\reference_line.ldb')             % option 1
%     ITHK_writeREV('default.rev', 'revetment.pol', 1, 'D:\reference_line.ldb', 0.05)       % option 2
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

% $Id: ITHK_writeREV_from_polygon.m 6464 2012-06-19 16:15:38Z huism_b $
% $Date: 2012-06-20 00:15:38 +0800 (Wed, 20 Jun 2012) $
% $Author: huism_b $
% $Revision: 6464 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeREV_from_polygon.m $
% $Keywords: $

%---------------Initialise------------------
%-------------------------------------------
dx        = 0.05;
option    = 0;
y_offset  = 0;
y_offset2 = {};
if nargin == 3
    option          = varargin{1};
elseif nargin == 4
    option          = varargin{1};
    option2         = 1;
    y_offset        = varargin{2};
elseif nargin == 5
    option          = varargin{1};
    option2         = 2;
    reference_line  = varargin{2};
    dx              = varargin{3};
end

%--------------Analyse data-----------------
%-------------------------------------------
%% READ revetment data
if isstr(revetment)
    revetm={revetment};
end
number_of_revetments = length(revetment);
if iscell(revetment)
    if isstr(revetment{1})
        for ii=1:number_of_revetments
            ldb=readldb(revetment{ii});
            revetm{ii}=[ldb.x,ldb.y];
        end
    else
        revetm=revetment;
    end
end

%% READ reference line data
if exist('reference_line','var')
    if isstr(reference_line)
        reference_line={reference_line};
    end
end



%% OUTPUT
jj=0;
if option2==1
    for ii=1:number_of_revetments
        id=find(revetm{ii}(:,1)~=999.999);
        revetm{ii}=[revetm{ii}(id,1),revetm{ii}(id,2)];
        number_of_points = size(revetm{ii},1);
        revetm_parts = ceil((number_of_points-20)/19+1);
        for iii=1:revetm_parts
            jj=jj+1;
            id1 = (iii-1)*19+1;
            id2 = min(number_of_points,iii*19+1);
            xyNew{jj}    = revetm{ii}(id1:id2,:);
            y_offset2{jj} = repmat(y_offset,[id2-id1+1,1]);
            if isnumeric(y_offset{ii})
                if size(y_offset{ii},1)==1
                    y_offset2{jj} = repmat(y_offset{ii},[id2-id1+1,1]);
                else
                    y_offset2{jj} = y_offset{ii}(id1:id2);
                end
            end
        end
    end
elseif option2==2
    for ii=1:number_of_revetments
        xyNew0=[];y_offset=[];

        % load baseline
        xy=readldb(reference_line{ii});
 
        % make it two colums
        id=find(xy.x~=999.999);
        xy=[xy.x(id),xy.y(id)];

        % load real revetment line
        %revetm{ii}=flipud(landboundary('read','walcheren_RD.ldb'));
        revetm{ii}=readldb(revetment{ii});
        id=find(revetm{ii}(:,1)~=999.999);
        revetm{ii}=[revetm{ii}(id,1),revetm{ii}(id,2)];

        [xyNew0, y_offset] = ITHK_relativeoffset(xy,revetm{ii},dx);
        
        number_of_points = size(xyNew0,1);
        revetm_parts = ceil((number_of_points-20)/19+1);
        for iii=1:revetm_parts
            jj=jj+1;
            id1 = (iii-1)*19+1;
            id2 = min(number_of_points,iii*19+1);
            xyNew{jj}     = xyNew0(id1:id2,:);
            y_offset2{jj} = y_offset(id1:id2)';
        end
    end
end
number_of_revetments = length(y_offset);

%-----------Write data to file--------------
%-------------------------------------------
fid=fopen(rev_filename,'wt');
fprintf(fid,'%s\n','revetment groups');
fprintf(fid,'%11.0f\n',length(y_offset2));

for ii=1:length(y_offset2)
    number_of_points = length(y_offset2{ii});
    fprintf(fid,'%s\n','Number   Key_ar');
    fprintf(fid,' %3.0f %3.0f\n',number_of_points,option);
    fprintf(fid,'%s\n','         Xw             Yw             Top');
    fprintf(fid,'% 10.2f  %10.2f  %10.1f\n',[xyNew{ii} y_offset2{ii}]');
end
fclose(fid);
