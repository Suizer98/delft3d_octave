function ddb_dnami_loadArea()
%DDB_DNAMI_LOADAREA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_dnami_loadArea(())
%
%   Input:
%   () =
%
%
%
%
%   Example
%   ddb_dnami_loadArea
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

% $Id: ddb_dnami_loadArea.m 10889 2014-06-25 08:09:38Z boer_we $
% $Date: 2014-06-25 16:09:38 +0800 (Wed, 25 Jun 2014) $
% $Author: boer_we $
% $Revision: 10889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/dnami/ddb_dnami_loadArea.m $
% $Keywords: $

%%
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth    disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch  mrkrpatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%
global progdir   datadir    workdir     tooldir ldbfile

%
[name,pat]=uigetfile([datadir '*.png; *.jpg'],'Select file');
if name==0
    return
end

%
% Set the present directory as the work directory
%
filename = [pat name];
set(findobj(gcbf,'tag','AreaFilename'),'string',filename);
[pathstr, name, ext] = fileparts(filename);

%
% Reinitialise all values
%
ddb_dnami_initValues()

%
% Read from file the header (area limitation of the image)
%
[fid,errmsg] = fopen([name '.hdr'],'r');

if fid == -1
    fprintf (1,'Error opening file %s\n',[name '.hdr']);
    disp (errmsg)
    error
end

%
% read Xleft Ytop & then Xright Ybottom
%
s = fgetl(fid); [hk,count] =  sscanf(s, '%f %f %s %s',4);
xareaGeo(1)=hk(1);
yareaGeo(1)=hk(2);
s = fgetl(fid); [hk,count] =  sscanf(s, '%f %f %s %s',4);
xareaGeo(2)=hk(1);
yareaGeo(2)=hk(2);
s = fgetl(fid); [ldbfile,count] =  sscanf(s, '%s',1);

overviewpic = imread([pat name ext]);

Figopen = (findobj('tag','Figure2'));
if (isempty(Figopen))
    fig2 = figure('Tag','Figure2','Name', [name ext],'CloseRequestFcn','ddb_fig2Quit()');
end
try
    set(fig2,'Position',[1 1 550 700])
end

image(xareaGeo,yareaGeo,overviewpic)
set(gca,'YDir','normal')
set(gca,'XDir','normal')
axis image;
iarea = 1;

ddb_dnami_drawpolygon();
if (nseg > 0 & Mw > 0)
    figure(fig2);
    for i=1:nseg
        xx = [];
        yy = [];
        for k=1:5
            xx(k) = xvrt(i,k);
            yy(k) = yvrt(i,k);
        end
        fltpatch(i) = patch(xx,yy,'w');
    end
end
%
% Set all values
%


return
%imtool(overviewpic);

