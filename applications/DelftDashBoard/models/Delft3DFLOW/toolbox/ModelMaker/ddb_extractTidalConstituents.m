function [ampu phaseu depth conList] = ddb_extractTidalConstituents(fname, xx, yy, opt1, varargin)
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
% $Date: 2011-11-29 23:05:10 +0800 (Tue, 29 Nov 2011) $
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

ampu=[];
phaseu=[];
depth=[];

x=nc_varget(fname,'lon');
y=nc_varget(fname,'lat');
cl=nc_varget(fname,'tidal_constituents');

nrcons=size(cl,1);

for k=1:nrcons
    conList{k}=squeeze(upper(cl(k,:)));
end

if ~isempty(comp)
    icomp=strmatch(comp,conList,'exact');
end

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

%for k=1:nrcons
switch lower(opt1)
    case{'h','z'}
        ampstr='tidal_amplitude_h';
        phistr='tidal_phase_h';
    case{'u'}
        ampstr='tidal_amplitude_u';
        phistr='tidal_phase_u';
    case{'v'}
        ampstr='tidal_amplitude_v';
        phistr='tidal_phase_v';
end

xv=x(ix1:ix2);
yv=y(iy1:iy2);
[xg,yg]=meshgrid(xv,yv);

xx(isnan(xx))=1e9;
yy(isnan(yy))=1e9;

dpt=nc_varget(fname,'depth',[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
dpt=dpt';
% figure(999);
% pcolor(xg,yg,double(dpt));colorbar;
depth=interp2(xg,yg,dpt,xx,yy);

if isempty(comp)
    
    % Get all constituents
    amp=nc_varget(fname,ampstr,[ix1-1 iy1-1 0],[ix2-ix1+1 iy2-iy1+1 nrcons]);
    phi=nc_varget(fname,phistr,[ix1-1 iy1-1 0],[ix2-ix1+1 iy2-iy1+1 nrcons]);
    amp=double(amp);
    phi=double(phi);
    amp=permute(amp,[2 1 3]);
    phi=permute(phi,[2 1 3]);
    
    %     figure(800);
    %     pcolor(amp(:,:,1));colorbar;
    %     figure(900);
    %     pcolor(phi(:,:,1));colorbar;
    
    for k=1:nrcons
        
        a=squeeze(amp(:,:,k));
        p=squeeze(phi(:,:,k));
        p(a==0)=NaN;
        a(a==0)=NaN;
        a=internaldiffusion(a);
        p=internaldiffusion(p);
        
        ampu(k,:,:)=interp2(xg,yg,a,xx,yy);
        phaseu(k,:,:)=interp2(xg,yg,p,xx,yy);
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

