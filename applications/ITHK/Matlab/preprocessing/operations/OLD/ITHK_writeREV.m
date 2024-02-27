function ITHK_writeREV_new(REVdata,varargin)
%write REV : Writes a unibest rev-file (can also compute cross-shore distance between reference line and revetment)
%
%   Syntax:
%     function ITHK_writeREV_new(REVdata)
% 
%   Input:
%     REVdata               structure with the following fields
%                           - filename:     name of REV-file
%                           - Xw:           x-coordinates of the revetment
%                           - Yw:           y-coordinates of the revetment
%                           - Top:          offset of the revetment with respect to specified reference (specified in option), 
%                                           if this field is left empty MDAdata will be used to calculate the offset
%                           - Option:       (0) revetment relative to shoreline
%                                           (1) revetment relative to reference line
%                                           (2) landfill with revetment relative to shoreline
%                                           (3) landfill with revetment relative to reference line
%   Optional:
%     MDAdata               (optional) structure with MDAdata, used to calculate offset between revetment and reference line, when no offset is indicated
%     dx                    (optional) resolution to cut up baseline (default = 0.05)
%
%   Output:
%     .rev file
% 
%   Example:
%     ITHK_writeREV(REVdata,MDAdata,dx)             
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer
%
%       wiebe.deboer@deltares.nl	
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
% Created: 13 Sep 2011
% Created with Matlab version: 7.11.0 (R2010b)

% $Id: ITHK_writeREV.m 6464 2012-06-19 16:15:38Z huism_b $
% $Date: 2012-06-20 00:15:38 +0800 (Wed, 20 Jun 2012) $
% $Author: huism_b $
% $Revision: 6464 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeREV.m $
% $Keywords: $

%---------------Initialise------------------
%-------------------------------------------
if length(varargin)==2
    dx = varargin{2};
else
    dx = 0.05;
end
%--------------Analyse data-----------------
%-------------------------------------------
%% READ revetment data
number_of_revetments = length(REVdata);
for ii=1:length(REVdata)
    Npoints = length(REVdata(ii).Xw);
    if isempty(REVdata(ii).Top)
        if isempty(varargin)
            disp('Please specify MDAdata')
            return
        end
        MDAdata = varargin{1};
        opt = REVdata(ii).Option;
        switch opt
            case 0
                xy=[MDAdata.Xcoast,MDAdata.Ycoast];
            case 1
                xy=[MDAdata.Xi,MDAdata.Yi];
            case 2
                xy=[MDAdata.Xcoast,MDAdata.Ycoast];
            case 3
                xy=[MDAdata.Xi,MDAdata.Yi];
        end
        [xyNew0{ii}, y_offset{ii}] = ITHK_relativeoffset(xy,[REVdata(ii).Xw',REVdata(ii).Yw'],dx);
    else
        xyNew0{ii} = [REVdata(ii).Xw',REVdata(ii).Yw'];
        y_offset{ii} = REVdata(ii).Top;
    end
end

%-----------Write data to file--------------
%-------------------------------------------
fid=fopen(REVdata(ii).filename,'wt');
fprintf(fid,'%s\n','NUMBER OF REVETMENT SECTIONS');
fprintf(fid,' %1.0f\n',number_of_revetments);

for ii=1:number_of_revetments
    number_of_points = length(REVdata(ii).Xw);
    fprintf(fid,'%s\n','NUMBER      KEY_ARR');
    fprintf(fid,' %1.0f %7.0f\n',number_of_points,REVdata(ii).Option);
    fprintf(fid,'%s\n','Xw      Yw      Top');
    for jj=1:number_of_points
        fprintf(fid,'%6.2f      %6.2f      %1.2f\n',[xyNew0{ii}(jj,1) xyNew0{ii}(jj,2) y_offset{ii}(jj)']);
    end
end
fclose(fid);
