function UCIT_preparePlot(FigureTag)
%UCIT_PREPAREPLOT   this routine prepares one of the UCIT figures (identified by FigureTag) for printing
%
% This routine prepares one of the UCIT figures (identified by FigureTag) for printing. 
% Through the ini-file options like a frame around the plot and proper axis settings may be activated.
%              
% input:       
%    FigureTag = tag identifying which figure to prepare  
%
% output:       
%    function has no output 
%
%   see also ucit 

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $ (Version 1.0, January 2006)
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl	
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% -------------------------------------------------------------------- 

% $Id: UCIT_preparePlot.m 4099 2011-02-24 12:57:05Z sonnevi $
% $Date: 2011-02-24 20:57:05 +0800 (Thu, 24 Feb 2011) $
% $Author: sonnevi $
% $Revision: 4099 $

% First determine what kind of plot it is, it is in the name and activate figure
figure(findobj('tag',FigureTag));

switch FigureTag
    case 'plotWindow'
        %MKL plot
        if strfind(upper(get(findobj('tag','plotWindow'),'name')),'MKL')
            %Try to get limits from INI-file, else use 10% left and right from the
            %outermost black dotted lines and -20 to 20 as lower and upper limit
            limits=getINIValue('UCIT.ini','DuinErosieXLimits');
            if isempty(limits)
                lineX=get(findobj(gcf,'linestyle','-','linewidth',1.5,'color',[0 0 0]),'xdata');
                lineY=get(findobj(gcf,'linestyle','-','linewidth',1.5,'color',[0 0 0]),'ydata');
                id=find(~isnan(lineY));
                limits=[lineX(id(1))-0.1*abs(lineX(id(end))-lineX(id(1)))-50 lineX(id(end))+0.1*abs(lineX(id(end))-lineX(id(1)))+100 -25 25];
            else
                limits=str2num(limits);
            end
            %and set axis
            axis(limits);
            
            MKLtextHandle=findobj(gcf,'string','Xmkl \rightarrow');
            MKLtextPos=get(findobj(gcf,'string','Xmkl \rightarrow'),'position');
            set(MKLtextHandle,'position',[MKLtextPos(1) limits(3)+(limits(4)-limits(3))/20 0]);
            
            GLWtextHandle=findobj(gcf,'string','GLW \rightarrow');
            GLWtextPos=get(findobj(gcf,'string','GLW \rightarrow'),'position');
            set(GLWtextHandle,'position',[limits(2)-(limits(2)-limits(1))/50 GLWtextPos(2) 0]);

            
            plotTxt={getINIValue('UCIT.ini','FrameTxt1'),getINIValue('UCIT.ini','FrameTxt2'),getINIValue('UCIT.ini','FrameTxt3'),...
                    getINIValue('UCIT.ini','FrameTxt4'),getINIValue('UCIT.ini','FrameTxt5'),getINIValue('UCIT.ini','FrameTxt6')};
            
            % Replace empty cells by a space
            for ii=1:length(plotTxt)
                if isempty(plotTxt{ii})
                    plotTxt{ii}=' ';
                end
            end
            
            if str2num(getINIValue('UCIT.ini','FrameOutput'))==1
                md_paper('a4l','wl',plotTxt);
            end
        end
        
        %Duinerosieplot
        if strfind(upper(get(findobj('tag','plotWindow'),'name')),'METHODE')
            % if strfind(upper(get(findobj('tag','plotWindow'),'name')),'DUINEROSIE')
            %Try to get limits from INI-file, else use 10% left and right from the
            %outermost black dotted lines and -20 to 20 as lower and upper limit
            limits=getINIValue('UCIT.ini','DuinErosieXLimits');
            if isempty(limits)
                lineX1=get(findobj(gcf,'linestyle',':','color',[0 0 0]),'xdata');
                limits1=[min([lineX1{:}])-0.1*abs(max([lineX1{:}])-min([lineX1{:}])) max([lineX1{:}])+0.1*abs(max([lineX1{:}])-min([lineX1{:}])) -25 25];
                lineX2=get(findobj(gcf,'linestyle','-','color',[1 0 0]),'xdata');
                limits2=[min([lineX2])-0.1*abs(max([lineX2])-min([lineX2])) max([lineX2])+0.1*abs(max([lineX2])-min([lineX2])) -25 25];
                if (limits1(2)-limits1(1))>(limits2(2)-limits2(1)) 
                    limits=limits1;
                else
                    limits=limits2;
                end
            else
                limits=str2num(limits);
            end
            %and set axis
            axis(limits);
            
            NAPtextHandle=findobj(gcf,'string','NAP \rightarrow');
            NAPtextPos=get(findobj(gcf,'string','NAP \rightarrow'),'position');
            set(NAPtextHandle,'position',[limits(2)-(limits(2)-limits(1))/50 NAPtextPos(2) 0]);
            
            if str2num(getINIValue('UCIT.ini','DeterministicMode'))==0
                RekenpeiltextHandle=findobj(gcf,'string','Rekenpeil \rightarrow');
                RekenpeiltextPos=get(findobj(gcf,'string','Rekenpeil \rightarrow'),'position');
                set(RekenpeiltextHandle,'position',[limits(2)-(limits(2)-limits(1))/50 RekenpeiltextPos(2) 0]);
            else 
                OntwerppeiltextHandle=findobj(gcf,'string','Ontwerppeil \rightarrow');
                OntwerppeiltextPos=get(findobj(gcf,'string','Ontwerppeil \rightarrow'),'position');
                set(OntwerppeiltextHandle,'position',[limits(2)-(limits(2)-limits(1))/50 OntwerppeiltextPos(2) 0]);
            end
            plotTxt={getINIValue('UCIT.ini','FrameTxt1'),getINIValue('UCIT.ini','FrameTxt2'),getINIValue('UCIT.ini','FrameTxt3'),...
                    getINIValue('UCIT.ini','FrameTxt4'),getINIValue('UCIT.ini','FrameTxt5'),getINIValue('UCIT.ini','FrameTxt6')};
            
            % Replace empty cells by a space
            for ii=1:length(plotTxt)
                if isempty(plotTxt{ii})
                    plotTxt{ii}=' ';
                end
            end
            
            if str2num(getINIValue('UCIT.ini','FrameOutput'))==1
                md_paper('a4l','wl',plotTxt);
            end
        end
        
        %JARKUS raaiplot
        if strfind(upper(get(findobj('tag','plotWindow'),'name')),'JARKUS VISUALISATIE')
            if str2num(getINIValue('UCIT.ini','FrameOutput'))==1
                md_paper('a4l','wl');
            end
        end
        
    case 'plotDurosta'
        %Durostaplot
        if str2num(getINIValue('UCIT.ini','FrameOutput'))==1
            md_paper('a4l','wl',plotTxt);
        end
        
end

try
    eval(getINIValue('UCIT.ini','plotUserFunction'));
end        

% Print WL|Delft Hydraulics watermark
UCIT_copyrightCurrentFigure

% print(gcf,'-djpeg90','-r600',['e:\temp_plot.jpg']); 