function varargout = vs_trih_station(trih,varargin)
%VS_TRIH_STATION   Read [x,y,m,n,name] information of history stations (obs point)
%
% ST = VS_TRIH_STATION(trih,<station_id>)
%
% where trih = VS_USE(...) and ST is a struct with fields:
%    - m
%    - n
%    - x
%    - y
%    - index
%    - name
%
% where station_id can be :
%    - the index(es) in the trih file
%    - station name(s) as a multidimensional characters array.
%      where stations are counted in the first dimension.
%    - a cell array of station name(s)
%    - absent or empty to load all stations
%
% Examples:
%
%   ST = VS_TRIH_STATION(trih);
%   ST = VS_TRIH_STATION(trih,{'coast05','coast06'});
%   ST = VS_TRIH_STATION(trih,['coast05';'coast06']);
%   ST = VS_TRIH_STATION(trih,[10 11]);
%
% [ST,iostat] = vs_trih_station(trih,station_id)
% returns iostat=1 when succesfull, and iostat=-1 when failed.
% When iostat is not asked for, and it fails, error is called.
% This happens when the station name is not present.
%
% See also: VS_USE, VS_LET, STATION, VS_TRIH_STATION_INDEX

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: vs_trih_station.m 9294 2013-09-30 09:15:19Z bartgrasmeijer.x $
% $Date: 2013-09-30 17:15:19 +0800 (Mon, 30 Sep 2013) $
% $Author: bartgrasmeijer.x $
% $Revision: 9294 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trih_station.m $
% 2009 sep 28: added implementation of WAQ hda files [Yann Friocourt]

iostat =  1;

%% Input

if nargin==1
    station_id = [];
else
    station_id = varargin{1};
end

%%
% option constxy added to work around bug (?) in Delft3D tag 1882 and 
% maybe others, mixing up xy from his-series; make OPT.constxy true if you 
% want to use the coordinates from the his-const group instead of the 
% his-series group
OPT.constxy = false;
if nargin > 2
    OPT = setproperty(OPT,varargin{2:end});
end
%%


%% Get names from indices or vv.

if strcmp(trih.SubType,'Delft3D-trih')
    OPT.GrpName    = 'his-const';
    OPT.ElmName    = 'NAMST';
    ST.Description = 'Delft3d-FLOW monitoring point (*.obs) time serie.';
elseif strcmp(trih.SubType,'Delft3D-waq-history')
    OPT.GrpName    = 'DELWAQ_PARAMS';
    OPT.ElmName    = 'LOCATION_NAMES';
    ST.Description = 'Delft3d-WAQ monitoring point (*.obs) time serie.';
else
    error(['File type not suported:',trih.SubType])
end

if iscell(station_id)
    station_id = char(station_id);
end

if ischar(station_id)
    
    ST.name  = station_id;
    ST.index = vs_trih_station_index(trih,station_id,'strcmp'); % Only one station with exact name match, with multiple stations this function fails.
    
elseif isempty(station_id) % BEFORE isnumeric because [] is also numeric!!!
    
    ST.index = 1:vs_get_elm_size(trih,OPT.ElmName); % get all stations
    ST.name  = permute(vs_let(trih,OPT.GrpName,OPT.ElmName,{ST.index},'quiet'),[2 3 1]);
    
elseif isnumeric(station_id)
    
    ST.index = station_id;
    ST.name  = permute(vs_let(trih,OPT.GrpName,OPT.ElmName,{ST.index},'quiet'),[2 3 1]);
    
end

if ~(length(ST.index)==size(ST.name,1))
    disp (addrowcol(station_id,0,[-1 1],''''))
    disp(['Not all of above stations have match in : ',trih.FileName]);
    iostat = -1;
end

%% Get data

if iostat==1
    
    if (~(size(ST.index,1)==0) && strcmp(trih.SubType,'Delft3D-trih'))
        
        [mnstat,OK]   = vs_let(trih,'his-series',{1},'MNSTAT');
        if OK && ~OPT.constxy % new files
            mnstat       = permute(mnstat,[2 3 1]); % (x,y) positions of observation stations
            xystat       = permute(vs_let(trih,'his-series',{1},'XYSTAT'),[2 3 1]); % (x,y) positions of observation stations
            ST.m         = mnstat(1,:)';
            ST.n         = mnstat(2,:)';
            ST.x         = xystat(1,:)';
            ST.y         = xystat(2,:)';
        else % old files
            ST.m         = squeeze(vs_let(trih,OPT.GrpName,'MNSTAT',{1,ST.index},'quiet'));
            ST.n         = squeeze(vs_let(trih,OPT.GrpName,'MNSTAT',{2,ST.index},'quiet'));
            ST.x         = squeeze(vs_let(trih,OPT.GrpName,'XYSTAT',{1,ST.index},'quiet'));
            ST.y         = squeeze(vs_let(trih,OPT.GrpName,'XYSTAT',{2,ST.index},'quiet'));
        end
        
        
        %ST.grdang    = squeeze(vs_let(trih,OPT.GrpName,'GRDANG',{1,ST.index}));
        ST.angle     = squeeze(vs_let(trih,OPT.GrpName,'ALFAS' ,{  ST.index},'quiet'))';
        ST.angle_explanation =  vs_get_elm_def(trih,'ALFAS','Description','quiet');
        ST.kmax        =  squeeze(vs_let(trih,OPT.GrpName,'KMAX','quiet'));
        ST.coordinates =  vs_let(trih,'his-const','COORDINATES'      ,'quiet');
        ST.layer_model =  vs_let(trih,'his-const','LAYER_MODEL'      ,'quiet');
        ST.coordinates =  strtrim(permute(ST.coordinates,[1 3 2]));
        ST.layer_model =  strtrim(permute(ST.layer_model,[1 3 2]));
        
    else
        
        ST.m      = [];
        ST.n      = [];
        
        ST.x      = [];
        ST.y      = [];
        
        ST.angle  = [];
        
    end
    
    ST.FileName        = trih.FileName;
    ST.extracted_at    = datestr(now,31);
    ST.extracted_with  = '$Id: vs_trih_station.m 9294 2013-09-30 09:15:19Z bartgrasmeijer.x $ $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trih_station.m $';
    
end

%% Output

if     nargout==1
    if iostat==1
        varargout = {ST};
    else
        error(' ');
        varargout = {iostat};
    end
elseif nargout==2
    varargout = {ST,iostat};
end

%% EOF
