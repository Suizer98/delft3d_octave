function [ lgrid,x,y,values ] = matroos_get_maps(unit,source,xmin,xmax,ymin,ymax,coordsys,currentTime);
%MATROOS_GET_MAPS   TEST version
%
%   [ x,y,values ] = get_maps(unit,source,xmin,xmax,ymin,ymax,coordsys,currentTime);
%
% Example. waterlevel for entire dcsm domain
%
% [x,y,wl]=get_maps('sep','csm8',-12.0,13.0,48.0.62.0,'wgs84','200802190000');
%
% See also: matroos

serverurl = matroos_server;

%% available units, sources and locations 
%  !!!! at 20080219 may change in the future, TODO read this data from the
%  server

sources =    {'csm8','zuno','kustfijn','zeedelta','ymo','waddenzee_atlas_oost', ...
            'knmi_dcsm_maps', 'knmi_hirlam_maps', 'knmi_ukmo_maps'};

%- unit    : A unit as known by Matroos.
%            Examples: SEP (=waterlevel), VELU (=water velocity in x-direction),
%            VELV (=water velocity in y-direction), RP (=salt), 
%            VELUV_abs (=absolute waterspeed).
%            For knmi_hirlam_maps: p, wind_u, wind_v and wind_uv_abs.
%            For knmi_ukmo_maps  : p_msl, u_sfc, v_sfc and uv_sfc_abs.
%
%coordsyss : The coordinate system in which x and y are given.
%            Default: the same coordinate system as the model specified by 'source'.
%            Examples: RD (='Rijksdriehoek'), ED50, MN (=m,n co-ordinates).
%            or any epsg-code as epsg:<code>

%
%check input
%
isource = strmatch(source,sources);
if(length(isource)==0), error('could not find source');end;
source=strrep(source,' ','%20'); % %20=<space>

fprintf('unit=%s\n',unit);
fprintf('source=%s\n',source);
fprintf('location=( x %f-%f, y %f-%f)\n',xmin,xmax,ymin,ymax);
fprintf('coordinate system =%s\n',coordsys);
fprintf('first time=%s\n',currentTime);

%% get data from matroos

urlChar = sprintf('%sunit=m,n,%s&source=%s&xmin=%f&xmax=%f&ymin=%f&ymax=%f&coordsys=%s&tstart=%s&tstop=%s', ...
    serverurl,unit,source,xmin,xmax,ymin,ymax,coordsys,currentTime,currentTime);
disp(urlChar);
%eg
%http://matroos.deltares.nl/direct/get_subgrid_ascii.php?source=csm8&unit=m,n,SEP&tstart=200802180000&tstop=200802180000&xmin=-12&xmax=13&ymin=48&ymax=62&coordsys=wgs84
allLines = geturl(urlChar);

%% parse 

%skip header
i=0;done=0;
while((done==0)&(i<length(allLines))),
    i=i+1;
    done=(length(findstr(allLines{i},'#'))==0);
end;

%read allLines
done=0;
m(1) = 1;
n(1) = 1;
x(1) = NaN;
y(1) = NaN;
values(1) = NaN;
pointIndex=2;
while(i<length(allLines)),
    line = allLines{i};
    data = sscanf(line,'%f');
    x(pointIndex) = data(1);
    y(pointIndex) = data(2);
    m(pointIndex) = data(3);
    n(pointIndex) = data(4);
    values(pointIndex) = data(5);
    i=i+1;
    pointIndex=pointIndex+1;
end;

% build matrices from vectors
mmax=max(m);
mmin=min(m);
nmax=max(n);
nmin=min(n);
m = m - mmin + 1;
n = n - nmin + 1;
lgrid = ones(mmax-mmin+1,nmax-nmin+1);
for i=2:length(m),
    lgrid(m(i),n(i)) = i;
end;
values(values>900) = NaN;

%% EOF

%% 2010 feb 16
http://matroos.deltares.nl:80//matroos/scripts/matroos.pl?
source=csm8&
anal=000000000000&
z=0&
xmin=-12.000000&
xmax=13.000000&
ymin=47.999180&
ymax=62.332320&
coords=WGS84&
xmin_abs=&
xmax_abs=13.0&
ymin_abs=47.99918&
ymax_abs=62.33232&
color=H,SEP,VELU,VELUV_abs,VELV,XDEP,YDEP&

interpolate=count&
,

interpolate=size&
celly=&
cellx=&


now=201002160000&
to=200809070330&
from=200809070330&
outputformat=nc&
stridetime=1&

stridex=&
stridey=&
xn=201&
yn=173&

fieldoutput=H,SEP,VELU,VELUV_abs,VELV,XDEP,YDEP&

format=nc
,
format=txt % will give ndump
