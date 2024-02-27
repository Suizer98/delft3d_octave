function deg = str2deg(x,varargin)
%STR2DEG  get float deg from: d° m' s" E
%
% deg = str2deg(string,<keyword,value>)
%
% where string can be char for one coordinate, 
% or a cellstr for a list.
% call for lat and lon separately.
% use keyword to change dms seperators.
%
% Example:
% str2deg('158° 20'' 36" E') = +158.3433
% str2deg('158° 20'' 36" w') = -158.3433
%
%See also: convertCoordinates, d2dms

OPT.dsep = '°';
OPT.msep = '''';
OPT.ssep = '"';

if nargin==0
    deg = OPT;
    return
end

OPT = setproperty(OPT,varargin);

if iscell(x)
    deg = cellfun(@str2deg,x);
else

    i0=strfind(x,OPT.dsep);
    i1=strfind(x,OPT.msep);
    i2=strfind(x,OPT.ssep);

    dg = str2num(x(   1:i0-1));
    mn = str2num(x(i0+1:i1-1));
    sc = str2num(x(i1+1:i2-1));
    hs = strtok(x(i2+1:end)); % hemisphere: E,W,N,S

    if     strcmpi(hs,'E');hs = +1;
    elseif strcmpi(hs,'W');hs = -1;
    elseif strcmpi(hs,'N');hs = +1;
    elseif strcmpi(hs,'S');hs = -1;
    end

    deg = hs*(dg + (mn + sc/60)/60);
    
end    