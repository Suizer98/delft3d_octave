function ITHK_writeSCO(varargin)
%write SCO : Writes an SCO file
%
%   Syntax:
%     function ITHK_writeSCO(SCOfilename,waterlevel,waveheight,waveperiod,direction,duration,X,Y,numOfDays)
% 
%   Input:
%     SCOfilename   string
%     waterlevel    [1xN] matrix
%     waveheight    [1xN] matrix
%     waveperiod    [1xN] matrix
%     direction     [1xN] matrix
%     duration      [1xN] matrix
%     X             number
%     Y             number
%     numOfDays     number
%
%   Output:
%     .sco files
% 
%   Example:
%     ITHK_writeSCO('test.sco',[0;0],[1.2;2.3],[6;9],[284;312],[10;1],576230,3457282,365)
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

% $Id: ITHK_writeSCO.m 6382 2012-06-12 16:00:17Z boer_we $
% $Date: 2012-06-13 00:00:17 +0800 (Wed, 13 Jun 2012) $
% $Author: boer_we $
% $Revision: 6382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/preprocessing/operations/OLD/ITHK_writeSCO.m $
% $Keywords: $
SCOfilename=varargin{1};
if nargin==2
    SCOdata    = varargin{2};
    waterlevel = SCOdata.h0(:);
    waveheight = SCOdata.hs(:);
    waveperiod = SCOdata.tp(:);
    direction  = SCOdata.xdir(:);
    duration   = SCOdata.dur(:);
    X          = SCOdata.x;
    Y          = SCOdata.y;
    numOfDays  = SCOdata.numOfDays;
else
    waterlevel = varargin{2}(:);
    waveheight = varargin{3}(:);
    waveperiod = varargin{4}(:);
    direction  = varargin{5}(:);
    duration   = varargin{6}(:);
    X          = varargin{7};
    Y          = varargin{8};
    numOfDays  = varargin{9};
end

fid = fopen(SCOfilename,'wt');

fprintf(fid,'%5.2f',numOfDays);
fprintf(fid,'             (Number of days)\n');
fprintf(fid,'%3.0f',length(waveheight));
fprintf(fid,'             (Number of waves   Location: X= ');
fprintf(fid,'%11.2f',X);
fprintf(fid,' Y= ');
fprintf(fid,'%11.2f',Y);
fprintf(fid,'  )\n');
fprintf(fid,'WAVM      H0            wave height   period   direction   Duration\n');
fprintf(fid,'   %14.3f%14.3f%14.3f%14.3f%14.5f\n',[waterlevel,waveheight,waveperiod,direction,duration]');
writedummyTIDE=0;
if writedummyTIDE==1
    fprintf(fid,'  1    (Number of Tide condition\n');
    fprintf(fid,'          DH            Vgety         Ref.depth   Perc\n');
    fprintf(fid,'             0.00          0.00          3.00        100.00\n');
end
st=fclose(fid);