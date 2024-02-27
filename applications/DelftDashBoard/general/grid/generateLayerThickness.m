function thick=generateLayerThickness(varargin)
%   GENERATELAYERTHICKNESS generates layer thickness (in percent of water depth) for sigma and Z layers
%
%   For sigma layers, the thickness can be computed:
%       1) gradually increasing from the bottom (specify thickbot in %)
%       2) gradually increasing from the surface (specify thicktop in %)
%       3) gradually increasing from the bottom and the surface (specify thickbot and thicktop in %)
%       4) equidistant
%
%   E.g. thick=generateLayers('type','sigma','kmax',20,'thicktop',2,'thickbot',3)
%
%   For Z layers, the thickness can be computed:
%       1) gradually increasing from the surface (specify thicktop in metres)
%       2) equidistant
%
%   For Z layers, zbot and ztop (both positive up) must both be specified
%
%   E.g.  thick=generateLayers('type','z','kmax',22,'thicktop',2,'zbot',-5000,'ztop',10);
%
%   The number of layers kmax and the layer type (sigma or z) must always be specified
%
%   Syntax:
%   thick = generateVerticalLayerDistribution(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 <COMPANY>
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
% Created: 11 Oct 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: generateLayerThickness.m 11468 2014-11-27 13:34:23Z ormondt $
% $Date: 2014-11-27 21:34:23 +0800 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11468 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/grid/generateLayerThickness.m $
% $Keywords: $

thtop=[];
thbot=[];
kmax=[];
zbot=[];
ztop=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'type'}
                switch lower(varargin{i+1})
                    case{'z'}
                        tp='z';
                    case{'sigma'}
                        tp='s';
                    otherwise
                        error('Unrecognized layer type. Use either Z or Sigma.')
                end
            case{'kmax'}
                kmax=varargin{i+1};
            case{'thicktop'}
                thtop=varargin{i+1};
            case{'thickbot'}
                thbot=varargin{i+1};
            case{'zbot'}
                zbot=varargin{i+1};
            case{'ztop'}
                ztop=varargin{i+1};
        end
    end
end

if isempty(kmax)
    error('Number of layers kmax not specified!');
end

if tp=='z'
    if isempty(ztop)
        error('ztop not specified!');
    end
    if isempty(zbot)
        error('zbot not specified!');
    end
end

if tp=='s'
    % Sigma layers
    if ~isempty(thtop) && isempty(thbot)
        % Refine at the top
        totalthick=100;
        thick=getlayers(kmax,totalthick,thtop);
    elseif isempty(thtop) && ~isempty(thbot)
        % Refine at the bottom
        totalthick=100;
        thick=getlayers(kmax,totalthick,thbot);
        thick=flipud(thick);
    elseif ~isempty(thtop) && ~isempty(thbot)
        % Refine at top and bottom
        dif0=1e9;
        totalthick1=50;
        totalthick2=50;
        % Iterate to find where layer thickness at mid depth is similar for profile from top and bottom 
        for k=2:kmax-1
            kmax1=k;
            kmax2=kmax-kmax1;
            thick1=getlayers(kmax1,totalthick1,thtop);
            thick2=getlayers(kmax2,totalthick2,thbot);
            dif1=abs(thick1(end)-thick2(end));
            if dif1>dif0
                kk=k-1;
                break
            end
            dif0=dif1;
        end
        % Best result found for k=kk
        kmax1=kk;
        kmax2=kmax-kk;
        thick1=getlayers(kmax1,totalthick1,thtop);
        thick2=getlayers(kmax2,totalthick2,thbot);
        thick2=flipud(thick2);
        thick=[thick1;thick2];
    else
        % Equidistant distribution
        thick=zeros(kmax,1)+100/kmax;
        thick=0.001*round(1000*thick);
        sumtot=sum(thick);
        dif=sumtot-100;
        thick(end)=thick(end)-dif;
    end    
else

    % Z layers
    zdif=ztop-zbot;
    
    if ~isempty(thtop)
        
        % First layers above surface
%        unifdpt=40;
        unifdpt=0;
        
        kmax1=round((ztop+unifdpt)/thtop);
        thabovesurf=100*(ztop+unifdpt)/kmax1/zdif;
        thick1(1:kmax1,1)=thabovesurf;
        
        % And now layers below surface
        totalthick2=-100*zbot/zdif;
        kmax2=kmax-kmax1;
        thick2=getlayers(kmax2,totalthick2,thabovesurf);
        thick=[thick1;thick2];
        
        % Make sure that sum of layers is 100
        thick=0.001*round(1000*thick);
        sumtot=sum(thick);
        dif=sumtot-100;
        thick(end)=thick(end)-dif;
        
        % Z layers so flip upside down
        thick=flipud(thick);
        
    else
        % Equidistant distribution        
        thick=zeros(kmax,1)+100/kmax;
        thick=0.001*round(1000*thick);
        sumtot=sum(thick);
        dif=sumtot-100;
        thick(end)=thick(end)-dif;
    end
    
end

function thick=getlayers(kmax,totalthick,thtop)
% Computes layer thickness
pw1=1.5;
sumtot=10000;
thick(1)=thtop;
n=0;
while abs(sumtot-totalthick)>0.0001
    n=n+1;
    for k=2:kmax
        thick(k)=thick(k-1)*pw1;
    end
    sumtot=sum(thick);
    pw1 = pw1*(totalthick/sumtot)^(1.0/kmax);
    if n>100
        error('Could not find solution!');
    end
end
thick=0.001*round(1000*thick);
sumtot=sum(thick);
dif=sumtot-totalthick;
thick(end)=thick(end)-dif;
thick=thick';
