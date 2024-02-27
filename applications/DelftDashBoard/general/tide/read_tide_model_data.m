function [lon,lat, gt, depth, conList] = readTideModel(tidefile, varargin)
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

%% Consituents
cnst=nc_varget(tidefile,'tidal_constituents');
try
    if findstr(constituent, 'all')
        constituent = cnst;
        ncons = length(constituent);
    else
        ncons = 1;
    end
catch
    ncons = 1;
end


%% Only one time readtidemodel
if ncons == 1
    
    %% TPXO 8.0
    if ~isempty(findstr(tidefile, 'tpxo80'))
        ind = find(strcmp('constituent', varargin));
        C = cellstr(constituent(1,:));
        str = ['Reading: TPXO 8.0 -', C, '- ', tp]; str = strjoin(str);
        disp(str);
        varargin{1, ind+1} = C{1,1};
        [lon, lat, gt, depth] = read_tide_model_TPXO8(tidefile,varargin);
        conList = C;
        
        %% Other
    else
        iddot = strfind(tidefile, '\');
        if isempty(iddot)
            iddot = strfind(tidefile, '/');
        end
        runname = tidefile((iddot(end)+1):end);
        str = ['Reading: ', runname, ' - ', tp];
        disp(str);
        [lon, lat, gt, depth, conList] = readTideModel_other(tidefile,varargin);
        
        % Filter other results
        ind = find(strcmp(constituent, conList));
        for jj = 1:length(gt);
            [nx ny ncons] = size(gt(jj).amp);
            if ncons > 1;
                gt(jj).amp = gt(jj).amp(:,:,ind);
                gt(jj).phi = gt(jj).phi(:,:,ind);
            else
                gt(jj).amp = gt(jj).amp(:,ind);
                gt(jj).phi = gt(jj).phi(:,ind);
            end
        end
    end
    
    %% All constituents
else
    
    %% TPXO 8.0
    if ~isempty(findstr(tidefile, 'tpxo80'))
%        for ii = 1:ncons
        for ii = 1:ncons
            % Replace constituent
            ind = find(strcmp('constituent', varargin));
            C = cellstr(constituent(ii,:));
            str = ['Reading: TPXO 8.0 -', C, '- ', tp]; str = strjoin(str);
            disp(str);
            varargin{1, ind+1} = C{1,1};
            
            % Determine
            [lon_TMP,lat_TMP, gt_TMP, depth] = readTideModel_TPXO8(tidefile,varargin);
            
            % Interpolate if needed
            for jj = 1:length(gt_TMP)
                values =  size(gt_TMP(jj).amp);
                if values(1) ==1
                    gt_TMP(jj).amp = gt_TMP(jj).amp';
                    gt_TMP(jj).phi = gt_TMP(jj).phi';
                end
                
                if ~strcmp(opt, 'interp') && ii ~= 1
                    [Xtmp, Ytmp] = meshgrid(lon_TMP, lat_TMP);
                    gt_TMP(jj).amp = interp2(lon_TMP, lat_TMP, gt_TMP(jj).amp, X, Y);
                    gt_TMP(jj).phi = interp2(lon_TMP, lat_TMP, gt_TMP(jj).phi, X, Y);
                end
                
                if ii == 1
                    gt(jj) = gt_TMP(jj);
                    lon = lon_TMP;
                    lat = lat_TMP;
                    [X, Y] = meshgrid(lon, lat);
                elseif strcmp(inptp, 'vector')
                    amp = gt_TMP(jj).amp;
                    phi = gt_TMP(jj).phi;
                    gt(jj).amp(:,ii) = amp;
                    gt(jj).phi(:,ii) = phi;
                else
                    amp = gt_TMP(jj).amp;
                    phi = gt_TMP(jj).phi;
                    gt(jj).amp(:,:,ii) = amp;
                    gt(jj).phi(:,:,ii) = phi;
                end
            end
        end
        
        % Get conlist
        for i=1:size(cnst,1)
            conList{i}=upper(deblank(cnst(i,:)));
        end
        
        
        %% TPXO 7.2, 6.0 or other
    else
        iddot = strfind(tidefile, '\');
        if isempty(iddot)
            iddot = strfind(tidefile, '/');
        end
        if isempty(iddot)
            iddot =0;
        end
        runname = tidefile((iddot(end)+1):end);
        str = ['Reading: ', runname, ' - ', tp];
        disp(str);
        [lon, lat, gt, depth, conList] = readTideModel_other(tidefile,varargin);
    end
    
end

%% Determine conlist
cl = constituent;
for i=1:size(cl,1)
    conList2{i}=upper(deblank(cl(i,:)));
end
