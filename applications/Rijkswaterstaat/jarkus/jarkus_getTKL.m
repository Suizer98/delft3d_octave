function TKL = jarkus_getTKL(targetyear, transectID, varargin)

%JARKUS_GETTKL  returns the cross shore coordinate of the TKL (te toetsen kustlijn)
%
% syntax:
%   TKL = jarkus_getTKL(2000, 7003800, 'plot') 
%
%  input:
%  targetyear          = year of which the TKL value is needed, e.g. 2008
%  transectID          = sum of area code (x1000000) and alongshore coordinate
%
%  output:
%  xTKL                = cross shore coordinate of MKL
%  plot if requested
% 
%
%   See also jarkus_getMKL jarkus_getBKL UCIT_calculateTKL 
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------


%% get url
datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp('Jarkus Data',datatypes.transect.names))};

%% read data of 10 previous years
tkl_year_array = [targetyear - 11: targetyear - 1];

%d=struct;
for i = 1 : 11
    d(i) = jarkus_readTransectDataNetcdf(url,transectID,tkl_year_array(i));
end



%% prepare input (targetyear should be integer)
years = vertcat(d.year);
[sorted, idsort]=sort(years);d = d(idsort);years=years(idsort);
idjaar = find(years<targetyear);

%% then calculate MKL values
dunefoot = 3; % Fixed dunefoot level of +3m NAP.
for i = min(idjaar):max(idjaar)
    if ~isempty(d(i).xe(~isnan(d(i).ze)))
        tkldata(i,1) = datenum([num2str(d(i).year+1964) '0101'], 'yyyyddmm');
        tkldata(i,2) = jarkus_getMKL(d(i).xe(~isnan(d(i).ze)), d(i).ze(~isnan(d(i).ze)), dunefoot, dunefoot - 2*(dunefoot - d(i).MLW));
    else
        errordlg('No TKL could be computed because no data was found')
        return
    end
end

%% remove nan values
tkldata = tkldata(~isnan(tkldata(:,2)),:);

%% execute regression
dns_targetyear = datenum([num2str(targetyear) '0101'],'yyyyddmm');
dns_startyear  = datenum([num2str(tkl_year_array(1)) ,'0101'],'yyyyddmm');
dns_stopyear   = datenum([num2str(tkl_year_array(end)) ,'0101'],'yyyyddmm');
idRegYears     = ...
    tkldata(:,1) >= dns_startyear & ...
    tkldata(:,1) <= dns_stopyear;
[reg,S]        = polyfit(tkldata(idRegYears,1),tkldata(idRegYears,2),1);

alpha          = 0.05; % to plot 95% conf. interval
xreg           = dns_startyear:dns_targetyear;
[yreg,delta]   = polyconf(reg,xreg,S,alpha);

%% determine TKL value
TKL          = polyval(reg, dns_targetyear);
if ~isempty(varargin)
    if strcmpi(varargin{1},'plot')

        if isempty(findobj('tag','plotWindowTKL'))
            figure;
        end

        %% plot results
        ph1 = plot(tkldata(:,1),tkldata(:,2)); % dit is de MKL volgens de leidraad zandige kust methode
        set(ph1,'marker','o','markeredgecolor','b','markerfacecolor','g','markersize',6,'linewidth',1.5)
        datetick; hold on

        % plot BKL
        BKL = jarkus_getBKL(transectID);
        XLim = get(gca,'XLim');
        if ~isempty(BKL)
            ph2 = plot([tkldata(1,1) tkldata(end,1)],[BKL BKL],'-r');
        else
            disp('No BKL value available here')
        end

        %plot TKL
        ph5 = plot(dns_targetyear,TKL);

        % plot regression line with (1-alpha)*100% confidence interval
        reghLZK      = plot(xreg,yreg,'k',xreg,yreg+delta,'k--',xreg,yreg-delta,'k--');

        % set legend and labels
        legend('MKL','BKL');grid
        set(ph5,'marker','o','markeredgecolor','k','markerfacecolor','k','markersize',2)
        xlabel('Years');
        ylabel('Cross shore distance [m]', 'Rotation', 270, 'VerticalAlignment', 'top');
        title(['TKL for targetyear ',num2str(targetyear),' : ' num2str(TKL, '%4.0f'), ' m to RSP-line'], 'fontsize', 9, 'fontweight','bold');
    end
end