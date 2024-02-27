function ddb_plotXBeachGrid(opt,handles,id,varargin)


switch lower(opt)

    case{'plot'}

        h=findall(gca,'Tag','XBeachGrid','UserData',id);
        delete(h);
        
        x=handles.model.xbeach.domain(id).gridx;
        y=handles.model.xbeach.domain(id).gridy;
%         xori = handles.model.xbeach.domain(id).xori;
%         yori = handles.model.xbeach.domain(id).yori;
%         alfa = handles.model.xbeach.domain(id).alfa;
%         xw =  xori+x*cos(alfa)-y*sin(alfa);
%         yw =  yori+x*sin(alfa)+y*cos(alfa);
        
%         grd=plot(xw,yw,'k');
%         set(grd,'Color',[0 0 0]);
%         set(grd,'HitTest','off');
%         set(grd,'Tag','XBeachGrid','UserData',id);
% 
%         grd=plot(xw',yw','k');
%         set(grd,'Color',[0 0 0]);
%         set(grd,'HitTest','off');
%         set(grd,'Tag','XBeachGrid','UserData',id);

        grd=plot(x,y,'k');
        set(grd,'Color',[0 0 0]);
        set(grd,'HitTest','off');
        set(grd,'Tag','XBeachGrid','UserData',id);

        grd=plot(x',y','k');
        set(grd,'Color',[0 0 0]);
        set(grd,'HitTest','off');
        set(grd,'Tag','XBeachGrid','UserData',id);
        
        
    case{'delete'}
        h=findall(gca,'Tag','XBeachGrid','UserData',id);
        delete(h);

    case{'activate'}
        h=findall(gca,'Tag','XBeachGrid','UserData',id);
        if ~isempty(h)
            set(h,'Color',[0 0 0]);
        end

    case{'deactivate'}
        h=findall(gca,'Tag','XBeachGrid','UserData',id);
        if ~isempty(h)
            set(h,'Color',[0.7 0.7 0.7]);
        end
end
