function dbplotgetVolumeCorrection(varargin)

persistent dbfig

% return % include if no plots are needed

dbstopcr=false;
dt=1;
%% initiate debug figure if not present
dbfig=findobj('Tag','dbVolCorrfig');
if isempty(dbfig) || (nargin>0 && strcmp(varargin{1},'init'))
    set(get(findobj('Tag','dbaxes2'),'Children'),'Tag','');
    set(get(findobj('Tag','dbaxes1'),'Children'),'Tag','');
    set(get(dbfig,'Children'),'Tag','');
    set(dbfig,'Tag','');
    dbfig=figure('NumberTitle','off','Name','Debug figure','Tag','dbVolCorrfig','WindowStyle','docked','Color','w');
    dbax1=axes('Parent',dbfig,'Tag','dbaxes1','Color','none');
    xlabel('Cross shore distance (x [m])');
    ylabel('Vertical level [m]');
    box on
    hold on
    grid on
    dbax2=axes('Parent',dbfig,'Tag','dbaxes2','position',get(dbax1,'Position'),'Color','none','YAxisLocation','right');
    ylabel('Cumulative Volume');
    hold on
else
    dbax1=findobj('Tag','dbaxes1');
    dbax2=findobj('Tag','dbaxes2');
end

%% pass variables from calling workspace to this workspace
% This enables use of the variables as if it were programmed in the calling
% function. Variables are passed through the userdata of the debug plot
% figure.

evalin('caller','dbs=whos;');
evalin('caller','for idb=1:length(dbs), dbs(idb).content=eval(dbs(idb).name); end');
evalin('caller','set(findobj(''Tag'',''dbVolCorrfig''),''UserData'',dbs);');

dbs=get(dbfig,'UserData');
for dbvari=1:length(dbs)
    if ~strcmp(dbs(dbvari).name,'dbs')
        eval([dbs(dbvari).name '=dbs(dbvari).content;']);
    end
end
set(dbfig,'UserData',[]);

%%
switch varargin{1}
    case 'init'
        plot(x,z,'-ob','Parent',dbax1,'Tag','xz');
        plot(x,z2,'-or','Parent',dbax1,'Tag','xz2');
        plot(mean([x(1:length(x)-1),x(2:length(x))],2),CumVolume,'Parent',dbax2,'Tag','Cumvolume','Color','k');
        axes(dbax2);
        hline(0);
        scatter(x(SeawardBoundary+1:length(x)),z2(SeawardBoundary+1:length(z2)),'Marker','*','MarkerEdgeColor','k','Parent',dbax1);
        axes(dbax1);
    case 'finish'
        if dbstopcr
            dbstopcurrent(1);
        else
            pause(dt);
        end
        close(dbfig);
    otherwise
        initprofile = findobj('tag','xz');
        correctedactive = findobj('tag','xz2');
        cumvol = findobj('Tag','Cumvolume');
        if isempty(initprofile)
            plot(x,z,'-ob','Parent',dbax1,'Tag','xz');
            plot(x,z2,'-or','Parent',dbax1,'Tag','xz2');
            plot(mean([x(1:length(x)-1),x(2:length(x))],2),CumVolume,'Parent',dbax2,'Tag','Cumvolume','Color','k');
            axes(dbax2);
            hline(0);
        else
            set(initprofile,'XData',x,'YData',z);
            set(correctedactive,'XData',x,'YData',z2);
            set(cumvol,'YData',CumVolume,'XData',mean([x(1:length(x)-1),x(2:length(x))],2));
        end
        scatter(x(ii:ii+1),z2(ii:ii+1),'Marker','*','MarkerEdgeColor','k','Parent',dbax1);
        axes(dbax1);
end

dbstate on