function [varargout] = mvbGetData(varargin)
%MVBGETDATA Gets timeseries from Meetnet Vlaamse Banken API.
%
%   mvbGetData retreives timeseries from the API of Meetnet Vlaamse Banken
%   (Flemish Banks Monitoring Network API). Only one parameter can be
%   retreived per call. The data is returned as two vectors: time and value. 
%   Optionally data (including meta-data) is returned in a struct.
%   Meetnet Vlaamse Banken (Flemish Banks Monitoring Network API) only
%   accepts requests for timeseries <=365 days. This script runs several
%   subsequent GET requests to obtain a longer time series.
%
%   A login token is required, which can be obtained with MVBLOGIN. A login
%   can be requested freely from https://meetnetvlaamsebanken.be/
%
%   Syntax:
%   [time, value] = mvbGetData(<keyword>, <value>, token);
%
%   Input: For <keyword,value> pairs call mvbGetData() without arguments.
%   varargin =
%       id: 'string'
%           MeasurementID string, choose one from the catalog list:
%           ctl.AvailableData.ID The catalog can be obtained via
%           mvbCatalog.
%       start: 'string'
%           Start time string in format: 'yyyy-mm-dd HH:MM:SS' (the time
%           part is optional).
%       end: 'string'
%           End time string, same format as start.
%       vector: [true|false]
%           Output as two column vectors [time, value] instead of full
%           struct.
%       token: <weboptions object>
%           Weboptions object containing the accesstoken. Generate this
%           token via mvbLogin. If no token is given or invalid, the user
%           is prompted for credentials.
%
%   Output:
%   varargout = 
%       [t,v]: column vectors containing time in datenum and value.
%       For units see the catalog via mvbCatalog.
%
%   Example
%   [t,v]=mvbGetData('id','BVHGH1','start','2010-01-01','end','2017-03-05','vector',true,'token',token);
%
%   See also: MVBLOGIN, MVBCATALOG, MVBMAP, MVBTABLE.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 KU Leuven
%       Bart Roest
%
%       bart.roest@kuleuven.be
%       l.w.m.roest@tudelft.nl
%
%       KU Leuven campus Bruges,
%       Spoorwegstraat 12
%       8200 Bruges
%       Belgium
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
% Created: 03 May 2019
% Created with Matlab version: 9.5.0.1067069 (R2018b) Update 4

% $Id: mvbGetData.m 17764 2022-02-15 08:34:29Z l.w.m.roest.x $
% $Date: 2022-02-15 16:34:29 +0800 (Tue, 15 Feb 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 17764 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/meetnetvlaamsebanken/mvbGetData.m $
% $Keywords: $

%%
OPT.apiurl='https://api.meetnetvlaamsebanken.be/V2/'; %Base URL
OPT.token=weboptions;
OPT.id='AKZGH1'; %Akkaert South Buouy, Wave Height
OPT.start='2018-01-01 00:00:00'; % Start time
OPT.end=datestr(now,'yyyy-mm-dd'); % End time
OPT.vector=true; % Output switch

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
elseif mod(nargin,2)==1;
    OPT.token = varargin{end}; %Assume token is the last input argument.
    varargin = varargin(1:end-1);
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% Login check
% Check if login is still valid!
response=webread([OPT.apiurl,'ping'],OPT.token);
if isempty(response.Customer) %If login has expired.
    fprintf(1,['Your login token has expired or is invalid, please login using mvbLogin \n'...
        'Use the obtained token from mvbLogin in this function. \n']);
    fprintf(1,'Trying auto-login using mvbLogin_private.m... ');
    OPT.token = mvbLogin_private;
    response=webread([OPT.apiurl,'ping'],OPT.token);
    if isempty(response.Customer) %If login is invalid
        fprintf(1,' Failed.\n');
        
        un=input('username: ','s'); 
        fprintf(1,[repmat('\b',1,length(un)+12),'\n']);
        pw=input('password: ','s'); 
        fprintf(1,[repmat('\b',1,length(pw)+12),'\n']);
        warning('Remove your password from the command history!')
        
        OPT.token = mvbLogin('username',un,'password',pw);
        clear un pw
        response=webread([OPT.apiurl,'ping'],OPT.token);
        if isempty(response.Customer) %If login is invalid
            fprintf(1,['Your login token is invalid, please login using mvbLogin \n'...
                'Use the obtained token from mvbLogin in this function. \n']);
            varargout=cell(nargout);
            return
        end
    else
        fprintf(1,' Success.\n');
    end
end

%% Input check
%Only for vectorised output!!
fprintf(1,'Request %s data from %s to %s\n',OPT.id,OPT.start,OPT.end);

%Verify datestrings
try 
    tstart=datenum(OPT.start,'yyyy-mm-dd HH:MM:SS');
catch 
    try
        tstart=datenum(OPT.start,'yyyy-mm-dd');
    catch
        tstart=datenum(OPT.start);
        fprintf(1,'WARNING: start interpreted as: %s\n',datestr(tstart,'yyyy-mmm-dd HH:MM:SS'));
    end
end
try
    tend=datenum(OPT.end,'yyyy-mm-dd HH:MM:SS');
catch
    try
        tend=datenum(OPT.end,'yyyy-mm-dd');
    catch
        tend=datenum(OPT.end);
        fprintf(1,'WARNING: end interpreted as: %s\n',datestr(tend,'yyyy-mmm-dd HH:MM:SS'));
    end
end

if tend < tstart
    error('OPT.start must be before OPT.end!');
else

end

%Vector of start timestamps. Maximum timespan per request is 365 days (not
%1 year!).
%t_start=datenum(OPT.start):365:datenum(OPT.end);
t_start=tstart:365:tend;

for t=1:length(t_start);
    if (t_start(t)+365) <= tend; %datenum(OPT.end);
        t_end=t_start(t)+365;
    else%if (t_start+365) > tend; %datenum(OPT.end);
        t_end=tend;%datenum(OPT.end);
    end
    %data=getData(OPT,t_start,t_end);
    fprintf(1,'Retreiving data for ID: %s from %s to %s\n',OPT.id,...
        datestr(t_start(t),'yyyy-mmm-dd'),datestr(t_end,'yyyy-mmm-dd'));
    tempdata(t)=webwrite([OPT.apiurl,'getData'],...
        'StartTime',datestr(t_start(t),'yyyy-mm-dd HH:MM:SS'),...
        'EndTime',  datestr(t_end     ,'yyyy-mm-dd HH:MM:SS'),...
        'IDs',OPT.id,OPT.token); %#ok<AGROW>
    
    if isempty(tempdata(t).Values) % When ID is not found, data.Values will be empty
        warning('Warning: empty result, ID %s not found! \nPlease consult the Catalog.\n',OPT.id);
        varargout={[],[]};
        return
    elseif isempty(tempdata(t).Values.Values); %When ID is found, but no data is available in the time interval, the values are empty.
        fprintf(1,'ID %s was found, but there is no data in the time interval.\n',OPT.id);
    end
    
end

%% Postprocess output
% In case of OPT.vector==true, only output column vectors with time and
% measurement value. This also automatically happens when two output
% arguments are requested.
t=[];
v=[];
if nargout==2 || OPT.vector %Output only time and value vectors!
    for n=1:length(tempdata);
        if isempty(tempdata(n).Values) || isempty(tempdata(n).Values.Values);
            %In case of no data.
            %Do nothing...
        else
            %When there is data.
            t=[t;datenum({tempdata(n).Values.Values.Timestamp}','yyyy-mm-ddTHH:MM:SS')]; %#ok<AGROW>
            v=[v;[tempdata(n).Values.Values.Value]']; %#ok<AGROW>
        end
    end
    %Data is not always sorted on the server. But no-one likes unsorted
    %timeseries! Therefore they will be sorted here for you! While we're at
    %it, let's filter out double occurences as well.
    [t,idx]=unique(t,'first');
    v=v(idx);
    varargout={t,v};
else
    % Combine data into single struct
    st=[];
    et=[];
    for n=1:length(tempdata)
        if ~isempty(tempdata(n).StartTime); 
            st=[st;datenum(tempdata(n).StartTime,'yyyy-mm-ddTHH:MM:SS')];  %#ok<AGROW>
            et=[et;datenum(tempdata(n).EndTime,  'yyyy-mm-ddTHH:MM:SS')];  %#ok<AGROW>
        end
    end
    data.StartTime=datestr(datestr(min(st)),'yyyy-mm-ddTHH:MM:SS+00:00');
    data.EndTime=  datestr(datestr(max(et)),'yyyy-mm-ddTHH:MM:SS+00:00');
    data.Intervals=nanmean([tempdata.Intervals]);

    data.Values.ID=tempdata(end).Values.ID;
    data.Values.StartTime=data.StartTime;
    data.Values.EndTime=  data.EndTime;
    temp=[tempdata.Values];
    data.Values.Minvalue=min([temp.MinValue]);
    data.Values.Maxvalue=max([temp.MaxValue]);
    data.Values.Values=struct('Timestamp',[],'Value',[]);
    for k=1:length(tempdata);
        if ~isempty(tempdata(k).Values) && ~isempty(tempdata(k).Values.Values);
            nov=length(tempdata(k).Values.Values);
            data.Values.Values(end+1:end+nov,1)=tempdata(k).Values.Values;
        end
    end
    data.Values.Values=data.Values.Values(2:end);
    varargout={data};
end
end
%EOF