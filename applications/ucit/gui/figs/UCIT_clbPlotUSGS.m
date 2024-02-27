function UCIT_clbPlotUSGS%(d)
%UCIT_CLBPLOTUSGS  callback of gui plotAlongshore
%
%
%   See also plotAlongshore

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
%   --------------------------------------------------------------------clear selecteditems;clc;

%% check whether overview figure is present
[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

mapW=findobj('tag','mapWindow');
if isempty(mapW)
    errordlg('First make an overview figure (plotTransectOverview)','No map found');
    return
end

par=findobj('tag','par');
if ~isempty(par);
    close(par)
end

if ~isempty(get(findobj('Tag','beginTransect'),'value'))

    % get data from userdata mapWindow
    fh = findobj('tag','UCIT_mainWin');
    d=get(fh,'UserData');

    % get begin and endtransect from d
    beginTransect = d.transectID(get(findobj('Tag','beginTransect'),'value'));
    endTransect = d.transectID(get(findobj('Tag','endTransect'),'value'));

    % if the selected end transect is smaller than the begin transect reverse the two
    if str2double(beginTransect) > str2double(endTransect)
        x=findobj('Tag','beginTransect');
        t=get(findobj('Tag','beginTransect'),'value');
        set(x,'value',get(findobj('Tag','endTransect'),'value'));
        y=findobj('Tag','endTransect');
        set(y,'value',t);
        beginTransect = d(get(findobj('Tag','beginTransect'),'value')).transectID;
        endTransect = d(get(findobj('Tag','endTransect'),'value')).transectID;
    end

    d = UCIT_SelectTransectsUS('Lidar Data US','2002',beginTransect,endTransect);

else
    d = UCIT_SelectTransectsUS;
end

% define parameters for figures and legends
USGSParameters      = {'Significant wave height','Peak wave period','Wave length (L0)','Shoreline position','Shoreline change','Beach slope','Bias','Mean High Water Level'};
USGSParametersshort = {'H_s','T_p','L_0','Shoreline Position','Shoreline change since 1930','\beta','Bias','Z_m_h_w'};
selecteditems       = get(findobj('Tag','Input'),'Value');

lat = get(findobj('tag','lattitude'),'value');
refline = get(findobj('tag','refline'),'value');
flipaxis = get(findobj('tag','flipaxis'),'value');

% find right transectnumbers from gui
a = get(findobj('Tag','beginTransect'),'value');
b = get(findobj('Tag','endTransect'),'value');

if lat==1 && refline==1
    errordlg('Select either lattitude or distance along reference line')
else

    % prepare figure
    sp4 = figure; ah4 = axes;
    set(sp4, 'visible','off', 'Units','normalized')
    set(sp4, 'tag','par','name','UCIT - Parameter selection');
    [sp4, ah] =  UCIT_prepareFigureN(0, sp4, 'UL', ah4);
    set(findobj('tag','par'), 'Position',UCIT_getPlotPosition('UL'));

    counter=0;
    
    for i = selecteditems;
        counter = counter+1;
        subplot(length(selecteditems),1,counter);
        x = str2double(d.transectID);
        x = x(a:b);
        if lat == 1
            [longitude,latitude] = convertCoordinates(d.shore_east(a:b),d.shore_north(a:b),'CS1.code',32610,'CS2.code',4326);
            x = latitude;
        end
        if refline == 1
            x = 0:2:length(d.transectID)*2;
            x = (x(a:b))/1000;
        end
        
       parameter = num2str(i);
       
       % define requested metadata to make plot 
        switch parameter
            case num2str(1)
                y = d.significant_wave_height(a:b) ;
            case num2str(2)
                y = d.significant_wave_height(a:b) ;
            case num2str(3)
                y = d.deep_water_wave_length(a:b);
            case num2str(4)
                y = d.shorepos(a:b);
                x1 = d.shore_east(a:b);
                y1 = d.shore_north(a:b);
                x2 = d.shore_east_1930(a:b);
                y2 = d.shore_north_1930(a:b);
                shoreline_change = sqrt((x1-x2).^2+(y1-y2).^2);
                negative = (x1-x2)./abs(x1-x2);
                shoreline_change = shoreline_change.*negative;
                y2 = y + shoreline_change;
                
            case num2str(5)
                x1 = d.shore_east(a:b);
                y1 = d.shore_north(a:b);
                x2 = d.shore_east_1930(a:b);
                y2 = d.shore_north_1930(a:b);
                shoreline_change = sqrt((x1-x2).^2+(y1-y2).^2);
                negative = (x1-x2)./abs(x1-x2);
                shoreline_change = -shoreline_change.*negative;
                y = shoreline_change;
               
            case num2str(6)
                y = d.beach_slope(a:b);
            case num2str(7)
                y = d.bias(a:b);
            case num2str(8)
                y = vertcat(d.mean_high_water);
                y = y(a:b);
        end
        
        % make plot        
        if str2num(parameter) == 4
            plot(x,y,'color','b','linewidth',2);hold on;
            plot(x,y2,'color','r','linewidth',2);
            if flipaxis
               set(gca,'xdir','reverse');
            end
            legend('Shoreline 2002','Shoreline 1930');
        elseif str2num(parameter) == 5
            % plot shoreline change
            % afarris@usgs.gov 2010feb03 changed the way the plot looks
            plot(x,y)
            hold on
            ax=axis;
            plot([ax(1) ax(2)],[0 0],'k')
%             id = a:b;
%             stack_width = 0.25;
%             for j = 1:length(id);
%                 if lat==0
%                     x1 = [x(j)-stack_width;x(j)+stack_width;x(j)+stack_width;x(j)-stack_width];
%                 else
%                     x1 = [x(j)-stack_width/5000;x(j)+stack_width/5000;x(j)+stack_width/5000;x(j)-stack_width/5000];
%                 end
%                 y1 = [0;0;shoreline_change(j);shoreline_change(j)];
%                 if shoreline_change(j) > 0
%                     patch(x1,y1,'g');
%                 else
%                     patch(x1,y1,'r');
%                 end
%             end
        else
            plot(x,y,'color','b','linewidth',2);
        end
        
        if flipaxis
           set(gca,'xdir','reverse');
        end
        grid on;box on;
        title([]);
        font=12-length(selecteditems);
        set(gca, 'fontsize',font);
        if ~isnan(x(1)) && ~isnan(x(end)) && x(1) < x(end)
            xlim([x(1) x(end)]);
        elseif ~isnan(x(1)) && ~isnan(x(end)) &&  x(1) > x(end)
            xlim([x(end) x(1)]);
        end

        % make labels
        if lat==1
            xlabel('Lattitude (degrees)');
        end
        if refline==1
            xlabel('Distance along reference line (km)');
        end
        if lat==0 && refline==0
            xlabel('Profile number');
        end

        ylabel(USGSParametersshort{i});
      
        results(counter).x = x;
        results(counter).y = y;
        clear x y
    end
    % afarris@usgs.gov 2010Feb02 moved the code that flips the axis.
    % (the old version only reversed the axis of one plot and it messed up
    % the legend)  The axis are fliped earlier in the code (f necessary).
    
    set(findobj('tag','par'), 'visible', 'on');    
    figure(findobj('tag','par'))
    set(findobj('tag','par'), 'Position', UCIT_getPlotPosition('UL'));
    set(findobj('tag','par'), 'userdata',results);

end

