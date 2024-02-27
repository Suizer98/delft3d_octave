function [KMLcosts]=ITHK_KMLcostsbar(sens)
%function [KMLcosts]=ITHK_KMLcostsbar(sens)
%
% ITHK_KMLcostsbar creates the kmltext for the costsbar
%

global S

tvec            = S.PP(sens).settings.tvec;tvec(length(tvec)+1)=round(2*tvec(end)-tvec(end-1));
t0              = S.PP(sens).settings.t0;
zgridrough      = S.PP(sens).coast.zgridRough;
directcosts     = S.PP(sens).TTmapping.costscum;
rotationtxt     = '   <rotationXY x="0.5" y="0" xunits="fraction" yunits="fraction"/>';
SCR             = get(0,'ScreenSize');
colour          = {'r','g'};
extraval        = [10,-10];
rotval          = [0,180];
KMLcostsbar     = [];
KMLcoststxt     = [];
if ~exist([S.settings.outputdir,'output'],'dir')
    mkdir(S.settings.outputdir,'output');
end

%% Loop through years
for ii=1:20%length(tvec)-1
    %% data
    time1           = datenum(tvec(ii)+t0,1,1);
    time2           = datenum(tvec(ii+1)+t0-1/365/24/60/60,1,1);
    timeSpan        = ITHK_KMLtimespan('timeIn',time1,'timeOut',time2);
    
    %% formatting data
    barurl{ii}      = [S.settings.outputdir,'output',filesep,'budgetbar_t=',num2str(t0+tvec(ii),'%1.0f'),'.png'];     %['http://127.0.0.1:5000/images/' S.name '/budget_t=' num2str(t0+ii) '.png'];
    txturl{ii}      = [S.settings.outputdir,'output',filesep,'budgettxt_t=',num2str(t0+tvec(ii),'%1.0f'),'.png'];      %['http://127.0.0.1:5000/images/' S.name '/budget_t=' num2str(t0+ii) '_text.png'];
    %offsetstr{ii}  = ['<screenXY x="0.9" y="' num2str(0.2+OFFSET(ii)) '" xunits="fraction" yunits="fraction"/>'];
    offsetval       = [0,0.03*(directcosts(ii)/10^6/2.54)*150/SCR(4)];
    idSIGN          = 1;   if directcosts(ii)<0;idSIGN=2;end
       
    %% PLOT COSTS BAR
    figure('Units','normalized','PaperSize',[10 0.08*(abs(directcosts(ii))/10^6+1)],'Visible','off')
    set(gcf,'Position',[0.8 0.1 0.15 0.003*(abs(directcosts(ii))/10^6)],'PaperPosition',[0 0 10 0.08*(abs(directcosts(ii))/10^6)])
    %% create bar and txt
    h1=bar(1,directcosts(ii)/10^6,colour{idSIGN});
    h2=text(1,directcosts(ii)/10^6+extraval(idSIGN),num2str(directcosts(ii)/10^6,'%3.1f'),'FontSize',36,'HorizontalAlignment','center','Color',colour{idSIGN});

    %OFFSET(ii) = offsetval(idSIGN);
    ylim([min(0,directcosts(ii)/10^6+1),max(0,directcosts(ii)/10^6)+1]);axis off;set(gca,'Position',[0,0,1,1]);
    if ii==1;set(gca,'color','none');end
    print(gcf,'-dpng',barurl{ii});
    I =imread(barurl{ii});
    imwrite(I,barurl{ii},'Transparency',[1,1,1]);close all;
    close all;
    
    %% PLOT COSTS TEXT
    scaleFAC=1;
    figure('visible','off');
    set(gcf,'MenuBar','None','Position',[50 50 100 30],'PaperSize',[10,30],'PaperPosition',[0 0 2*scaleFAC 0.6*scaleFAC]);
    h3=text(0.95,0.5,num2str(directcosts(ii)/10^6,'%3.1f'),'FontSize',20,'HorizontalAlignment','Right','Color',colour{idSIGN});
    axis off;set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
    print(gcf,'-dpng',txturl{ii});
    I =imread(txturl{ii});
    imwrite(I,txturl{ii},'Transparency',[1 1 1]);close all;
    %imwrite(I,['text.png'],'Alpha',(255-I(:,:,1))/255)
    
    % Put in directcosts kml string
    KMLcostsbar    = [KMLcostsbar,KMLstring(timeSpan,[0.93,0.05],barurl{ii},rotationtxt2)];
    KMLcoststxt    = [KMLcoststxt,KMLstring(timeSpan,[0.88-0.01*(length(plotnumber)-ii)+dx,0.01],txturl{ii},'')];
end

KMLcosts = [KMLcostsbar,KMLcoststxt];

end

%% SUB-function 1: 
function KMLstring=KMLstring(timeSpan,screenxy,magnitude,figureURL,rotationtxt)
    % screenxy = 0.05 or 0.1
    if nargin<5
        %rotationtxt = '   <rotationXY x="0.5" y="0" xunits="fraction" yunits="fraction"/>\n';
        rotationtxt = '';
    end
    
    KMLstring = sprintf([...
        '  <ScreenOverlay>\n'...
        '  <name>costsbar</name>\n'...
        '  <visibility>1</visibility>\n'...
        '  %s\n'...
        '  <Icon><href>%s</href></Icon>\n'...
        '   <overlayXY x="1" y="0" xunits="fraction" yunits="fraction"/>\n'...
        '   <screenXY  x="%3.3f" y="%3.2f" xunits="fraction" yunits="fraction"/>\n'...
        '   <size x="0.05" y="0" xunits="fraction" yunits="fraction"/>\n'... 
        '   %s'...
        '  </ScreenOverlay>\n'],...
        timeSpan, ...
        figureURL, ...
        screenxy(1),screenxy(2), ...
        rotationtxt);
end
