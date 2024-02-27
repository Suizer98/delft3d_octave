function dbPlotDuneErosion(varargin)

persistent dbfig cnt

dbstopcr=false;
dt=0.4;
points=[];
%% retrieve function name and line of calling function
dba=dbstack;
if length(dba)>1
    dbfnc=dba(2).name;
else
    return
end

%% initiate debug figure if not present
dbfig=findobj('Tag','dbfig');
if isempty(dbfig) || (nargin>0 && strcmp(varargin{1},'new'))
    cnt = 0;
    set(get(findobj('Tag','dbaxes'),'Children'),'Tag','');
    set(get(dbfig,'Children'),'Tag','');
    set(dbfig,'Tag','');
    set(findobj('Tag','dbaxes'),'Tag','');
    dbfig=figure('NumberTitle','off','Name','Debug figure','Tag','dbfig','WindowStyle','docked');
    dbax=axes('Parent',dbfig,'Tag','dbaxes');
    xlabel('Cross shore distance (x [m])');
    ylabel('Vertical level [m]');
    box on
    hold on
    grid on
else
    dbax=findobj('Tag','dbaxes');
end
cnt = cnt + 1;

%% pass variables from calling workspace to this workspace
% This enables use of the variables as if it were programmed in the calling
% function. Variables are passed through the userdata of the debug plot
% figure.

evalin('caller','dbs=whos;');
evalin('caller','for idb=1:length(dbs), dbs(idb).content=eval(dbs(idb).name); end');
evalin('caller','set(findobj(''Tag'',''dbfig''),''UserData'',dbs);');

dbs=get(dbfig,'UserData');
for dbvari=1:length(dbs)
    if ~strcmp(dbs(dbvari).name,'dbs')
        eval([dbs(dbvari).name '=dbs(dbvari).content;']);
    end
end
set(dbfig,'UserData',[]);

%% plot initial conditions if not present and if in variables
dbinitprofile=findobj('Tag','IniProfile');
dbwl=findobj('Tag','WL');
if isempty(dbinitprofile) && exist('xInitial','var') && exist('xInitial','var') && numel(xInitial)==numel(zInitial)
    plot(xInitial,zInitial,'Color',[255 215 140]/255,'LineWidth',2,'Parent',dbax,'Tag','IniProfile');
end
if isempty(dbwl) && exist('WL_t','var')
    plot(xlim,[WL_t WL_t],'Color',[74 114 255]/255,'LineStyle','--','Parent',dbax,'Tag','WL');
end

%% plot debuig information (depending on calling function)

switch dbfnc
    case 'getDuneErosion_VTV2006'
        cla(dbax);
        plot(xInitial,zInitial,'Color',[255 215 140]/255,'LineWidth',2,'Parent',dbax,'Tag','IniProfile');
        plot(xlim,[WL_t WL_t],'Color',[74 114 255]/255,'LineStyle','--','Parent',dbax,'Tag','WL');
        if dbstopcr
            dbstopcurrent(1);
        else
            pause(dt)
        end
    case 'getIterationBoundaries'
        switch(varargin{1})
            case 'x0max'
                dbx0max=findobj('Tag','dbx0max');
                if ~isempty(dbx0max)
                    set(dbx0max,'XData',[x0max x0max],'YData',ylim(dbax));
                else
                    plot([x0max x0max],ylim(dbax),'Parent',dbax,'Color','k','LineStyle','-.','Tag','dbx0max');
                end
            case 'x00min'
                dbx00min=findobj('Tag','dbx00min');
                if ~isempty(dbx00min)
                    set(dbx00min,'XData',[x00min x00min],'YData',ylim(dbax));
                else
                    plot([x00min x00min],ylim(dbax),'Parent',dbax,'Color','k','LineStyle','-.','Tag','dbx00min');
                end
            case 'x0except'
                for iexc=1:length(x0except)
                    temphan=findobj('Tag',['dbx0exc' num2str(iexc)]);
                    if ~isempty(temphan)
                        set(temphan,'XData',[x0except(iexc) x0except(iexc)],'YData',ylim(dbax));
                    else
                        plot([x0except(iexc) x0except(iexc)],ylim(dbax),'Parent',dbax,'Color','b','LineStyle','-.','Tag',['dbx0exc' num2str(iexc)]);
                    end
                end
            case 'x0min'
                dbx0min=findobj('Tag','dbx0min');
                if ~isempty(dbx0min)
                    set(dbx0min,'XData',[x0min x0min],'YData',ylim(dbax));
                else
                    plot([x0min x0min],ylim(dbax),'Parent',dbax,'Color','k','LineStyle','-.','Tag','dbx0min');
                end
        end
        if dbstopcr
            dbstopcurrent(1);
        else
            pause(dt)
        end
    case 'getParabolicProfile'
        if exist('y','var') && ~isempty(y)
            dbparab=findobj('Tag','parab');
            if isempty(dbparab)
                plot(x,y,'Color','k','Tag','parab','Parent',dbax);
            else
                set(dbparab,'XData',x,'YData',y);
            end
        end
        if dbstopcr
            dbstopcurrent(1);
        else
            pause(dt)
        end
    case 'getDUROSprofile'
        dbparab = findobj('Tag','parab');
        dbparabopt = findobj('Tag','optimiseparab');
        dbparabchannel = findobj('Tag','final DUROS');
        if isempty(dbparabopt)
            if isempty(dbparab)
                if isempty(dbparabchannel)
                    %                 set(dbparabchannel,'XData',x2,'YData',z2);
                    plot(x2,z2,'Color','k','Tag','parab','Parent',dbax);
                end
            else
                set(dbparab,'YData',z2,'XData',x2);
            end
            if dbstopcr
                dbstopcurrent(1);
            else
                pause(dt)
            end
        end
    case 'optimiseDUROS'
        switch varargin{1}
            case 'steeppoints in profile'
                plot(xInitialChannel,zInitialChannel,'Color',[0.7 0.7 0.7],'LineWidth',2,'Tag','channelprofile','Parent',dbax);
            case 'steeppoints'
                if ~isempty(points)
                    scatter(points(:,1),points(:,2),'Marker','*','MarkerEdgeColor','r','Parent',dbax,'Tag','Steeppoints');
                end
                dbparab = findobj('Tag','parab');
                if ~isempty(dbparab)
                    set(dbparab,'Tag','optimiseparab');
                end
                dbstopcurrent clear
            case 'final parab'
                dbparab = findobj('Tag','optimiseparab');
                dbparabchannel = findobj('Tag','final DUROS');
                xfin=[result.xLand ; result.xActive ; result.xSea];
                zfin=[result.zLand ; result.z2Active ; result.zSea];
                if isempty(dbparab)
                    if isempty(dbparabchannel)
                        plot(xfin,zfin,'Color','k','Tag','parab','Parent',dbax);
                    else
                        set(dbparabchannel,'XData',xfin, 'YData', zfin);
                    end
                else
                    set(dbparab,'YData',zfin,'XData',xfin,'Tag','final DUROS','Color','k');
                end
                if dbstopcr
                    dbstopcurrent(1);
                else
                    pause(dt)
                end
            case 'update parab'
                dbparab = findobj('Tag','optimiseparab');
                if Iter==1
                    xlimm=[min(result(Iter).xLand) max(result(Iter).xActive)];
                    xlimm=[xlimm(1) xlimm(2)+0.05*diff(xlimm)];
                    ylimm=[min(zInitial(xInitial>xlimm(1)&xInitial<xlimm(2))) max(zInitial(xInitial>xlimm(1)&xInitial<xlimm(2)))];
                    ylimm=[ylimm(1)-0.05*diff(ylimm) ylimm(2)+0.05*diff(ylimm)];
                    set(dbax,'xlim',xlimm,...
                        'ylim',ylimm);
                end
                if ~isempty(dbparab)
                    set(dbparab,'YData',result(Iter).z2Active,'XData',result(Iter).xActive,'Color','r','LineWidth',2,'Tag','optimiseparab');
                end
                if dbstopcr
                    dbstopcurrent(1);
                else
                    pause(dt)
                end
        end
    case 'getDuneErosion_additional'
        dba=findobj('Tag','addedvolume');
        if exist('result','var') && ~isempty(result.info)
            res=result;
            clr='k';
            Tag='final added volume';
        else
            res=iterresult(Iter);
            clr='r';
            Tag='addedvolume';
        end
        if isempty(dba)
            plot(res.xActive,res.z2Active,...
                'Color',clr,...
                'Tag',Tag);
        else
            set(dba,'XData',res.xActive,'YData',res.z2Active,'Color',clr,'Tag',Tag);
        end
        if dbstopcr
            dbstopcurrent(1);
        else
            pause(dt)
        end
end