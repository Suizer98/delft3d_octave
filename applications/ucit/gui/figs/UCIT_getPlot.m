function UCIT_getPlot(d, axisNew)
%PLOTTRANSECT   routine plots transect (called by UCIT GUI)
%
%   More detailed description goes here.
%
%   Syntax:
%   
%
%   Input:
%   
%
%   Output:
%   
%
%   Example
%  
%
%   See also 

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
%% preprocess input to fit below routines
try
    if isnumeric(d.area)
        d.area=num2str(d.area);
    end
end

%% prepare figure window
try
    guiH=findobj('tag','UCIT_mainWin');
end

if get(findobj(guiH,'tag','UCIT_holdFigure'),'value')==0 && ~isempty(findobj('tag','plotWindow'))
    fh=findobj('tag','plotWindow');
    figure(fh)
    ah=gca;
    try
        if nargin == 1
            axisNew = axis(gca);
            set(fh,'UserData',d);

            hold off;

            %plot entire jarkus profiel
            if ~isempty(d.ze)
                try
                    ph1=plot(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),'b');
                catch
                    ph1=plot(d(1).xe(~isnan(d(1).ze)),d(1).ze(~isnan(d(1).ze)),'b');
                end
                hold on
                
                % make grey patch
                x = d.xe(~isnan(d.ze));z = d.ze(~isnan(d.ze));
                patch([x(1); x; x(end)],[min(z)-1; z; min(z)-1],[0 0 0],'LineStyle','none','FaceAlpha',0.1)


                %plot measured jarkus profiel only if hold crossec. figure is not checked
                try
                    if get(findobj(guiH,'tag','UCIT_holdFigure'),'value')==0
                        try
                            ph2=plot(d.xi(~isnan(d.ze)),d.zi(~isnan(d.ze)),'k','linewidth',0.5);
                        catch
                            ph2=plot(d(1).xi(~isnan(d(1).ze)),d(1).zi(~isnan(d(1).ze)),'k','linewidth',0.5);
                        end
                    end
                end
                xlabel('Cross shore distance [m]');
                ylabel('Elevation [m to datum]');
                title('Transect');
                axis([min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze))) -35 35]);
                set(gca,'XDir','reverse');
                box on
                axis(axisNew)
                minmax = axis;
                handles.XMaxRange = [minmax(1) minmax(2)];
                handles.YMaxRange = [minmax(3) minmax(4)];
                guidata(fh,handles);
            end
        end
    end
else
    try
        fh=figure('tag','plotWindow');clf;

        RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' (d.transectID) '  Time: ' num2str(d.year)];
        set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');

        ah=axes;

        [fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);

        set(fh,'UserData',d);

        hold on;

        %plot entire jarkus profiel
        if ~isempty(d.ze)
            try
                ph1=plot(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),'b');
            catch
                ph1=plot(d(1).xe(~isnan(d(1).ze)),d(1).ze(~isnan(d(1).ze)),'b');
            end
            hold on
            
            % make grey patch
            x = d.xe(~isnan(d.ze));z = d.ze(~isnan(d.ze));
            patch([x(1); x; x(end)],[min(z)-1; z; min(z)-1],[0 0 0],'LineStyle','none','FaceAlpha',0.1)


            %plot measured jarkus profiel only if hold crossec. figure is not checked
            try
                if get(findobj(guiH,'tag','UCIT_holdFigure'),'value')==0
                    try
                        ph2=plot(d.xi(~isnan(d.ze)),d.zi(~isnan(d.ze)),'k','linewidth',0.5);
                    catch
                        ph2=plot(d(1).xi(~isnan(d(1).ze)),d(1).zi(~isnan(d(1).ze)),'k','linewidth',0.5);
                    end
                end
            end
            xlabel('Cross shore distance [m]');
            ylabel('Elevation [m to datum]');
            title('Transect');
            axis([min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze))) min(z)-1 35]);
            set(gca,'XDir','reverse');
            box on
            minmax = axis;
            handles.XMaxRange = [minmax(1) minmax(2)];
            handles.YMaxRange = [minmax(3) minmax(4)];
            guidata(fh,handles);

        else
            plot3(d.fielddata.rawx,d.fielddata.rawy,d.fielddata.rawz)
            xlabel('Cross shore distance [m]');
            ylabel('Elevation [m to datum]');
            title('Transect');
        end
    catch
        fh=figure('tag','plotWindow');clf;

        RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' num2str(d.year)];
        set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
        ah=axes;
        set(fh,'UserData',d);

        [fh,ah] = UCIT_prepareFigureN(0 ,fh, 'UL', ah, @doNothing, [], @doNothing, []);
    end
end

RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' num2str(d.year)];
set(fh,'Name', RaaiInformatie,'NumberTitle','Off','Units','normalized');
handles = guidata(fh);
