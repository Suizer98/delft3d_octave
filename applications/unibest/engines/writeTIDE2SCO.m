function writeTIDE2SCO(sco_file, Vgetij, refDepth, Occurence, varargin)
%writeTIDE2SCO : Writes a tide table below an existing SCO-file
%
%   Syntax:
%     function writeTIDE2SCO(sco_file, Vgetij, refDepth, Occurence, DH)
% 
%   Input:
%     sco_file         string
%     DH               Tidal amplitude for each tidal condition (m), [1xN] matrix or single value (optional, default = 0)
%     Vgetij           Tidal velocity for each tidal condition (m/s), [1xN] matrix
%     refDepth         Depth of tidal data (m w.r.t. MSL), [1xN] matrix or single value
%     Occurence        Occurence of each condition (% of a year), [1xN] matrix
%
%   Output: 
%     .sco files
%   
%   Example:
%     Vgetij    = [0.2; 1; -0.1; -0.9];
%     refDepth  = [8; 8; 8; 8];
%     Occurence = [25; 25; 25; 25];
%     DH        = [-0.5; 0; 0.5; 0];
%     writeTIDE2SCO('test.sco', Vgetij, refDepth, Occurence, DH);
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

% $Id: writeTIDE2SCO.m 3286 2012-03-21 15:12:51Z huism_b $
% $Date: 2012-03-21 16:12:51 +0100 (Wed, 21 Mar 2012) $
% $Author: huism_b $
% $Revision: 3286 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/SCOextract/writeTIDE2SCO.m $
% $Keywords: $

%-------------analyse input---------------
%-----------------------------------------
if nargin==4
    DH = 0;
else
    DH = varargin{1};
end

% if DH or refDepth is single value -> make matrix for each condition
if length(DH) < length(Vgetij)
    DH = repmat(DH(1),[length(Vgetij),1]);
end
if length(refDepth) < length(Vgetij)
    refDepth = repmat(refDepth(1),[length(Vgetij),1]);
end

DH        = reshape(DH,[length(DH),1]);
Vgetij    = reshape(Vgetij,[length(Vgetij),1]);
refDepth  = reshape(refDepth,[length(refDepth),1]);
Occurence = reshape(Occurence,[length(Occurence),1]);

%-------------read SCO data---------------
%-----------------------------------------
fid1 = fopen(sco_file,'rt');
inhoud = fread(fid1);
fclose(fid1);

%-------------write SCO data--------------
%-----------------------------------------
fid2 = fopen(sco_file,'wt');
fwrite(fid2,inhoud);
fprintf(fid2,' %4.0f   (Number of Tide conditions)\n',length(DH));
fprintf(fid2,'          DH         Vgety      Ref.depth      Perc\n');
fprintf(fid2,' %12.2f %12.2f %12.2f %12.2f\n',[DH, Vgetij, refDepth, Occurence]');
fclose(fid2);