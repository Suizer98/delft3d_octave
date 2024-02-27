function [ampu phaseu conList] = ddb_extractTidalConstituents_FES(fname, xx, yy, opt1, varargin)
%DDB_EXTRACTTIDALCONSTITUENTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [ampu phaseu depth conList] = ddb_extractTidalConstituents(fname, xx, yy, opt1, varargin)
%
%   Input:
%   fname    =
%   xx       =
%   yy       =
%   opt1     =
%   varargin =
%
%   Output:
%   ampu     =
%   phaseu   =
%   depth    =
%   conList  =
%
%   Example
%   ddb_extractTidalConstituents
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_extractTidalConstituents.m 5540 2011-11-29 15:05:10Z boer_we $
% $Date: 2011-11-29 07:05:10 -0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5540 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/toolbox/ModelMaker/ddb_extractTidalConstituents.m $
% $Keywords: $

%%
if ~isempty(varargin)
    comp=varargin{1};
else
    comp=[];
end
ampu    = [];
phaseu  = [];

% Get mesh
input_dir   = fname; cd(input_dir);
fname       = 'm2.nc';
x           = nc_varget(fname,'lon');
y           = nc_varget(fname,'lat');

% Find wanted components
listing = dir;
conList = {'2n2';'eps2';'j1';'k1';'k2';'l2';'la2';'m2';'m3';'m4';'m6';'m8';'mf';'mks2';'mm';'mn4';'ms4';'msf';'msqm';'mtm';'mu2';'n2';'n4';'nu2';'o1';'p1';'q1';'r2';'s1';'s2';'s4';'sa';'ssa';'t2'};
if ~isempty(comp)
    icomp=strmatch(comp,conList,'exact');
end

% Find desired space
xmin=min(min(xx));
ymin=min(min(yy));
xmax=max(max(xx));
ymax=max(max(yy));

ix1=find(x<=xmin,1,'last')-1;
if isempty(ix1)
    ix1=1;
end
ix1=max(ix1,1);

ix2=find(x>=xmax,1)+1;
if isempty(ix2)
    ix2=length(x);
end
ix2=min(ix2,length(x));

iy1=find(y<=ymin,1,'last')-1;
if isempty(iy1)
    iy1=1;
end
iy1=max(iy1,1);

iy2=find(y>=ymax,1)+1;
if isempty(iy2)
    iy2=length(y);
end
iy2=min(iy2,length(y));

switch lower(opt1)
    case{'h','z'}
        ampstr='amplitude';
        phistr='phase';
end

% Coordinates ready
xv=x(ix1:ix2);
yv=y(iy1:iy2);
[xg,yg]=meshgrid(xv,yv);
xx(isnan(xx))=1e9;
yy(isnan(yy))=1e9;


if isempty(comp)
    
    % Get all constituents
    for k = 1:length(conList)
        
        % Get matrix
        cd(input_dir)
        fname   = [conList{k}, '.nc'];
        amp     = nc_varget(fname,ampstr,[iy1-1 ix1-1],[iy2-iy1+1 ix2-ix1+1]);
        phi     = nc_varget(fname,phistr,[iy1-1 ix1-1],[iy2-iy1+1 ix2-ix1+1]);
        xgr     = nc_varget(fname,'lon', [ix1-1],[ix2-ix1+1]);
        ygr     = nc_varget(fname,'lat', [iy1-1],[iy2-iy1+1]);
        [xgr,ygr]=meshgrid(xgr,ygr);
        
        % Make amp and phi ready
        amp         = double(amp);
        amp         = double(amp)/100;          % was in cm
        rad         = deg2rad(phi);
        idflip      = rad < 0;
        rad(idflip) = rad(idflip) + 2*pi;  
        phi         = double(rad2deg(rad));
        
        % Interpolate
        ampu(k,:)     = interp2(xgr,ygr,amp,xx,yy);
        phaseu(k,:)   = interp2(xgr,ygr,phi,xx,yy);
    end

    
else
    
    % Get one constituents
    amp=nc_varget(fname,ampstr,[ix1-1 iy1-1 icomp-1],[ix2-ix1+1 iy2-iy1+1 1]);
    phi=nc_varget(fname,phistr,[ix1-1 iy1-1 icomp-1],[ix2-ix1+1 iy2-iy1+1 1]);
    amp=double(amp);
    phi=double(phi);
    amp=permute(amp,[2 1 3]);
    phi=permute(phi,[2 1 3]);
    
    a=squeeze(amp(:,:,1));
    p=squeeze(phi(:,:,1));
    p(a==0)=NaN;
    a(a==0)=NaN;
    a=internaldiffusion(a);
    p=internaldiffusion(p);
    
    ampu(:,:)=interp2(xg,yg,squeeze(amp(:,:)),xx,yy);
    phaseu(:,:)=interp2(xg,yg,squeeze(phi(:,:)),xx,yy);
    
end

ampu=squeeze(ampu);
phaseu=squeeze(phaseu);

