function varargout = mvbTable(varargin)
%MVBTABLE  Shows table of available parameters at locations.
%
%   mvbTable shows an overview with combinations of parameters and
%   measurement locations, for which data is available. Further, a list
%   with the full names of these locations is presented. The order of the
%   list is the same as the order of the codes.
%   Optionally the language in which the full names are presented can be
%   changed to Dutch, French or English (default).
%
%   Combinations with available data can be used to request data with
%   mvbGetData, e.g. "A2 boei" 'A2B' with "Golfhoogte - Boeien" 'GHA' -->
%   'A2BGHA'.
%
%   Syntax:
%   dataTable = mvbTable(<keyword>, <value>, token);
%
%   Input: For <keyword,value> pairs call mvbTable() without arguments.
%       token: <weboptions object>
%           Weboptions object containing the accesstoken. Generate this
%           token via mvbLogin. If no token is given or invalid, the user
%           is prompted for credentials.
%       language: string of preferred language: 'NL','FR' or 'EN',
%           officially 'nl-BE', 'fr-FR' or 'en-GB'.
%       catalog: catalog of all data, obtained from MVBCATALOG.
%       apiurl: url to Meetnet Vlaamse Banken API.
%
%   Output:
%   	datatable: mask indicating data availability for location/parameter
%           combinations.
%
%   Example
%   mvbTable(token);
%
%   See also: MVBLOGIN, MVBCATALOG, MVBMAP, MVBGETDATA.

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
% Created: 09 Jul 2019
% Created with Matlab version: 9.5.0.1067069 (R2018b) Update 4

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT.apiurl='https://api.meetnetvlaamsebanken.be/V2/';
OPT.token=weboptions;
OPT.catalog=nan;
OPT.language='en-GB';

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
elseif mod(nargin,2)==1;
    OPT.token = varargin{end}; %Assume token is the last input argument.
    varargin = varargin(1:end-1);
end
if length(varargin) >= 2
    % overwrite defaults with user arguments
    OPT = setproperty(OPT, varargin);
end

if ischar(OPT.language);
    if strncmpi(OPT.language,'NL',1);
        OPT.language='nl-BE';
    elseif strncmpi(OPT.language,'FR',1);
        OPT.language='fr-FR';
    elseif strncmpi(OPT.language,'EN',1);
        OPT.language='en-GB';
    else
        fprintf(1,'Unknown language option "%s", using en-GB instead. \n',OPT.language);
        OPT.language='en-GB';
    end
% elseif isscalar(OPT.language) && OPT.language >=1 && OPT.language <=3;
%     %Use number
else
    fprintf(1,'Unknown language option "%s", using en-GB instead. \n',OPT.language);
    OPT.language='en-GB';
end

if isnan(OPT.catalog)
    % No previous catalog, fetch from server.
    catalog=mvbCatalog(OPT.token);
else
    % Use previously fetched catalog.
    catalog=OPT.catalog;
end
%% code
% Find index for locale/language.
% Try for chosen language.
langIdx=find(strcmpi({catalog.Locations(1).Name.Culture},{OPT.language}),1);
% When choosen language is not available in catalog, fall back to 'en-GB'.
if isempty(langIdx);
    fprintf(1,'Language "%s" not available in catalog, using en-GB instead.\n',OPT.language);
    langIdx=find(strcmpi({catalog.Locations(1).Name.Culture},{'en-GB'}),1);
end

Locations={catalog.Locations.ID};
Parameters={catalog.Parameters.ID};
AvailableData={catalog.AvailableData.ID};
%pcolor ambiguities require matrix dimensions to be one larger.
dataTable=false(length(Locations)+1,length(Parameters)+1);

temp=[catalog.Locations.Name];
LocName={temp(langIdx,:).Message}';
temp=[catalog.Parameters.Name];
ParName={temp(langIdx,:).Message}';

for m=1:length(Locations);
    for n=1:length(Parameters);
        if any(strcmpi([Locations{m} Parameters{n}],AvailableData));
            dataTable(m,n)=true;
        end
    end
end

% % figure;
% % ax=subplot(1,3,[1:2]);
% % pcolorcorcen(1:length(Parameters)+1,length(Locations)+1:-1:1,single(dataTable));
% % shading faceted;
% % ax.XAxis.TickValues=[1:1:length(Parameters)]+0.5;
% % ax.XAxis.TickLabels=Parameters;
% % ax.YAxis.TickValues=[1:1:length(Locations)]+0.5;
% % ax.YAxis.TickLabels=flipud(Locations(:));
% % xlabel('Location code');
% % ylabel('Parameter code');
% % 
% % subplot(1,3,3);
% % xlim([0 2]);
% % ylim([0 length(Locations)+1]);
% % text(zeros(size(Locations)),length(Locations):-1:1,LocName);
% % text(ones(size(Parameters)),length(Parameters):-1:1,ParName);
% % p0=patch(0,0,0); % Create dummy patch to create a legend.
% % p1=patch(0,0,1);
% % legend([p0;p1],'No data','Data available','Location','NE');
% % 
% % axis off;

figure; 
ax=axes('Units','normalized','Position',[0.30 0.30 0.60 0.65]); hold on;
%pcolor ambiguities require matrix dimensions to be one larger.
pcolor(1:length(Parameters)+1,length(Locations)+1:-1:1,single(dataTable));
shading faceted;
ax.XAxis.TickValues=[1:1:length(Parameters)]+0.5;
ax.XAxis.TickLabels=Parameters;
ax.YAxis.TickValues=[1:1:length(Locations)]+0.5;
ax.YAxis.TickLabels=flipud(Locations(:));
xlabel('Location code');
ylabel('Parameter code');

text(ax,-2.*ones(size(Locations)),(length(Locations):-1:1)+0.5,LocName,'HorizontalAlignment','right');
text(ax,(1:1:length(Parameters))+0.5,-3.*ones(size((Parameters))),ParName,'Rotation',-45);
p0=patch(ax,0,0,0); % Create dummy patch to create a legend.
p1=patch(ax,0,0,1);
ylim([1 length(Locations)+1]);
xlim([1 length(Parameters)+1]);
legend(ax,[p0;p1],'No data','Data available','Position',[0.15 0.15 0 0]);

varargout={dataTable};
end
%EOF
