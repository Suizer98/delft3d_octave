function [KMLcosts]=ITHK_KMLcostsbar(sens,directcosts)
%function [KMLcosts]=ITHK_KMLcostsbar(sens,directcosts)
%
% ITHK_KMLcostsbar creates the kmltext for the costsbar
%

global S

tvec            = S.PP(sens).settings.tvec;
tvec(length(tvec)+1)=round(2*tvec(end)-tvec(end-1));
t0              = S.PP(sens).settings.t0;
zgridrough      = S.PP(sens).coast.zgridRough;
%directcosts     = -S.PP(sens).TTmapping.costs.direct.costs_total;
SCR             = get(0,'ScreenSize');
rotval          = [0,0];%[0,180];
KMLcostsbar     = [];
KMLcoststxt     = [];

%% Loop through years
for ii=1:length(tvec)-1
    %% data
    time1           = datenum(tvec(ii)+t0,1,1);
    time2           = datenum(tvec(ii+1)+t0-1/365/24/60/60,1,1);
    timeSpan        = ITHK_KMLtimespan('timeIn',time1,'timeOut',time2);
    
    %% formatting data
    %idSIGN          = 2;
    idSIGN         = 1;   if directcosts(ii)<0;idSIGN=2;end

    %% Generate KMLtext for bars
    barurl          = {[S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\costsbar1.png'],...
                       [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\costsbar2.png']};
    rotationtxt2    = ['   <rotationXY x="0.5" y="0" xunits="fraction" yunits="fraction"/>',char(13),...
                       '   <rotation>',num2str(rotval(idSIGN),'%1.0f'),'</rotation>',char(13)];
    magnitude       = abs(directcosts(ii)) / (3*max(abs(directcosts)));
    KMLcostsbar     = [KMLcostsbar,KMLstring(timeSpan,[0.93,0.10],[0.04,magnitude],barurl{idSIGN},rotationtxt2)];
    plotnumber      = [sprintf('%c',8364),num2str(directcosts(ii)/10^6,'%1.1f'),'M'];
    
    %% Generate KMLtext for numbers
    for ii=1:length(plotnumber)
        magnitude   = [0.01,0.03];
        numurl      = [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\number',plotnumber(ii),'.png'];
        dx=0;
        if strcmp(plotnumber(ii),'.');
            magnitude(1) = magnitude(1)/2;
            numurl  = [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\numberdot.png'];
        end
        if strcmp(plotnumber(ii),'-');
            magnitude(1) = 2*magnitude(1)/3;
            numurl  = [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\numberminus.png'];
        end
        if strcmp(plotnumber(ii),sprintf('%c',8364));
            dx=0.01/3;
            numurl  = [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\numbereuro.png'];
        end
        if ii>=length(plotnumber)-2;dx=-0.005;end
        if strcmp(plotnumber(ii),'M');
            magnitude(1) = magnitude(1)*2;dx=0.005;
            numurl  = [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\numbermillion.png'];
        end
        KMLcoststxt = [KMLcoststxt,KMLstring(timeSpan,[0.88-0.01*(length(plotnumber)-ii)+dx,0.10],magnitude,numurl,'')];
    end
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
    
    if isstr(timeSpan) && isstr(rotationtxt) && isstr(figureURL) && length(screenxy)==2 && length(magnitude)==2
    KMLstring = sprintf([...
        '  <ScreenOverlay>\n' ...
        '  <name>costsbar</name>\n' ...
        '  <visibility>1</visibility>\n' ...
        '  %s\n'...
        '  <color>bfffffff</color>\n' ...
        '  <Icon><href>%s</href></Icon>\n' ...
        '   <overlayXY x="1" y="0" xunits="fraction" yunits="fraction"/>\n' ...
        '   <screenXY  x="%3.3f" y="%3.2f" xunits="fraction" yunits="fraction"/>\n' ...
        '   <size x="%4.4f" y="%4.4f" xunits="fraction" yunits="fraction"/>\n' ... 
        '   %s' ...
        '  </ScreenOverlay>\n'], ...
        timeSpan, ...
        figureURL, ...
        screenxy(1),screenxy(2), ...
        magnitude(1),magnitude(2), ...
        rotationtxt);
    else
        fprintf('Warning : Input format in ''ITHK_KMLcostsbar.m'' not correctly specified!\n')
    end
end
