function varargout=getndbcdata(opt,varargin)
%GETNDBCDATA get capabilities, inventory meta-data or data from NOAA NDBC SOS web service
% 
% download metadata from internet or local cache, save to local cache
%   C = getndbcdata('getcapabilities','setglobal',1,'inputfile',[],'outputfile',[])
%
% get struct with available stations
%   S = getndbcdata('getstations') % uses global C if setglobal=1 above
%   S = getndbcdata('getstations','capabilities',C)
%   D = getndbcdata('getobservations','id',id,'parameter',parameter,'t0',t0,'t1',t1);
%
% Example:
%  S = getndbcdata('getstations')
%  var2evalstr(S(1)) % see what's available
%  D = getndbcdata('getobservations','id',S(1).id,...
%                  'parameter','air_temperature',...
%                  't0',datenum(2013,1,1),'t1',now); % time as datenum
%  D = getndbcdata('getobservations','id',S(1).id,...
%                  'parameter','air_temperature',...
%                  't0','2013-01-01T00:00:00Z','t1',now) % time as ISO string
%  D = getndbcdata('getobservations','id','0y2w3',...
%                  'parameter',S(1).observedproperties{1},...
%                  't0',S(1).t0,'t1',S(1).t1) % time from inventory
%
%  plot(D.parameters(2).parameter.time,D.parameters(2).parameter.val)
%  ylabel([mktex(D.parameters(2).parameter.name),' [',D.parameters(2).parameter.unit,']'])
%  datetick('x')
%  title(['''',D.stationid,''' [',num2str(D.longitude),',',num2str(D.latitude),']'])
%
%See also: getcoopsdata, getICESdata, ddb_ObservationStations_ndbc, http://sdf.ndbc.noaa.gov/sos

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Maarten van ormondt
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
% $Id: getndbcdata.m 16690 2020-10-27 06:10:51Z ormondt $
% $Date: 2020-10-27 14:10:51 +0800 (Tue, 27 Oct 2020) $
% $Author: ormondt $
% $Revision: 16690 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/observations/ndbctoolbox/getndbcdata.m $
% $Keywords: $

% getcapabilities
 OPT.inputfile    = '';
 OPT.outputfile   = '';
 OPT.setglobal    = 0;
% getstations
 OPT.capabilities = [];
% getobservations
 OPT.id           = [];
 OPT.parameter    = [];
 OPT.t0           = [];
 OPT.t1           = [];
 OPT.inputfile    = [];
 OPT.outpoutfile  = [];
 OPT.setglobal    = 1; % default to make ddb work !

if nargin==0
   varargout = {OPT};
   return
end

for ii=1:length(varargin) % replace with setpropery
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'global','setglobal'};OPT.setglobal    = varargin{ii+1};
            case{'inputfile'};         OPT.inputfile    = varargin{ii+1};
            case{'outputfile'};        OPT.outputfile   = varargin{ii+1};

            case{'capabilities'};      OPT.capabilities = varargin{ii+1};

            case{'id','stationid'};    OPT.id           = varargin{ii+1};
            case{'parameter'};         OPT.parameter    = varargin{ii+1};
            case{'starttime','t0'};    OPT.t0           = varargin{ii+1};
            case{'stoptime','t1'};     OPT.t1           = varargin{ii+1};
        end
    end
end

switch lower(opt)
    case{'getcapabilities'}
        capabilities = getCapabilities(OPT.inputfile,OPT.outputfile,OPT.setglobal);
        varargout{1}=capabilities.Capabilities;
    case{'getstations'}
        varargout{1}=getStations(OPT.capabilities);
    case{'getobservations'}
        varargout{1}=getData(OPT.id,OPT.parameter,OPT.t0,OPT.t1);
end

%%
function capabilities=getCapabilities(inputfile,outputfile,setglobal)

if isempty(inputfile)
    % Get data from NDBC SOS server
    capabilities=xml2struct('https://sdf.ndbc.noaa.gov/sos/server.php?request=GetCapabilities&service=SOS','structuretype','long','includeroot');
else
    % Get data from file
    [pathstr,name,ext]=fileparts(inputfile);
    switch lower(ext(2:end))
        case{'mat'}            
            capabilities=load(inputfile);
        case{'xml'}
            capabilities=xml2struct(inputfile,'structuretype','long','includeroot');
    end
end

if ~isempty(outputfile)
    [pathstr,name,ext]=fileparts(outputfile);
    switch lower(ext(2:end))
        case{'mat'}            
            save(outputfile,'-struct','capabilities');
        case{'xml'}
            struct2xml(outputfile,capabilities,'structuretype','long','includeattributes','includeroot')
    end
end

if setglobal
    setCapabilitiesGlobal(capabilities);
end

%%
function setCapabilitiesGlobal(capabilities)

global NDBCCapabilities

NDBCCapabilities=capabilities.Capabilities;

%%
function stations=getStations(varargin)

if isempty(varargin{1})
   global NDBCCapabilities
else
    NDBCCapabilities = varargin{1};
end

s0=NDBCCapabilities.Contents.Contents.ObservationOfferingList.ObservationOfferingList.ObservationOffering;

n=0;
for ib=1:length(s0)
    s=s0(ib).ObservationOffering;
    id=s.ATTRIBUTES.id.value;
    switch id
        case{'network-all'}
        otherwise
            n=n+1;
            stations(n).id          = id(end-4:end);
            stations(n).description = s.description.description.value;
            loc=str2num(s.boundedBy.boundedBy.Envelope.Envelope.upperCorner.upperCorner.value);
            stations(n).x           = loc(2);
            stations(n).y           = loc(1);
            
            stations(n).t0 = s.time.time.TimePeriod.TimePeriod.beginPosition.beginPosition.value;
            stations(n).t1 = s.time.time.TimePeriod.TimePeriod.endPosition.endPosition.value;
            
            if length(stations(n).t0)<2; stations(n).t0 = [];end
            if length(stations(n).t1)<2; stations(n).t1 = [];end
            
            np=length(s.observedProperty);
            for ip=1:np
                property=s.observedProperty(ip).observedProperty.ATTRIBUTES.href.value;
                ii=find(property=='/');
                property=property(ii(end)+1:end);
                stations(n).observedproperties{ip}=property;
            end
    end
end

%%
function data=getData(id,parameter,t0,t1)
   
url='https://sdf.ndbc.noaa.gov/sos/server.php';

arg.request          = 'GetObservation';
arg.service          = 'SOS';
arg.version          = '1.0.0';
arg.responseformat   = 'text/xml;subtype="om/1.0.0"';
arg.responseformat   = 'text/csv';
arg.offering         = ['urn:ioos:station:wmo:' id];
arg.observedproperty = parameter;
if ~ischar(t0);t0    = datestr(t0,'yyyy-mm-ddTHH:MM:SSZ');end
if ~ischar(t1);t1    = datestr(t1,'yyyy-mm-ddTHH:MM:SSZ');end
arg.eventtime        = [t0 '/' t1];

urlstr=[url '?'];
fldnames=fieldnames(arg);
for ii=1:length(fldnames)
    urlstr=[urlstr fldnames{ii} '=' arg.(fldnames{ii})];
    if ii<length(fldnames)
        urlstr=[urlstr '&'];
    end
end

disp(urlstr)

try
s=urlread(urlstr);
catch
options = weboptions('TimeOut',20,'ContentType','text');
s=webread(urlstr,options);
end

data=[];

values=textscan(s,'%s','delimiter','\n');

% First read the parameter list
parstr     = values{1}{1};
parameters = textscan(parstr,'%s','delimiter',',');    
parameters = parameters{1};
for ip=1:length(parameters)
    par  =textscan(parameters{ip},'%s','delimiter','"');
    parameters{ip}(parameters{ip}=='"')='';
    ii=find(parameters{ip}==' ');
    if ~isempty(ii)
              unit{ip}=parameters{ip}(ii(1)+2:end-1);
        parameters{ip}=parameters{ip}(1:ii(1)-1);
    else
        unit{ip}='';
    end
end

% Now read the data
v=values{1};
v=v(2:end);
nt=length(v);

if nt>0
    
    for it=1:nt
        vv=textscan(v{it},'%s','delimiter',',');
        vv=vv{1};
        for ip=1:length(vv)
            val{it,ip}=vv{ip};
        end
        if strcmpi(v{it}(end),',')
            val{it,ip+1}='';
        end
    end
    
    d=[];
    
    for ip=1:length(parameters)
        switch parameters{ip}
            case{'date_time'}
                time=zeros(1,nt);
                for it=1:nt
                    str=val{it,ip};
                    str=strrep(str,'T',' ');
                    str=strrep(str,'Z',' ');
                    time(it)=datenum(str);
                end
            case{'station_id'}
                stationid=val{1,ip};
            case{'sensor_id'}
                sensorid=val{1,ip};
            case{'calculation_method'}
                calculationmethod=val{1,ip};
            case{'longitude'}
                lon=str2double(val{1,ip});
            case{'latitude'}
                lat=str2double(val{1,ip});
            otherwise
                % Real data
                % First check dimensions
                if isempty(val{1,ip})
                    npoints=0;
                else
                    cls=textscan(val{1,ip},'%f','delimiter',';');
                    npoints=length(cls{1});
                end
                d.(parameters{ip}).data=zeros(npoints,nt);
                for it=1:nt
                    if isempty(val{it,ip})
                        d.(parameters{ip}).data(it)=NaN;
                    else
                        cls=textscan(val{it,ip},'%f','delimiter',';');
                        d.(parameters{ip}).data(:,it)=cell2mat(cls);
                    end
                end
                d.(parameters{ip}).unit=unit{ip};
        end
    end
    
    % Now store in a proper data structure
    fldnames=fieldnames(d);
    data.stationname  = '';
    data.stationid    = nocolon(stationid);
    data.longitude    = lon;
    data.latitude     = lat;
    data.timezone     = 'UTC';
    data.source       = 'NDBC';
    for ip=1:length(fldnames)
        data.parameters(ip).parameter.name = fldnames{ip};
        data.parameters(ip).parameter.time = time;
        data.parameters(ip).parameter.val  = d.(fldnames{ip}).data;
        if size(d.(fldnames{ip}).data,1)>2
            % spectral data
            data.parameters(ip).parameter.size=[length(time) 0 size(d.(fldnames{ip}).data,1) 0 0];
        else
            % time series
            data.parameters(ip).parameter.size=[length(time) 0 0 0 0];
        end
        data.parameters(ip).parameter.quantity='scalar';
        data.parameters(ip).parameter.unit    =d.(fldnames{ip}).unit;
    end
    
end

