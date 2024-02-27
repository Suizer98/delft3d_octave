function s=write_meteo_file(meteodir, meteoname, parameter, rundir, fname, xlim, ylim, tstart, tstop, varargin)
%write_meteo_file  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   write_meteo_file(meteodir, meteoname, rundir, fname, xlim, ylim, reftime, tstart, tstop, varargin)
%
%   Input:
%   meteodir     =
%   meteoname    =
%   rundir       =
%   fname        =
%   xlim         =
%   ylim         =
%   coordsys     =
%   coordsystype =
%   reftime      =
%   tstart       =
%   tstop        =
%   varargin     =
%
%
%
%
%   Example
%   writeD3DMeteoFile4
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

% $Id: writeD3DMeteoFile4.m 9262 2013-09-24 11:23:25Z ormondt $
% $Date: 2013-09-24 13:23:25 +0200 (Tue, 24 Sep 2013) $
% $Author: ormondt $
% $Revision: 9262 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/writeD3DMeteoFile4.m $
% $Keywords: $

%% Parameters can be any cell array with strings u, v, p, airtemp, relhum
%% and cloud cover.

vsn='1.03';
model='delft3d';
spwfile=[];

dx=[];
dy=[];
dx=50000;
dy=50000;
dt=[];
spwmergefrac=0.5;
cs.name='WGS 84';
cs.type='geographic';
interpolationmethod='none';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
            case{'version'}
                vsn=varargin{i+1};
            case{'model'}
                model=varargin{i+1};
            case{'spwfile'}
                spwfile=varargin{i+1};
            case{'dt'}
                dt=varargin{i+1}; % in minutes
            case{'cs'}
                cs=varargin{i+1};
            case{'reftime'}
                reftime=varargin{i+1};
            case{'interpolationmethod'}
                interpolationmethod=varargin{i+1};
        end
    end
end

% If only dx or dy is given
if isempty(dx) && ~isempty(dy)
    dx=dy;
end
if ~isempty(dx) && isempty(dy)
    dy=dx;
end

% Convert strings a cell arrays
if ~iscell(parameter)
    parameter=cellstr(parameter);
end
if ~isempty(meteodir)
    if ~iscell(meteodir)
        meteodir=cellstr(meteodir);
        meteoname=cellstr(meteoname);
    end
end
nmeteo=length(meteodir);

% Add file separators to run dir
if isempty(rundir)
    rundir=['.' filesep];
end
if ~strcmpi(rundir(end),filesep)
    rundir=[rundir filesep];
end

npar=length(parameter);

% Make rectangular grid (only for projected coordinate systems)
xlimg=xlim;
ylimg=ylim;
% Determine xlim and ylim in case of projected coordinate systems
if ~strcmpi(cs.type,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=convertCoordinates(xg,yg,'persistent','CS1.name',cs.name,'CS1.type',cs.type,'CS2.name','WGS 84','CS2.type','geographic');
    xlimg(1)=min(min(xgeo));
    xlimg(2)=max(max(xgeo));
    ylimg(1)=min(min(ygeo));
    ylimg(2)=max(max(ygeo));
    unit='m';
else
    [xgeo,ygeo]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    unit='degree';
end

%% First get data for each parameter (in WGS 84) and store in structure s0

spw=[];

% First spiderweb info
if ~isempty(spwfile)
    
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [t,u,v,p,spwfrac]=spw2regulargrid(spwfile,xg,yg,dt,'mergefrac',spwmergefrac,'backgroundpressure',101500);
    
    it0=find(t<=tstart,1,'last');
    it1=find(t>=tstop,1,'first');
    if isempty(it0)
        it0=1;
    end
    if isempty(it1)
        it1=length(t);
    end
    t=t(it0:it1);
    u=u(it0:it1,:,:);
    v=v(it0:it1,:,:);
    p=p(it0:it1,:,:);
    spwfrac=spwfrac(it0:it1,:,:);
    
    u(isnan(u))=0;
    v(isnan(v))=0;

    spw.type='fromspiderweb';
    
    spw.parameter(1).name='u';
    spw.parameter(1).time=t;
    spw.parameter(1).x=xlim(1):dx:xlim(2);
    spw.parameter(1).y=ylim(1):dy:ylim(2);
    spw.parameter(1).val=u;

    spw.parameter(2).name='v';
    spw.parameter(2).time=t;
    spw.parameter(2).x=xlim(1):dx:xlim(2);
    spw.parameter(2).y=ylim(1):dy:ylim(2);
    spw.parameter(2).val=v;

    spw.parameter(3).name='p';
    spw.parameter(3).time=t;
    spw.parameter(3).x=xlim(1):dx:xlim(2);
    spw.parameter(3).y=ylim(1):dy:ylim(2);
    spw.parameter(3).val=p;
    
end

% Now regular datasets (interpolation to local system and merging may
% happen in next step)

nm=0;

% Loop through datasets
for imeteo=1:nmeteo
    
    nm=nm+1;

    s0(nm).type='fromregulargrid';

    % Add file separators to run dir
    if ~strcmpi(meteodir{imeteo}(end),filesep)
        meteodir{imeteo}=[meteodir{imeteo} filesep];
    end
    
    % Loop through parameters
    
    for ipar=1:npar
        
        s0(nm).parameter(ipar).name=parameter{ipar};
        s0(nm).parameter(ipar).time=[];
        s0(nm).parameter(ipar).x=[];
        s0(nm).parameter(ipar).y=[];
        s0(nm).parameter(ipar).val=[];
        
        % Find available times
        
        flist=dir([meteodir{imeteo} meteoname{imeteo} '.' parameter{ipar} '.*.mat']);
        t=[];
        for i=1:length(flist)
            tstr=flist(i).name(end-17:end-4);
            for j=1:10
                try
                    t(i)=datenum(tstr,'yyyymmddHHMMSS');
                    break
                catch
                    pause(0.001);
                end
            end
        end
        
        if isempty(t)
            error(['No data found in ' meteoname '!']);
        end
        
        it0=find(t>tstart-0.001&t<tstart+0.001,1,'first');
        it1=find(t>tstop-0.001&t<tstop+0.001,1,'first');
        
        if isempty(it0)
            it0=1;
%            error(['First time ' datestr(tstart) ' not found in ' meteoname{imeteo} '!']);
        end
        
        if isempty(it1)
            it1=length(t);
%            error(['Last time ' datestr(tstop) ' not found in ' meteoname{imeteo} '!']);
        end
            
        nt=it1-it0+1;
        
        for it=1:nt
            
            n=it+it0-1;
                       
            s=load([meteodir{imeteo} flist(n).name]);
            
            [val,lon,lat]=getMeteoMatrix(s.(parameter{ipar}),s.lon,s.lat,xlimg,ylimg);
            val=internaldiffusion(val);
            
            if it==1
                % Allocate arrays
                s0(nm).parameter(ipar).time=zeros(1,nt);
                s0(nm).parameter(ipar).x=lon;
                s0(nm).parameter(ipar).y=lat;
                s0(nm).parameter(ipar).val=zeros(nt,length(lat),length(lon));
            end
            
            s0(nm).parameter(ipar).time(it)=t(n);
            s0(nm).parameter(ipar).val(it,:,:)=val;
            
        end
        
    end
end

%% Now merge the data on regular grids (only if there are more dataset on a regular grid)

% First determine at which times the data should be available
[xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));

for ipar=1:npar

    t=[];
    if ~isempty(spw)
        t=spw.parameter(ipar).time;
    end
        
    % First determine the total number of times
    for imeteo=1:nmeteo
        if isempty(t)
            t=s0(imeteo).parameter(ipar).time;
        else
            % Find last time smaller than first available time
            it1=find(s0(imeteo).parameter(ipar).time<t(1),1,'last');
            t=[s0(imeteo).parameter(ipar).time(1:it1) t];
            % Find first time larger than last available time
            it1=find(s0(imeteo).parameter(ipar).time>t(end),1,'first');
            t=[t s0(imeteo).parameter(ipar).time(it1:end)];
        end
    end
    
    % Create final structure s
    s.parameter(ipar).name=parameter{ipar};
    s.parameter(ipar).time=t;
    nt=length(t);
    % Set x and y coordinates
    s.parameter(ipar).x=xlim(1):dx:xlim(2);
    s.parameter(ipar).y=ylim(1):dy:ylim(2);
    nx=length(s.parameter(ipar).x);
    ny=length(s.parameter(ipar).y);
    % Allocate array
    s.parameter(ipar).val=zeros(nt,ny,nx);
    s.parameter(ipar).val(s.parameter(ipar).val==0)=NaN;
end
    
if nmeteo>1 || ~isempty(spw)
        
    for ipar=1:npar
        
        % Now interpolate
        for imeteo=1:length(meteodir)
            % Create grid for this meteo dataset
            [xg0,yg0]=meshgrid(s0(imeteo).parameter(ipar).x,s0(imeteo).parameter(ipar).y);
            % Loop through time
            for it=1:nt
                
                val=squeeze(s.parameter(ipar).val(it,:,:));
                
                % Find time in this meteo dataset
                tm=s.parameter(ipar).time(it);

                [it1,it2,tfrac1,tfrac2]=find_time_indices_and_factors(s0(imeteo).parameter(ipar).time,tm);

                if it1>0
                    if it2==0
                        % Exact time found
                        val0=squeeze(s0(imeteo).parameter(ipar).val(it1,:,:));
                    else
                        val0a=squeeze(s0(imeteo).parameter(ipar).val(it1,:,:));
                        val0b=squeeze(s0(imeteo).parameter(ipar).val(it2,:,:));
                        val0=tfrac1*val0a+tfrac2*val0b;
                    end
                    
                    % Interpolate this meteo dataset onto new grid
%                     val1=interp2(xg0,yg0,val0,xg,yg);
                    val1=interp2(xg0,yg0,val0,xgeo,ygeo);
                    % Only use data
                    val(isnan(val))=val1(isnan(val));
                    s.parameter(ipar).val(it,:,:)=val;
                end
            end
        end
        
    end
else
    s=s0;
end

% And now add the spiderweb data
if ~isempty(spw)
    if nmeteo>0
        for ipar=1:npar
            iparspw=0;
            switch s.parameter(ipar).name
                case{'u'}
                    iparspw=1;
                case{'v'}
                    iparspw=2;
                case{'p'}
                    iparspw=3;
            end
            if iparspw>0
                for it=1:length(spw.parameter(iparspw).time)
                    it1=find(s.parameter(ipar).time==spw.parameter(iparspw).time(it));
                    val1=squeeze(spw.parameter(iparspw).val(it,:,:));
                    val1(isnan(val1))=0;
                    val2=squeeze(s.parameter(ipar).val(it1,:,:));
                    frac=squeeze(spwfrac(it,:,:));
                    val=frac.*val1+(1-frac).*val2;
                    s.parameter(ipar).val(it1,:,:)=val;
                end
            end
        end
    else
        s=spw;
    end
end

% Is this still necessary?
% %% Now interpolate onto grid in local coordinate system
% if ~strcmpi(cs.type,'geographic')
% %     s.parameter(ipar).x=xlim(1):dx:xlim(2);
% %     s.parameter(ipar).y=ylim(1):dy:ylim(2);
%     % Convert grid to geographic coordinate system
%     [xg1,yg1]=convertCoordinates(xg,yg,'CS1.name',cs.name,'CS1.type',cs.type,'CS2.name','WGS 84','CS2.type','geographic');
%     for ipar=1:npar
%         x1=s.parameter(ipar).x;
%         y1=s.parameter(ipar).y;
%         val1=s.parameter(ipar).val; % Data on original grid
%         nt=length(s.parameter(ipar).time);
%         s.parameter(ipar).x=xlim(1):dx:xlim(2);
%         s.parameter(ipar).y=ylim(1):dy:ylim(2);
%         s.parameter(ipar).val=zeros(nt,size(xg,1),size(xg,2));
%         for it=1:nt
%             val=squeeze(val1(it,:,:));
%             s.parameter(ipar).val(it,:,:)=interp2(x1,y1,val,xg1,yg1);
%         end
%     end
% end

%% Apply spline
switch lower(interpolationmethod)
    case{'none'}
    case{'linear'}
        if isempty(dt)
            error('Please specify interpolation time step!');
        end
        tt=s.parameter(ipar).time(1):dt/1440:s.parameter(ipar).time(end);
        for ipar=1:npar
            val=s.parameter(ipar).val;
            val=interp1(s.parameter(ipar).time,val,tt);
            s.parameter(ipar).val=val;
            s.parameter(ipar).time=tt;        
        end
    case{'spline'}
        if isempty(dt)
            error('Please specify interpolation time step!');
        end
        tt=s.parameter(ipar).time(1):dt/1440:s.parameter(ipar).time(end);
        for ipar=1:npar
            val=s.parameter(ipar).val;
            val=permute(val,[2 3 1]);
            val=spline(s.parameter(ipar).time,val,tt);
            val=permute(val,[3 1 2]);
            s.parameter(ipar).val=val;
            s.parameter(ipar).time=tt;
        end
end

%% And write the data to model input files
switch lower(model)

    case{'delft3d'}
        for ipar=1:npar
            write_meteo_file_delft3d([rundir fname],s,parameter{ipar},unit,reftime,'version',vsn);
        end
        
    case{'netcdf'}
        write_meteo_file_netcdf([rundir fname],s,unit,reftime);
        
    case{'ww3'}
        % Combined u and v
        ww3_write_wnd([rundir fname],s);
        ww3_write_prep_inp([rundir 'ww3_prep.inp'],s.parameter(1).x,s.parameter(1).y,'WND');

    case{'mat'}

        n=0;

        for ipar=1:npar
            switch parameter{ipar}
                case{'u'}
                    n=n+1;                    
                    % Find index of v
                    ivpar=strmatch('v',parameter,'exact');                    
                    st.parameters(n).parameter.name='wind';
                    st.parameters(n).parameter.time=s.parameter(ipar).time;
                    st.parameters(n).parameter.x=s.parameter(ipar).x;
                    st.parameters(n).parameter.y=s.parameter(ipar).y;
                    st.parameters(n).parameter.u=s.parameter(ipar).val;
                    st.parameters(n).parameter.v=s.parameter(ivpar).val;
                    st.parameters(n).parameter.quantity='vector';
                    st.parameters(n).parameter.size=[length(s.parameter(ipar).time) 0 length(s.parameter(ipar).y) length(s.parameter(ipar).x) 0];
                    
                case{'v'}
                otherwise
                    n=n+1;
                    st.parameters(n).parameter.name=parameter{ipar};
                    st.parameters(n).parameter.time=s.parameter(ipar).time;
                    st.parameters(n).parameter.x=s.parameter(ipar).x;
                    st.parameters(n).parameter.y=s.parameter(ipar).y;
                    st.parameters(n).parameter.val=s.parameter(ipar).val;
                    st.parameters(n).parameter.quantity='scalar';
                    st.parameters(n).parameter.size=[length(s.parameter(ipar).time) 0 length(s.parameter(ipar).y) length(s.parameter(ipar).x) 0];
            end
        end        

        save([rundir fname],'-struct','st');

end
