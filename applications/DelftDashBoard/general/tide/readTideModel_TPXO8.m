function [lon, lat, gt, depth, conList] = readTideModel_TPXO8(fname, varargin)
%READTIDEMODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = readTideModel(fname, variables)
%
%   Input:
%   fname     =
%   variables  =
%
%   Output:
%   varargout =
%
%   Example
%   readTideModel
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

% $Id: readTideModel.m 12110 2015-07-16 07:55:24Z ormondt $
% $Date: 2015-07-16 09:55:24 +0200 (Thu, 16 Jul 2015) $
% $Author: ormondt $
% $Revision: 12110 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/tide/readTideModel.m $
% $Keywords: $

%% Start
lon = [] ; lat = []; depth = []; conList = []; gt = [];
variables = varargin{1,1};
xp=[];
yp=[];
xl=[];
yl=[];
tp='h';
getd=0;
constituent='all';
incldep=0;

%% Variables
for i=1:length(variables)
    if ischar(variables{i})
        switch lower(variables{i})
            case{'x'}
                xp=variables{i+1};
                if size(xp,1)==1 || size(xp,2)==1
                    if size(xp,2)==1
                        xp=xp';
                    end
                    inptp='vector';
                else
                    inptp='matrix';
                end
                opt = 'interp';
            case{'y'}
                yp=variables{i+1};
                if size(yp,1)==1 || size(yp,2)==1
                    if size(yp,2)==1
                        yp=yp';
                    end
                    inptp='vector';
                else
                    inptp='matrix';
                end
                opt = 'interp';
            case{'xlim'}
                xl=variables{i+1};
                opt = 'limits';
            case{'ylim'}
                yl=variables{i+1};
                opt = 'limits';
            case{'type'}
                tp=variables{i+1};
            case{'constituent'}
                constituent=variables{i+1};
            case{'includedepth'}
                incldep=1;
                getd=1;
        end
    end
end

constituent = lower(constituent);

gt=[];
idpath = strfind(fname, 'tpxo80.nc');
fnamereduced = fname(1:idpath-1);

switch lower(tp)
    case{'h','z'}
        gt(1).ampstr='tidal_amplitude_h';
        gt(1).phistr='tidal_phase_h';
        fnameneeded = [fnamereduced, 'hf.', lower(constituent), '_tpxo8.nc'];
    case{'vel'}
        gt(1).ampstr='tidal_amplitude_u';
        gt(1).phistr='tidal_phase_u';
        gt(2).ampstr='tidal_amplitude_v';
        gt(2).phistr='tidal_phase_v';
        fnameneeded = [fnamereduced, 'uv.', lower(constituent), '_tpxo8.nc'];
    case{'q'}
        gt(1).ampstr='tidal_amplitude_U';
        gt(1).phistr='tidal_phase_U';
        gt(2).ampstr='tidal_amplitude_V';
        gt(2).phistr='tidal_phase_V';
        fnameneeded = [fnamereduced, 'uv.', lower(constituent), '_tpxo8.nc'];
    case{'u'}
        gt(1).ampstr='tidal_amplitude_u';
        gt(1).phistr='tidal_phase_u';
        fnameneeded = [fnamereduced, 'uv.', lower(constituent), '_tpxo8.nc'];
    case{'v'}
        gt(1).ampstr='tidal_amplitude_v';
        gt(1).phistr='tidal_phase_v';
        fnameneeded = [fnamereduced, 'uv.', lower(constituent), '_tpxo8.nc'];
    case{'all'}
        gt(1).ampstr='tidal_amplitude_h';
        gt(1).phistr='tidal_phase_h';
        gt(2).ampstr='tidal_amplitude_u';
        gt(2).phistr='tidal_phase_u';
        gt(3).ampstr='tidal_amplitude_v';
        gt(3).phistr='tidal_phase_v';
end

switch constituent
    case{'ms4','mn4','mf','mm'}
        fnamedepth = [fnamereduced, 'grid_tpxo8_atlas6.nc'];
    otherwise
        fnamedepth = [fnamereduced, 'grid_tpxo8atlas_30.nc'];
end

% Get limits
switch opt
    case{'interp'}
        xmin=min(min(xp));
        ymin=min(min(yp));
        xmax=max(max(xp));
        ymax=max(max(yp));
    case{'limits'}
        xmin=xl(1);
        ymin=yl(1);
        xmax=xl(2);
        ymax=yl(2);
end

% Get dimensions
idpath = strfind(fname, 'tpxo80.nc');
fnamereduced = fname(1:idpath-1);
xz=nc_varget([fnamereduced, 'hf.', constituent, '_tpxo8.nc'],'lon_z');
yz=nc_varget([fnamereduced, 'hf.', constituent, '_tpxo8.nc'],'lat_z');
xu=nc_varget([fnamereduced, 'uv.', constituent, '_tpxo8.nc'],'lon_u');
yu=nc_varget([fnamereduced, 'uv.', constituent, '_tpxo8.nc'],'lat_u');
xv=nc_varget([fnamereduced, 'uv.', constituent, '_tpxo8.nc'],'lon_v');
yv=nc_varget([fnamereduced, 'uv.', constituent, '_tpxo8.nc'],'lat_v');

% Consituents
cl=nc_varget(fname,'tidal_constituents');
for i=1:size(cl,1)
    cons{i}=upper(deblank(cl(i,:)));
end
nrcons=length(cons);
constituent=lower(constituent);
if strcmpi(constituent,'all')
    ic1=1;
    ic2=nrcons;
else
    ic1=strmatch(constituent,lower(cons),'exact');
    ic2=1;
end

for i=1:length(gt)      
    
    %% Get real and complex: TPXO 8.0 special
    switch gt(i).ampstr
        case{'tidal_amplitude_h'}
            real_name = 'hRe'; complex_name = 'hIm';correction_factor=0.001;
            dpname='hz';
            x=xz;
            y=yz;
        case{'tidal_amplitude_U'}
            real_name = 'uRe'; complex_name = 'uIm';correction_factor=1e-4;
            dpname='hu';
            x=xu;
            y=yu;
        case{'tidal_amplitude_V'}
            real_name = 'vRe'; complex_name = 'vIm';correction_factor=1e-4;
            dpname='hv';
            x=xv;
            y=yv;
        case{'tidal_amplitude_u'}
            real_name = 'uRe'; complex_name = 'uIm';correction_factor=1e-4;
            dpname='hu';
            x=xu;
            y=yu;
        case{'tidal_amplitude_v'}
            real_name = 'vRe'; complex_name = 'vIm';correction_factor=1e-4;
            dpname='hv';
            x=xv;
            y=yv;
    end

    % Y indices
    dy=(ymax-ymin)/10;
    dy=max(dy,0.5);
    iy1=find(yz<=ymin-dy,1,'last');
    if isempty(iy1)
        iy1=1;
    end
    iy2=find(y>=ymax+dy,1,'first');
    if isempty(iy2)
        iy2=length(y);
    end
    
    dx=(xmax-xmin)/10;
    dx=max(dx,0.5);
    dx=xz(2)-xz(1);
    iok=0;
    iglob=0;
    if xz(end)-xz(1)>330
        % Global dataset
        iglob=1;
    end
    loncor=0;
    
    
    if iglob
        
        % Assuming global dataset
        % First check situation
        if xmin>=x(1) && xmax<=x(end)
            % No problems
            iok=1;
            ix1=find(x<=xmin-dx,1,'last');
            ix2=find(x>=xmax+dx,1,'first');
        elseif xmin<x(1) && xmax<x(1)
            % Both to the left of the data
            % Check if moving the data 360 deg to the left helps
            xtmp=x-360;
%             xutmp=xu-360;
%             xvtmp=xv-360;
        elseif xmin>x(1) && xmax>x(1)
            % Both to the right of the data
            % Check if moving the data 360 deg to the right helps
            xtmp=x+360;
%             xutmp=xu+360;
%             xvtmp=xv+360;
        else
            % Possibly pasting necessary
            xtmp=x;
        end
        
        if ~iok
            % Check again
            if xmin>=xtmp(1) && xmax<=xtmp(end)
                % No problems now, keep new x value
                iok=1;
                x=xtmp;
%                 xu=xutmp;
%                 xv=xvtmp;
                ix1=find(x<=xmin-dx,1,'last');
                ix2=find(x>=xmax+dx,1,'first');
            end
        end
        
        if ~iok
            % Needs pasting
            
            % Left hand side
            if xmin<x(1)
                xtmp=x-360;
            else
                xtmp=x;
            end
            ix1left=find(xtmp<=xmin,1,'last');
            ix2left=length(x);
            
            lonleft=xtmp(ix1left:ix2left);
            
            % Right hand side
            if xmax>x(end)
                xtmp=x+360;
            else
                xtmp=x;
            end
            ix1right=1;
            ix2right=find(xtmp>=xmax,1,'first');
            
            lonright=xtmp(ix1right:ix2right);
            
        end
        
    else
        % Not a global dataset
        % First check situation
        iok=1;
        ix1=find(x<=xmin-dx,1,'last');
        ix2=find(x>=xmax+dx,1,'first');
        if ix1==length(x)
            ix1=[];
        end
        if ix2==1
            ix2=[];
        end
        if isempty(ix1) && isempty(ix2)
            % Possibly using WL iso EL
            if xmin<x(1) && xmax<x(end)
                ix1=find(x<=xmin-dx+360,1,'last');
                ix2=find(x>=xmax+dx+360,1,'first');
                loncor=-360;
            else
                ix1=find(x<=xmin-dx-360,1,'last');
                ix2=find(x>=xmax+dx-360,1,'first');
                loncor=360;
            end
        end
        % Using
        if isempty(ix1)
            ix1=1;
        end
        if isempty(ix2)
            ix2=length(x);
        end
    end
    
    %% If not OK: pasting needed
    if ~iok
        % pasting - left
        real    =  nc_varget(fnameneeded,real_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
        complex =  nc_varget(fnameneeded,complex_name,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
        ampleft(:,:)   = abs(real+1i*complex);
        val   = mod(180*atan2(real,complex)/pi,360) - 90;
        id = val < 270; val(id) = val(id)+360;
        id = val > 360; val(id) = val(id)-360;
        phileft(:,:)   = val;

        if getd
            dpleft   = nc_varget(fnamedepth,dpname,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
        end
        
        % pasting - right
        real    =  nc_varget(fnameneeded,real_name,[ix1right-1 iy1-1],[ix2right-ix1right+1 iy2-iy1+1]);
        complex =  nc_varget(fnameneeded,complex_name,[ix1right-1 iy1-1],[ix2right-ix1right+1 iy2-iy1+1]);
        ampright(:,:)   = abs(real+1i*complex);
        val   = mod(180*atan2(real,complex)/pi,360) - 90;
        id = val < 270; val(id) = val(id)+360;
        id = val > 360; val(id) = val(id)-360;
        phiright(:,:)   = val;
        if getd
            dpright  = nc_varget(fnamedepth,dpname,[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
        end
        
        % Now paste
        gt(i).amp   = permute([permute(ampleft,[2 1 3]) permute(ampright,[2 1 3])],[2 1 3]);
        gt(i).phi   = permute([permute(phileft,[2 1 3]) permute(phiright,[2 1 3])],[2 1 3]);
        if getd
            depth = [dpleft' dpright'];
        end
        
        % TODO This is still wrong!!! Make distinction between xu, xv and xz!
        lonz = [lonleft;lonright];
        lonu = [lonleft;lonright];
        lonv = [lonleft;lonright];
        latz = y(iy1:iy2);
        latu = yu(iy1:iy2);
        latv = yv(iy1:iy2);
        
    else
        
        %% No pasting needed
        % Get values
        real    =  nc_varget(fnameneeded,real_name,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
        complex =  nc_varget(fnameneeded,complex_name,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
        gt(i).amp   = abs(real+1i*complex);
        val   = mod(180*atan2(real,complex)/pi,360) - 90;
        id = val < 270; val(id) = val(id)+360;
        id = val > 360; val(id) = val(id)-360;
        gt(i).phi   = val;
        
        % Get depth
        if getd
            depth = nc_varget(fnamedepth,dpname,[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
        end
        
        % Fix grid
        lonz=x(ix1:ix2)+loncor;
        latz=y(iy1:iy2);
        lonu=xu(ix1:ix2)+loncor;
        latu=yu(iy1:iy2);
        lonv=xv(ix1:ix2)+loncor;
        latv=yv(iy1:iy2);
    end

    % For velocities, divide by depth
    switch gt(i).ampstr
        case{'tidal_amplitude_u','tidal_amplitude_v'}
            gt(i).amp=gt(i).amp./max(depth,0.1);
    end
    
    % Save in structure
    gt(i).amp = gt(i).amp*correction_factor;
    gt(i).amp=permute(gt(i).amp,[2 1]);
    gt(i).phi=permute(gt(i).phi,[2 1]);
    gt(i).phi(gt(i).amp==0)=NaN;
    gt(i).amp(gt(i).amp==0)=NaN;
    
    if getd
        depth = depth';
    end
    
end

% Finalize
switch opt
    case{'interp'}
        
        % X and Y coordinates
        xp(isnan(xp))=1e9;
        yp(isnan(yp))=1e9;
        
        % Loop over gt
        for i=1:length(gt)
            a=[];
            p=[];
            switch gt(i).ampstr
                case{'tidal_amplitude_h'}
                    lon=lonz;
                    lat=latz;
                case{'tidal_amplitude_u','tidal_amplitude_U'}
                    lon=lonu;
                    lat=latu;
                case{'tidal_amplitude_v','tidal_amplitude_V'}
                    lon=lonv;
                    lat=latv;
            end
            
            for k=1:size(gt(i).phi,3)
                
                % Amplitude
                if strcmpi(inptp,'matrix')
                    a(k,:,:)=interp2(lon,lat,internaldiffusion(squeeze(gt(i).amp(:,:,k))),xp,yp);
                else
                    a(k,:)=interp2(lon,lat,internaldiffusion(squeeze(gt(i).amp(:,:,k))),xp,yp);
                end
                
                % Phase (bit more difficult)
                sinp=sin(squeeze(gt(i).phi(:,:,k))*pi/180);
                cosp=cos(squeeze(gt(i).phi(:,:,k))*pi/180);
                sinp=internaldiffusion(sinp);
                cosp=internaldiffusion(cosp);
                sinpi=interp2(lon,lat,sinp,xp,yp);
                cospi=interp2(lon,lat,cosp,xp,yp);
                if strcmpi(inptp,'matrix')
                    p(k,:,:)=mod(180*atan2(sinpi,cospi)/pi,360);
                else
                    p(k,:)=mod(180*atan2(sinpi,cospi)/pi,360);
                end
            end
            
            % Put in structure
            gt(i).amp    = a;
            gt(i).phi    = p;
        end
        
        if getd
            depth=interp2(lon,lat,internaldiffusion(depth),xp,yp);
        end
        
    case{'limits'}
        switch gt(i).ampstr
            case{'tidal_amplitude_h'}
                lon=lonz;
                lat=latz;
            case{'tidal_amplitude_u','tidal_amplitude_U'}
                lon=lonu;
                lat=latu;
            case{'tidal_amplitude_v','tidal_amplitude_V'}
                lon=lonv;
                lat=latv;
        end
        
end
