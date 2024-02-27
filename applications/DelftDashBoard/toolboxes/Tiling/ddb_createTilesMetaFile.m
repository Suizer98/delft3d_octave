function ddb_createTilesMetaFile(dr, dataname, nrzoom, dxk, dyk, nnxk, nnyk, nxk, nyk, x0, y0, OPT)
%DDB_CREATETILESMETAFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_createTilesMetaFile(dr, dataname, nrzoom, dxk, dyk, nnxk, nnyk, nxk, nyk, x0, y0, OPT)
%
%   Input:
%   dr       =
%   dataname =
%   nrzoom   =
%   dxk      =
%   dyk      =
%   nnxk     =
%   nnyk     =
%   nxk      =
%   nyk      =
%   x0       =
%   y0       =
%   OPT      =
%
%
%
%
%   Example
%   ddb_createTilesMetaFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_createTilesMetaFile.m 5560 2011-12-02 11:26:29Z boer_we $
% $Date: 2011-12-02 19:26:29 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5560 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_createTilesMetaFile.m $
% $Keywords: $

%%
for k=1:nrzoom
    nnx=nnxk(k);
    nny=nnyk(k);
    nav=0;
    
    flist2=dir([dr 'zl' num2str(k,'%0.2i') '\*.nc']);
    iin=[];
    jin=[];
    for jjj=1:length(flist2)
        iin(jjj)=str2double(flist2(jjj).name(end-13:end-9));
        jin(jjj)=str2double(flist2(jjj).name(end-7:end-3));
    end
    
    for i=1:nnx
        for j=1:nny
            iava=find(iin==i & jin==j, 1);
            if ~isempty(iava)
                nav=nav+1;
                iavailable{k}(nav)=i;
                javailable{k}(nav)=j;
            end
        end
    end
end
fnamemeta=[dr dataname '.nc'];
nc_createNCmetafile(fnamemeta,x0,y0,dxk,dyk,nnxk,nnyk,nxk,nyk,iavailable,javailable,OPT);

