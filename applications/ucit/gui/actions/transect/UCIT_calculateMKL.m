function UCIT_calculateMKL()
%UCIT_calculateMKL shows the cross shore coordinate of the volume based coastal indicator MKL
%
% input: through UCIT GUI
%
% output: through UCIT GUI
%
%
%   See also jarkus_getMKL

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
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

[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

%% get (meta)data
datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
year = UCIT_getInfoFromPopup('TransectsSoundingID');
d = jarkus_readTransectDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'),UCIT_getInfoFromPopup('TransectsTransectID'),year(end-3:end));
d.zi = squeeze(d.zi);
d.ze = squeeze(d.ze);

if ~all(isnan(d.ze))
    %% prepare plot
    nameInfo=['UCIT - MKL analysis - ', 'Area: ', d.area, '  Transect: ', d.transectID,'  Year: ', num2str(d.year)];

    guiH=findobj('tag','UCIT_mainWin');
    if ~isempty(guiH)
        % if hold is off or the figure does not yet exist create a new fig
        if get(findobj(guiH,'tag','UCIT_holdFigure'),'value')==0
            try
                close(findobj('tag','plotWindowMKL'));
            end
            fh=figure('tag','plotWindowMKL'); clf; ah=axes;
            set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
            [fh,ah] = UCIT_prepareFigureN(2, fh, 'UL', ah);

        else % find the fig handle erase the figure and reuse
            fh=findobj('tag','plotWindowMKL');
            hold on;

        end
    else % this else statement allows this routine to be useful outside the UCIT context
        fh=figure('tag','plotWindowMKL'); clf; ah=axes;
        set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
        [fh,ah] = UCIT_prepareFigureN(2, fh, 'UL', ah);
    end

    %% calculate MKL position
    dunefoot = 3;


    [MKL] = jarkus_getMKL(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),dunefoot , dunefoot - 2*(dunefoot - d.MLW),'plot');hold on;

    %% prepare result structure
    result.xold                 = d.xe;
    result.zold                 = d.ze;
    result.xout                 = d.xe;
    result.zout                 = d.ze;
    result.area                 = d.area;
    result.transectID           = d.transectID;
    result.year                 = num2str(d.year);


    %% plot MLW
    if ~isempty(d.MLW)
        ph2=plot([min(result.xout(~isnan(result.zout))) max(result.xout(~isnan(result.zout)))],[d.MLW d.MLW],':g');
        th2=text(max(result.xout(~isnan(result.zout)))-100,d.MLW,'GLW \rightarrow');
        set(th2,'fontsize',8,'fontweight','bold','HorizontalAlignment','right','VerticalAlignment','middle');
    end

    %% plot over that a vertical line at CoastlinePosition
    YLim = get(gca,'YLim');
    try
        ph3=plot([MKL MKL],[min(YLim) max(YLim)],'-.r');
    end

    % plot MKL text
    th3=text(MKL,min(YLim)+0.05*(max(YLim) - min(YLim)),'Xmkl \rightarrow');
    set(th3,'fontsize',8,'fontweight','bold','HorizontalAlignment','right','VerticalAlignment','middle');

    %% plot MKL point
    warning off
    zMKL = interp1(d.xe(~isnan(d.ze)), d.ze(~isnan(d.ze)), MKL); %#ok<AGROW>
    warning on
    scatter(MKL,zMKL,'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','SizeData',4)

    xlabel('Cross shore distance [m]');
    ylabel('Elevation [m to datum]', 'Rotation', 270, 'VerticalAlignment', 'top');
%     title({'Momentane Coastline Position (MKL)',['Area: ', d.area, '  Transect: ', d.transectID,'  Year: ',num2str(d.year)]});

    
    title(['MKL for targetyear ',num2str(d.year),' : ' num2str(MKL, '%4.0f'), ' m to RSP-line'], 'fontsize', 9, 'fontweight','bold');

    % plot MKL result
 
     ax = axis;
     x = d.xe(~isnan(d.ze));z = d.ze(~isnan(d.ze));
     axis([min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze))) min(z)-1 35]);
%     MKLtext = text(0.6*ax(2),0.8*ax(4),['MKL: ', num2str(MKL,'%3.1f'), ' m to RSP-line']);
%     set(MKLtext,...
%         'FontSize',8,...
%         'fontweight','bold');
    set(gca,'xdir','reverse')

    % varargin = { ...
    %     'MKL: ', MKL, ' m to RSP-line'};
    % UCIT_displayResultsOnFigure(gca,varargin)

else
    errordlg(['Transect: ', d.transectID,'  Year: ',num2str(d.year) ' does not contain data']);
end
