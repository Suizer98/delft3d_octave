function [gt, constituents] = read_tide_model(tidefile, varargin)
%READTIDEMODEL  Wrapper for TPXO 8.0 and older
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = readTideModel(fname, varargin)
%
%   Input:
%   fname     =
%   varargin  =
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

% $Id: readTideModel.m 16770 2020-11-05 13:43:35Z bj.vanderspek.x $
% $Date: 2020-11-05 14:43:35 +0100 (do, 05 nov 2020) $
% $Author: bj.vanderspek.x $
% $Revision: 16770 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/tide/readTideModel.m $
% $Keywords: $

%% Create output
lon = [] ; lat = []; depth = []; conList = [];
ampz = []; phasez = [];
ampu = []; phaseu = []; ampv = []; phasev = [];
inptp = [];

%% How many
constituent='all';
incldep=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'x'}
                xp=varargin{i+1};
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
                yp=varargin{i+1};
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
                xl=varargin{i+1};
                opt = 'limits';
            case{'ylim'}
                yl=varargin{i+1};
                opt = 'limits';
            case{'type'}
                tp=varargin{i+1};
            case{'constituent'}
                constituent=varargin{i+1};
            case{'includedepth'}
                incldep=1;
                getd=1;
        end
    end
end

if strcmpi(opt,'interp')
    xl(1)=min(min(xp));
    xl(2)=max(max(xp));
    yl(1)=min(min(yp));
    yl(2)=max(max(yp));
end

%% Available constituents
if ~isempty(findstr(tidefile, 'tpxo80'))
    constituents={'M2','S2','N2','K2','K1','O1','P1','Q1','MF','MM','M4','MS4','MN4'};
else
    cnst=nc_varget(tidefile,'tidal_constituents');
    cnst=upper(cnst);
    for ic=1:size(cnst,1)
        constituents{ic}=deblank(cnst(ic,:));
    end    
end

%% Requested constituents
if strcmpi(constituent,'all')
    ncons = length(constituents);
    const=constituents;
else
    ncons = 1;
    const{1}=lower(constituent);
end

if ~isempty(findstr(tidefile, 'tpxo80'))
    tidesource='tpxo80';
else
    tidesource='other';
end
    
for icons=1:ncons
    
    cns=const{icons};
    
    disp(['Fetching component ' upper(cns) ' - ' tp  ' from ' tidefile]);
    
    switch tidesource
        
        case{'tpxo80'}
            [lon, lat, amp, phi] = read_tide_model_TPXO80(tidefile,xl,yl,cns,tp);
        otherwise
            [lon, lat, amp, phi] = read_tide_model_other(tidefile,xl,yl,cns,tp);

    end
    
    data(icons).name=cns;
    data(icons).lon=lon;
    data(icons).lat=lat;
    data(icons).amp=amp;
    data(icons).phi=phi;
    data(icons).amp(data(icons).amp==0)=NaN;
    data(icons).phi(isnan(data(icons).amp))=NaN;
    
end

% Finalize
switch opt
    
    case{'interp'}
        
        if strcmpi(inptp,'matrix')
            gt.amp=zeros(ncons,size(xp,1),size(xp,2));
        else
            gt.amp=zeros(ncons,length(xp));
        end
        gt.phi=gt.amp;
        
        % X and Y coordinates
        xp(isnan(xp))=1e9;
        yp(isnan(yp))=1e9;
        
        for icons=1:ncons
            
            % Get required data from tide file
                        
            
            lon=data(icons).lon;
            lat=data(icons).lat;
            
            % Amplitude
            if strcmpi(inptp,'matrix')
                gt.amp(icons,:,:)=interp2(lon,lat,internaldiffusion(squeeze(data(icons).amp)),xp,yp);
            else
                gt.amp(icons,:)=interp2(lon,lat,internaldiffusion(squeeze(data(icons).amp)),xp,yp);
            end
            
            % Phase (bit more difficult)
            sinp=sin(squeeze(data(icons).phi)*pi/180);
            cosp=cos(squeeze(data(icons).phi)*pi/180);
            sinp=internaldiffusion(sinp);
            cosp=internaldiffusion(cosp);
            sinpi=interp2(lon,lat,sinp,xp,yp);
            cospi=interp2(lon,lat,cosp,xp,yp);
            if strcmpi(inptp,'matrix')
                gt.phi(icons,:,:)=mod(180*atan2(sinpi,cospi)/pi,360);
            else
                gt.phi(icons,:)=mod(180*atan2(sinpi,cospi)/pi,360);
            end
        end
        
    case{'limits'}
        
        gt=data;
        
end