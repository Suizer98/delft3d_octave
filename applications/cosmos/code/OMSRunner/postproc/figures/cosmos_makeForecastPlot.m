function cosmos_makeForecastPlot(hm,m)

% Makes map plots and KMZs

t=0;

name='';

try
    
    model=hm.models(m);
    dr=model.dir;
    if model.forecastplot.plot
        
        try
            [weather] = cosmos_urlReadWeather(model.forecastplot.weatherstation);
        end
        
        settings.thin = model.forecastplot.thinning;
        settings.scal = model.forecastplot.scalefactor;
        settings.xlim = model.forecastplot.xlims;
        settings.ylim = model.forecastplot.ylims;
        settings.clim = model.forecastplot.clims;
        settings.kmaxis = model.forecastplot.kmaxis;
        
        name=model.forecastplot.name;
        
        fname=[model.archiveDir hm.cycStr filesep 'maps' filesep 'vel.mat'];
        s(1).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'maps' filesep 'bedlevel.mat'];
        s(2).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'maps' filesep 'waterdepth.mat'];
        s(3).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'wl.' model.forecastplot.wlstation '.mat'];
        s(4).data=load(fname);
        
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'hs.' model.forecastplot.wavestation '.mat'];
        wav(1).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'tp.' model.forecastplot.wavestation '.mat'];
        wav(2).data=load(fname);
        fname=[model.archiveDir hm.cycStr filesep 'timeseries' filesep 'wavdir.' model.forecastplot.wavestation '.mat'];
        wav(3).data=load(fname);
        
        try
            fname=[model.archiveDir hm.cycStr filesep 'maps' filesep 'windvel.mat'];
            wnd(1).data=load(fname);
        end
        
        s(1).data.U(isnan(s(1).data.U)) = 0;
        s(1).data.V(isnan(s(1).data.V)) = 0;
        
        s(3).data.Val(s(3).data.Val>0.2) = NaN;
        s(3).data.Val(s(3).data.Val<=0.2) = -0.1;
        
        if exist([dr 'data' filesep model.forecastplot.ldb '.ldb'],'file')
            ldb=landboundary('read',[dr 'data' filesep model.forecastplot.ldb '.ldb']);
        end
        
        AvailableTimes=s(1).data.Time;
        dt=86400*(AvailableTimes(2)-AvailableTimes(1));
        n3=round(model.forecastplot.timeStep/dt);
        n3=max(n3,1);
        nt=length(s(1).data.Time);
        
        % Time shift
        timeShift=model.timeShift/24;

        tel = 0;
        
        for it=1:n3:nt
            
            timnow = s(1).data.Time(it);
            timnowCET = timnow + timeShift;
            
            input.scrsz= get(0, 'ScreenSize');               % Set plot figure on full screen
            figure('Visible','Off','Position', [input.scrsz]);
            hold on; set(gcf,'defaultaxesfontsize',8)
            
            thin = settings.thin;
            scal = settings.scal;
            mag  = squeeze((s(1).data.U(it,:,:).^2 + s(1).data.V(it,:,:).^2).^0.5);
            
            try %get wave forecast
                id = find(round(timnow*24*60)==round(wav(1).data.Time*24*60));
                hsnow = num2str(wav(1).data.Val(id),'%2.1f');
                tpnow = num2str(wav(2).data.Val(id),'%2.0f');
                wavdirnow = num2str(wav(3).data.Val(id),'%3.0f');
                
                wavdir = str2num(wavdirnow);
                
                if wavdir >= 0 && wavdir < 22.5
                    wavid = 3;
                elseif wavdir >= 22.5 && wavdir < 67.5
                    wavid = 7;
                elseif wavdir >= 67.5 && wavdir < 112.5
                    wavid = 4;
                elseif wavdir >= 112.5 && wavdir < 157.5
                    wavid = 8;
                elseif wavdir >= 157.5 && wavdir < 202.5
                    wavid = 1;
                elseif wavdir >= 202.5 && wavdir < 247.5
                    wavid = 5;
                elseif wavdir >= 247.5 && wavdir < 292.5
                    wavid = 2;
                elseif wavdir >= 292.5 && wavdir < 337.5
                    wavid = 6;
                elseif wavdir >= 337.5 && wavdir <= 360
                    wavid = 3;
                end
                
                wavIconFile = [hm.dataDir 'icons' filesep 'wind' filesep 'wind-arrows\wind-dart-white\256x256\wind-dart-white-' num2str(wavid) '.png'];
                try
                    imWave = imread(wavIconFile,'png','BackgroundColor',[1 1 1]);
                catch
                    imWave = [];
                end
                
            catch
                hsnow = 'n/a';
                tpnow = 'n/a';
                wavdirnow = 'n/a';
                imWave = [];
            end
            
            try %get wind forecast
                windIds = find(timnow>=wnd(1).data.Time);
                %                 id = find(round(timnow*24)==round(wnd(1).data.Time*24));
                id = windIds(end);
                wndUnow = wnd(1).data.U(id,model.forecastplot.windstation(1),model.forecastplot.windstation(2));
                wndVnow = wnd(1).data.V(id,model.forecastplot.windstation(1),model.forecastplot.windstation(2));
                windnow = num2str(sqrt(wndUnow.^2 + wndVnow.^2),'%2.0f');
                winddirnow = num2str(mod(270 - rad2deg(atan2(wndVnow,wndUnow)),360),'%2.0f');
                winddir = str2num(winddirnow);
                
                if winddir >= 0 && winddir < 22.5
                    windid = 3;
                elseif winddir >= 22.5 && winddir < 67.5
                    windid = 7;
                elseif winddir >= 67.5 && winddir < 112.5
                    windid = 4;
                elseif winddir >= 112.5 && winddir < 157.5
                    windid = 8;
                elseif winddir >= 157.5 && winddir < 202.5
                    windid = 1;
                elseif winddir >= 202.5 && winddir < 247.5
                    windid = 5;
                elseif winddir >= 247.5 && winddir < 292.5
                    windid = 2;
                elseif winddir >= 292.5 && winddir < 337.5
                    windid = 6;
                elseif winddir >= 337.5 && winddir <= 360
                    windid = 3;
                end
                
                bftscal = [0,1,2,3,4,5,6,7,8,9,10,11,12;
                    0,0.2,1.5,3.3,5.4,7.9,10.7,13.8,17.1,20.7,24.4,28.4,32.6]';
                
                windbft = num2str(floor(interp1(bftscal(:,2),bftscal(:,1),str2num(windnow))));
                
                windIconFile = [hm.dataDir 'icons' filesep 'wind' filesep 'wind-arrows\wind-disc-transparent-background\256x256\wind-disc1-trans-' num2str(windid) '_w.png'];
                try
                    imWind = imread(windIconFile,'png','BackgroundColor',[1 1 1]);
                catch
                    imWind = [];
                end
                
            catch
                windnow = 'n/a';
                winddirnow = 'n/a';
                windbft = 'n/a';
                imWind = [];
            end
            
            if ~exist('wtempnow','var')
                try %get water temperature
                    startT = datestr(round((now-1)*24*6)/24/6,'yyyymmddHHMM');
                    endT = datestr(round((now)*24*6)/24/6,'yyyymmddHHMM');
                    [t, dat] = GetMatroosSeries('water_temperature','observed',model.forecastplot.waterstation,startT,endT);
                    wtempnow = num2str(mean(dat),'%2.0f');
                catch
                    wtempnow = 'n/a';
                end
            end
            
            try %get weather forecast
                weatherIds = find(timnowCET>=weather(:,1));
                weatherId = weatherIds(end);
                atempnow = num2str(weather(weatherId,2),'%2.0f');
                
                try
                    imWthr = imread([hm.dataDir 'icons' filesep 'weather' filesep num2str(weather(weatherId,3),'%2.2d') '.png'],'png','BackgroundColor',[1 1 1]);
                catch
                    imWthr = [];
                end
            catch
                atempnow = 'n/a';
                imWthr = [];
            end
            
            % model plot
            
            ax1 = gca; hold on;
            pcolor(s(1).data.X,s(1).data.Y,mag);shading interp;axis equal
            
            velX = s(1).data.X(1:thin:end,1:thin:end);
            velY = s(1).data.Y(1:thin:end,1:thin:end);
            velXComp = squeeze(s(1).data.U(it,1:thin:end,1:thin:end));
            velYComp = squeeze(s(1).data.V(it,1:thin:end,1:thin:end));
            
            remID = ~(velXComp == 0 & velYComp == 0);
            
            quiver(velX(remID),velY(remID),scal*(velXComp(remID)),scal*(velYComp(remID)),0,'color',[1 1 1])
            
            blank = squeeze(s(3).data.Val(it,:,:));
            blank(mag>0.05) = NaN;
            pcolor(s(3).data.X,s(3).data.Y,blank);shading interp;axis equal
            
            try
                filledLDB(ldb,[1 1 0.8],[1 1 0.8],10,0);
            end
            
            [cb,h] = contour(s(2).data.X,s(2).data.Y,squeeze(s(2).data.Val),[-16:2:2]);
            set(h,'linecolor',[0.8 0.8 0.8]);
            
            clim([-0.1 settings.clim(2)])
            colormap([repmat([1 1 0.8],floor(0.1/(settings.clim(2)/length(jet))),1); jet])
            cb = colorbar;
            set(cb,'ylim',[0 settings.clim(2)]);
            
            set(gca,'xlim',settings.xlim)
            set(gca,'ylim',settings.ylim)
            kmAxis(gca,settings.kmaxis)
            
            % axes 2
            ax2 = axes('position',[0.68 0.30 0.12 0.1]);
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.8,'Wind','fontsize',7,'fontweight','bold')
            text(0.1,0.6,['Richting: ' winddirnow '^oN'],'fontsize',7)
            text(0.1,0.4,['Snelheid: ' windnow 'm/s'],'fontsize',7)
            %            text(0.1,0.2,'Kracht: 4 bft','fontsize',7)
            
            % axes 2a
            ax2a = axes('position',[ 0.7561 0.2995  0.0424268  0.06719]);
            %             ax2a = axes('position',[0.763 0.309 0.0334 0.0489]);
            axis equal;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            %             arrow([0 0],[0.93 1],'Width',1,'LineWidth',1.5,'length',15,'faceColor','b','edgecolor','b')
            image(imWind)
            text( mean(get(gca,'xlim')),mean(get(gca,'ylim')),windbft,'fontsize',9,'horizontalAlignment','center','fontweight','bold')
            box off;
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            set(gca,'ytick',[])
            set(gca,'xtick',[])
            
            % axes 3
            ax3 = axes('position',[0.80 0.30 0.12 0.1]);
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.5,0.6,strrep(strrep(datestr(timnowCET,1),'-',' '),'May','Mei'),'fontsize',12,'HorizontalAlignment','center')
            text(0.5,0.4,[datestr(timnowCET,15) 'u'],'fontsize',12,'HorizontalAlignment','center')
            
            % axes 4
            ax4 = axes('position',[0.68 0.20 0.12 0.1]); hold on;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.8,'Weer','fontsize',7,'fontweight','bold')
            text(0.1,0.6,['Luchttemp.: ' atempnow '^o'],'fontsize',7)
            text(0.1,0.4,['Watertemp.: ' wtempnow '^o'],'fontsize',7)
            %             text(0.1,0.2,'Bewolking: geen','fontsize',7)
            
            % axes 4a
            ax2a = axes('position',[0.763 0.209 0.0314 0.0439]);
            axis equal;
            image(imWthr)
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box off;
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            
            % axes 5
            ax5 = axes('position',[0.80 0.20 0.12 0.1]);
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            text(0.1,0.8,'Golven','fontsize',7,'fontweight','bold')
            text(0.1,0.6,['Richting: ' wavdirnow '^oN'],'fontsize',7)
            text(0.1,0.4,['Hoogte: ' hsnow 'm'],'fontsize',7)
            text(0.1,0.2,['Periode: ' tpnow 's'],'fontsize',7)
            
            % axes 5a
            ax5a = axes('position',[0.87380   0.209        0.04059     0.05647]);
            %             ax5a = axes('position',[0.7611 0.2995  0.0424268  0.06719]);
            axis equal;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            %             arrow([0 0],[1 1],'Width',1,'LineWidth',1.5,'length',15,'faceColor','g','edgecolor','g')
            image(imWave)
            box off;
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            set(gca,'ytick',[])
            set(gca,'xtick',[])
            
            % axes 6
            ax6 = axes('position',[0.68 0.075 0.24 0.125]);
            set(gca,'xtick',[]);set(gca,'ytick',[])
            text(0.05,0.85,'Waterstand','fontsize',7,'fontweight','bold')
            box on;
            
            % axes 7
            ax7 = axes('position',[0.695 0.10 0.21 0.07]);hold on;
            set(gca,'xtick',[]);set(gca,'ytick',[])
            box on;
            plot(s(4).data.Time+timeShift,s(4).data.Val,'linewidth',0.7);
            set(gca,'xlim',[min(s(1).data.Time+timeShift) max(s(1).data.Time+timeShift)])
            set(gca,'xtick',[min(s(1).data.Time):0.5:max(s(1).data.Time)])
            datetick('x','keeplimits','keepticks')
            tcks = get(gca,'xticklabel');
            tcks(2:2:end,:) = ' ';
            set(gca,'xticklabel',tcks);
            ylim([-1.5 1.5]);
            set(gca,'ytick',[-1 0 1])
            grid on
            plot([timnowCET timnowCET],get(gca,'ylim'),'r','linewidth',1)
            
            
            set(cb,'position',[0.8887    0.4515    0.0159    0.2847])
            set(get(cb,'title'),'string','Stroomsnelheid (m/s)','fontsize',7)
            set(get(cb,'title'),'rotation',90)
            set(get(cb,'title'),'position',[-3.134 0.789 9.160])
            set(ax1,'fontsize',7)
            set(ax7,'fontsize',7)
            
            set(ax1,'position',[0.0104    0.0382    0.9882    0.9558])
            set(gcf,'paperSize',[29.68  18.58 ])
            set(gcf,'paperPosition',[0.6345    0.6345   28.4110   17.3110])
            set(gcf,'color','w')
            set(gcf,'renderer','zbuf')
            
            if ~exist([dr 'lastrun' filesep 'figures' filesep 'forecast'],'dir')
                mkdir([dr 'lastrun' filesep 'figures'],'forecast')
            end
            figname=[dr 'lastrun' filesep 'figures' filesep 'forecast' filesep name '_' datestr(timnowCET,'yyyymmddHH') '.png'];
            print(gcf,'-dpng','-r400',figname);
            
            close(gcf)
            
            if (timnowCET-floor(timnowCET)) >= 0.25 && (timnowCET-floor(timnowCET)) <= 20/24 % only hours between 6am and 8pm on website
                if (timnowCET-now) >= -0.25 % no past forecasts on website
                    
                    tel = tel + 1;
                    
                    fc.name.value        = name;
                    fc.name.type         = 'char';
                    fc.numoffields.value = tel;
                    fc.numoffields.type  = 'int';
                    fc.interval.value    = model.forecastplot.timeStep;
                    fc.interval.type     = 'int';
                    
                    fc.timepoints(tel).timepoint.timestr.value = lower(strrep(strrep(strrep(datestr(timnowCET,'dd mmm HH:MM'),'May','Mei'),'Mar','Mrt'),'Oct','Okt'));
                    fc.timepoints(tel).timepoint.timestr.type  = 'char';
                    fc.timepoints(tel).timepoint.png.value      = [name '/' name '_' datestr(timnowCET,'yyyymmddHH') '.png'];
                    fc.timepoints(tel).timepoint.png.type      = 'char';
                    fc.timepoints(tel).timepoint.id.value      = datestr(timnowCET,'yyyymmddHH');
                    fc.timepoints(tel).timepoint.id.type       = 'int';
                end
            end
        end
        
        struct2xml([dr 'lastrun' filesep 'figures' filesep 'forecast' filesep name '.xml'],fc);
    end
    
catch
    
    WriteErrorLogFile(hm,['Something went wrong with generating map figures of ' name ' - ' model.name]);
    
end

