function S=ITHK_calculate_costs(S)

%% Input
tvec = S.kml.tvec;
t0 = S.kml.t0;
zgridrough = S.result.zgridRough;

%% Settings
budget(1) = 40*10^6;   %budget
C_GRO = 6000;       %costs per m groyne
C_REV = 5000;       %costs per m revetment
C_MEGA = 2;         %costs per m^3 mega nourishment
C_SUPP = 4;          %costs per m^3 'normal' nourishment

C_EXTENSION = 1000;%10000;     %revenues per m coastline extension per grid cell (w.r.t. initial coastline)
C_EROSION = 10000;       %costs per m coastline erosion per grid cell (w.r.t. initial coastline)

SCR = get(0,'ScreenSize'); % Screen resolution 

% IR = 1.025;              %interest rate
% DEBET = 1.025;           %debet interest

%% Plot initial budget
% figure('Units','normalized','PaperSize',[10 6.67],'Visible','off')
% set(gcf,'Position',[0.8 0.1 0.15 0.6])
% bar(1,budget(1)/10^6,'g');
% %bar(1,0);hold on; bar(2,0)
% text(1,budget(1)/10^6+10,num2str(budget(1)/10^6,'%3.1f'),'FontSize',36,'HorizontalAlignment','center','Color','g');
% %text(1,0+10,num2str(0),'FontSize',20,'HorizontalAlignment','center','Color','g');
% %text(1,0+10,num2str(0),'FontSize',20,'HorizontalAlignment','center','Color','g');
% ylim([-100 100])
% %set(gca,'Position',[0.8 0.1 0.15 0.6])
% set(gca,'color','none')
% axis off
% mkdir([S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\'],S.name);
% print(gcf,'-dpng',[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0) '.png'])
% I = imread([S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0) '.png']);
% imwrite(I,[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0) '.png'],'Transparency',[1,1,1])
% close(gcf)

   

figure('Units','normalized','PaperSize',[10 0.08*budget(1)/10^6],'Visible','off')
set(gcf,'Position',[0.8 0.1 0.15 0.003*budget(1)/10^6])
set(gcf,'PaperPosition',[0 0 10 0.08*budget(1)/10^6]);
bar(1,budget(1)/10^6,'g');
%bar(1,0);hold on; bar(2,0)
text(1,budget(1)/10^6+10,num2str(budget(1)/10^6,'%3.1f'),'FontSize',20,'HorizontalAlignment','center','Color','g');
%text(1,0+10,num2str(0),'FontSize',20,'HorizontalAlignment','center','Color','g');
%text(1,0+10,num2str(0),'FontSize',20,'HorizontalAlignment','center','Color','g');
ylim([min(0,budget(1)/10^6),max(0,budget(1)/10^6)]);
%set(gca,'Position',[0.8 0.1 0.15 0.6])
set(gca,'color','none')
axis off
set(gca,'Position',[0,0,1,1]);
mkdir([S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\'],S.name);
print(gcf,'-dpng',[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0) '.png'])
close all

 scaleFAC=1;
    figure('visible','off');
    set(gcf,'MenuBar','None');
    set(gcf,'Position',[50 50 100 30]);
    set(gcf,'PaperSize',[10,30]);
    set(gcf,'PaperPosition',[0 0 2*scaleFAC 0.6*scaleFAC]);
    h=text(0.95,0.5,num2str(budget(1)/10^6,'%3.1f'),'FontSize',20,'Color','g');axis off;
    set(h,'HorizontalAlignment','Right');
    set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
    print('-dpng',['plot1.png']);
    I = imread('plot1.png');
    %imwrite(I,['text.png'],'Alpha',(255-I(:,:,1))/255)
    imwrite(I,[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0) '_text.png'],'Transparency',[1 1 1])
    close all

% Y = 10;
% for Y=10:1:20
% set(gcf,'Position',[50 50 100 Y*2]);
% set(gcf,'PaperSize',[10,Y*0.2]);
% set(gcf,'PaperPosition',[0 0 10 Y*0.2]);
% h = bar(Y);
% set(gca,'Position',[0,0,1,1]);
% ylim([min(0,Y),max(0,Y)]);
% print('-dpng',['plot',num2str(Y),'.png']);
% end



figurl{1} = ['http://127.0.0.1:5000/images/' S.name '/budget_t=' num2str(t0) '.png'];
figtexturl{1} = ['http://127.0.0.1:5000/images/' S.name '/budget_t=' num2str(t0) '_text.png'];
budgetstring = '';
budgettextstring = '';
time    = datenum(t0,1,1);
timeSpan = KML_timespan('timeIn',time,'timeOut',time+364);

budgetstring = [budgetstring sprintf([...
    '  <ScreenOverlay>\n'...
    '  <name>budgetbar</name>\n'...
    '  <visibility>1</visibility>\n'...
    '  %s\n'...
    '  <Icon><href>%s</href></Icon>\n'...
    '   <overlayXY x="1" y="0" xunits="fraction" yunits="fraction"/>\n'...
    '   <screenXY  x="0.10" y="0.1" xunits="fraction" yunits="fraction"/>\n'...
    '   <size x="0.05" y="0" xunits="fraction" yunits="fraction"/>\n'... 
    '  </ScreenOverlay>\n'],...
    timeSpan,...
    figurl{1})];

budgettextstring = [budgettextstring sprintf([...
    '  <ScreenOverlay>\n'...
    '  <name>budgetbar</name>\n'...
    '  <visibility>1</visibility>\n'...
    '  %s\n'...
    '  <Icon><href>%s</href></Icon>\n'...
    '   <overlayXY x="1" y="0" xunits="fraction" yunits="fraction"/>\n'...
    '   <screenXY  x="0.05" y="0.1" xunits="fraction" yunits="fraction"/>\n'...
    '   <size x="0.05" y="0" xunits="fraction" yunits="fraction"/>\n'... 
    '  </ScreenOverlay>\n'],...
    timeSpan,...
    figtexturl{1})];


%% Loop through years
for ii=1:length(tvec)-1
    time    = datenum((ii+t0),1,1);
    timeSpan = KML_timespan('timeIn',time,'timeOut',time+364);
    if  isfield(S,'nourishment')
        for jj = 1:length(S.nourishment)
            if  strcmp(S.nourishment(jj).category,'mega')==1
                if  tvec(ii)==S.implementation
                    T_supp(jj) = C_MEGA*S.nourishment(jj).magnitude;
                else
                    T_supp(jj) = 0;
                end
            else
                if  tvec(ii)>=S.implementation
                    T_supp(jj) = C_SUPP*S.nourishment(jj).magnitude;
                else
                    T_supp(jj) = 0;
                end
            end
        end
    else 
        T_supp = 0;
    end
    if isfield(S,'groyne')
        for jj = 1:length(S.groyne)
            if  tvec(ii)==S.implementation
                T_gro(jj) = C_GRO*S.groyne(jj).length;
            else
                T_gro(jj) = 0;
            end
        end
    else
        T_gro = 0;
    end
    if isfield(S,'revetment')
        for jj = 1:length(S.revetment)
            if  tvec(ii)==S.implementation
                T_rev(jj) = C_REV*S.revetment(jj).length;
            else
                T_rev(jj) = 0;
            end
        end
    else
        T_rev = 0;
    end
    ids_CST = find(zgridrough(ii,10:29)<-10);
    ids_IJM = find(zgridrough(ii,30:33)>40);
    if  length(ids_CST)>3
        T_coast=(length(ids_CST)-3)*5*10^6/2.5;
    else
        T_coast=-2*10^6;
    end
    if  length(ids_IJM)>1
        T_IJM=2*10^6;
    else
        T_IJM=-1*10^6;
    end
%     for kk = 10:29%33
%         if      (zgridrough(ii,kk))<0
%                 T_coast(kk) = -zgridrough(ii,kk)*C_EROSION*IR^ii;
%         elseif (zgridrough(ii,kk))>0
%                 T_coast(kk) = -zgridrough(ii,kk)*C_EXTENSION*IR^ii;
%         else
%                 T_coast(kk) = 0;
%         end
%     end
    
    budget(ii+1) = budget(ii)-(sum(T_supp)+sum(T_gro)+sum(T_rev)+sum(T_coast)+sum(T_IJM));
    if  max(T_gro) == 0 && max(T_rev) == 0 && max(T_supp) == 0
        budget(ii+1) = budget(ii+1)+1*10^6;
%     elseif budget(ii)<0
%         budget(ii+1) = budget(ii+1)-1*10^6;%*DEBET^ii;
    end
    measures(ii+1)=sum(T_supp)+sum(T_gro)+sum(T_rev);
    coast(ii+1)=sum(T_coast);
    ijm(ii+1)=T_IJM;
    
%    figure('Units','normalized','PaperSize',[10 6.67],'Visible','off')
    figure('Units','normalized','PaperSize',[10 0.08*(abs(budget(ii+1))/10^6+1)],'Visible','off')
    set(gcf,'Position',[0.8 0.1 0.15 0.003*(abs(budget(ii+1))/10^6+1)])
    set(gcf,'PaperPosition',[0 0 10 0.08*(abs(budget(ii+1))/10^6+1)]);
%   set(gcf,'Position',[0.8 0.1 0.15 0.6])
    if budget(ii+1)>0
        bar(1,budget(ii+1)/10^6,'g');
        text(1,budget(ii+1)/10^6+10,num2str(budget(ii+1)/10^6,'%3.1f'),'FontSize',36,'HorizontalAlignment','center','Color','g');
        OFFSET(ii+1) = 0;
        rot{ii}='<rotation>0</rotation>';
    else
        bar(1,budget(ii+1)/10^6,'r');
        text(1,budget(ii+1)/10^6-10,num2str(budget(ii+1)/10^6,'%3.1f'),'FontSize',36,'HorizontalAlignment','center','Color','r');
        OFFSET(ii+1) = 0.03*(budget(ii+1)/10^6/2.54)*150/SCR(4);
        rot{ii}='<rotation>180</rotation>';
    end
%    ylim([-100 100])
    ylim([min(0,budget(ii+1)/10^6+1),max(0,budget(ii+1)/10^6)+1]);
    axis off
    set(gca,'Position',[0,0,1,1]);
    print(gcf,'-dpng',[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0+ii) '.png']);
    I = imread([S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0+ii) '.png']);
    imwrite(I,[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0+ii) '.png'],'Transparency',[1,1,1])
    close all
    
    scaleFAC=1;
    figure('visible','off');
    set(gcf,'MenuBar','None');
    set(gcf,'Position',[50 50 100 30]);
    set(gcf,'PaperSize',[10,30]);
    set(gcf,'PaperPosition',[0 0 2*scaleFAC 0.6*scaleFAC]);
    if budget(ii+1)>0
        h=text(0.95,0.5,num2str(budget(ii+1)/10^6,'%3.1f'),'FontSize',20,'Color','g');axis off;
    else
        h=text(0.95,0.5,num2str(budget(ii+1)/10^6,'%3.1f'),'FontSize',20,'Color','r');axis off;
    end
    set(h,'HorizontalAlignment','Right');
    set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
    print('-dpng',['plot1.png']);
    I = imread('plot1.png');
    %imwrite(I,['text.png'],'Alpha',(255-I(:,:,1))/255)
    imwrite(I,[S.settings.baseDir '\ITviewer\openearthtest\openearthtest\public\images\' S.name '\budget_t=' num2str(t0+ii) '_text.png'],'Transparency',[1 1 1])
    close all
    
    % Put in budget kml string
    figurl{ii} = ['http://127.0.0.1:5000/images/' S.name '/budget_t=' num2str(t0+ii) '.png'];
    texturl{ii} = ['http://127.0.0.1:5000/images/' S.name '/budget_t=' num2str(t0+ii) '_text.png'];
    offsetstr{ii} = ['<screenXY x="0.9" y="' num2str(0.2+OFFSET(ii+1)) '" xunits="fraction" yunits="fraction"/>'];
    budgetstring = [budgetstring sprintf([...
    '  <ScreenOverlay>\n'...
    '  <name>budgetbar</name>\n'...
    '  <visibility>1</visibility>\n'...
    '  %s\n'...
    '  <Icon><href>%s</href></Icon>\n'...
    '   <overlayXY x="1" y="0" xunits="fraction" yunits="fraction"/>\n'...
    '   <screenXY x="0.10" y="0.1" xunits="fraction" yunits="fraction"/>\n'...
    '   <size x="0.05" y="0" xunits="fraction" yunits="fraction"/>\n'... 
    '   <rotationXY x="0.5" y="0" xunits="fraction" yunits="fraction"/>\n'... 
    '   %s\n'...
    '  </ScreenOverlay>\n'],...
    timeSpan,...
    figurl{ii},...
    rot{ii})];

    budgettextstring = [budgettextstring sprintf([...
    '  <ScreenOverlay>\n'...
    '  <name>budgetbar</name>\n'...
    '  <visibility>1</visibility>\n'...
    '  %s\n'...
    '  <Icon><href>%s</href></Icon>\n'...
    '   <overlayXY x="1" y="0" xunits="fraction" yunits="fraction"/>\n'...
    '   <screenXY x="0.05" y="0.1" xunits="fraction" yunits="fraction"/>\n'...
    '   <size x="0.05" y="0" xunits="fraction" yunits="fraction"/>\n'... 
    '  </ScreenOverlay>\n'],...
    timeSpan,...
    texturl{ii})];
    
end
S.budget=budget;
S.output = [S.output budgetstring budgettextstring];
%S.kml.budgetstring = budgetstring;
S.coast=coast;
S.ijm=ijm;
S.meas=measures;
% S.T_coast_neg = T_coast_neg;
% S.T_coast_pos = T_coast_pos;    
    

        
        