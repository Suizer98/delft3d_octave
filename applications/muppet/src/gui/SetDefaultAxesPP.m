function handles=SetDefaultAxes(handles,new)

ifig=1;
i=handles.ActiveAvailableDataset;
j=1;
typ=handles.DataProperties(handles.ActiveAvailableDataset).Type;

if strcmp(handles.Figure(ifig).Axis(j).PlotType,'unknown')
    switch lower(handles.DataProperties(i).Type),

        case {'timeseries'}
            handles.Figure(ifig).Axis(j).PlotType='timeseries';

        case {'xyseries'}
            handles.Figure(ifig).Axis(j).PlotType='xy';

        case {'2dscalar','2dvector','samples','geoimage','curvedvectors','polyline','3dcrosssectionscalar', ...
                '3dcrosssectionvector','3dcrosssectiongrid','kubint','lint','annotation','crosssections','grid'}
            if ~strcmp(handles.Figure(ifig).Axis(j).PlotType,'3d')
                handles.Figure(ifig).Axis(j).PlotType='2d';
            end

        case {'image'}
            handles.Figure(ifig).Axis(j).PlotType='image';

        case {'rose'}
            handles.Figure(ifig).Axis(j).PlotType='rose';

        case {'bar'}
            handles.Figure(ifig).Axis(j).PlotType='bar';
    end

end

% Set Axes Limits
xminori=0;
xmaxori=1;
yminori=0;
ymaxori=1;
zminori=0;
zmaxori=1;
handles.Figure(ifig).Axis(j).Position=[0 0 10 5];

switch lower(typ),
    case {'2dscalar','2dvector','polyline','annotation','crosssections','kubint','lint','3dcrosssectionscalar', ...
          '3dcrosssectionvector','3dcrosssectiongrid','geoimage','curvedvectors','grid','samples'}
 
        if new==1
            xmin=min(min(handles.DataProperties(i).x));
            xmax=max(max(handles.DataProperties(i).x));
            ymin=min(min(handles.DataProperties(i).y));
            ymax=max(max(handles.DataProperties(i).y));
            zmin=min(min(handles.DataProperties(i).z));
            zmax=max(max(handles.DataProperties(i).z));
        else
            xmin=min(min(min(handles.DataProperties(i).x)),xminori);
            xmax=max(max(max(handles.DataProperties(i).x)),xmaxori);
            ymin=min(min(min(handles.DataProperties(i).y)),yminori);
            ymax=max(max(max(handles.DataProperties(i).y)),ymaxori);
            zmin=min(min(min(handles.DataProperties(i).z)),zminori);
            zmax=max(max(max(handles.DataProperties(i).z)),zmaxori);
        end
 
        dx=xmax-xmin;
        dy=ymax-ymin;
        x1=handles.Figure(ifig).Axis(j).Position(3)*0.01;
        y1=handles.Figure(ifig).Axis(j).Position(4)*0.01;
        scalex=dx/x1;
        scaley=dy/y1;
 
        XMin0=xmin+0.5*dx-0.5*max(scalex,scaley)*x1;
        YMin0=ymin+0.5*dy-0.5*max(scalex,scaley)*y1;
 
        dx=max(scalex,scaley)*handles.Figure(ifig).Axis(j).Position(3)*0.01;
        dy=max(scalex,scaley)*handles.Figure(ifig).Axis(j).Position(4)*0.01;
 
        order=floor(log10(dx));
        xmin1=10^(order-1)*floor(XMin0/10^(order-1));
 
        order=floor(log10(dy));
        ymin1=10^(order-1)*floor(YMin0/10^(order-1));
        
        scalex=(xmax-xmin1)/x1;
        scaley=(ymax-ymin1)/y1;
        scale=max(scalex,scaley);

        dz=max(zmax-zmin,1e-9);
        logdif=round(log10(dz));
        zmin1=10^logdif*floor(zmin*10^-logdif);
        zmax1=10^logdif*ceil(zmax*10^-logdif);
        dz1=max(zmax1-zmin1,1e-9);
        logdif1=round(log10(dz1));
        dz2=10^logdif1;
        
        handles.Figure(ifig).Axis(j).Scale=10^(round(log10(scale))-1)*ceil(scale/10^(round(log10(scale))-1));
        handles.Figure(ifig).Axis(j).XMin=xmin1;
        handles.Figure(ifig).Axis(j).YMin=ymin1;
        handles.Figure(ifig).Axis(j).ZMin=zmin1;
        handles.Figure(ifig).Axis(j).XMax=xmin1+handles.Figure(ifig).Axis(j).Scale*x1;
        handles.Figure(ifig).Axis(j).YMax=ymin1+handles.Figure(ifig).Axis(j).Scale*y1;
        handles.Figure(ifig).Axis(j).ZMax=zmax1;
        handles.Figure(ifig).Axis(j).XTick=handles.Figure(ifig).Axis(j).Scale*0.02;
        handles.Figure(ifig).Axis(j).YTick=handles.Figure(ifig).Axis(j).Scale*0.02;
        handles.Figure(ifig).Axis(j).ZTick=dz2;
        
        handles.Figure(ifig).Axis(j).PlotType='2d';
 
    case {'timeseries'}
        if new==1
            xmin=min(min(handles.DataProperties(i).x));
            xmax=max(max(handles.DataProperties(i).x));
            ymin=min(min(handles.DataProperties(i).y));
            ymax=max(max(handles.DataProperties(i).y));
            if ymin==ymax
                ymin=ymin-1;
                ymax=ymax+1;
            end
        else
            xmin=min(min(min(handles.DataProperties(i).x)),xminori);
            xmax=max(max(max(handles.DataProperties(i).x)),xmaxori);
            ymin=min(min(min(handles.DataProperties(i).y)),yminori);
            ymax=max(max(max(handles.DataProperties(i).y)),ymaxori);
        end
 
        x1=handles.Figure(ifig).Axis(j).Position(3)*0.01;
        y1=handles.Figure(ifig).Axis(j).Position(4)*0.01;
 
        dx=xmax-xmin;
        dy=ymax-ymin;
 
        order=floor(log10(dy));
 
        ymin1=10^(order-1)*floor(ymin/10^(order-1));
        ymax1=10^(order-1)*ceil(ymax/10^(order-1));
 
        handles.Figure(ifig).Axis(j).YTick=(ymax1-ymin1)/8;
        handles.Figure(ifig).Axis(j).YMin=ymin1;
        handles.Figure(ifig).Axis(j).YMax=ymax1;

        handles.Figure(ifig).Axis(j).YTickRight=(ymax1-ymin1)/8;
        handles.Figure(ifig).Axis(j).YMinRight=ymin1;
        handles.Figure(ifig).Axis(j).YMaxRight=ymax1;
        
        handles.Figure(ifig).Axis(j).YearMin=str2num(datestr(xmin,'yyyy'));
        handles.Figure(ifig).Axis(j).YearMax=str2num(datestr(xmax,'yyyy'));
        handles.Figure(ifig).Axis(j).MonthMin=str2num(datestr(xmin,'mm'));
        handles.Figure(ifig).Axis(j).MonthMax=str2num(datestr(xmax,'mm'));
        handles.Figure(ifig).Axis(j).DayMin=str2num(datestr(xmin,'dd'));
        handles.Figure(ifig).Axis(j).DayMax=str2num(datestr(xmax,'dd'));
        handles.Figure(ifig).Axis(j).HourMin=str2num(datestr(xmin,'HH'));
        handles.Figure(ifig).Axis(j).HourMax=str2num(datestr(xmax,'HH'));
        handles.Figure(ifig).Axis(j).MinuteMin=str2num(datestr(xmin,'MM'));
        handles.Figure(ifig).Axis(j).MinuteMax=str2num(datestr(xmax,'MM'));
        handles.Figure(ifig).Axis(j).SecondMin=str2num(datestr(xmin,'SS'));
        handles.Figure(ifig).Axis(j).SecondMax=str2num(datestr(xmax,'SS'));
 
        handles.Figure(ifig).Axis(j).XMin=xmin;
        handles.Figure(ifig).Axis(j).XMax=xmax;
 
        handles.Figure(ifig).Axis(j).YearTick=   0;
        handles.Figure(ifig).Axis(j).MonthTick=  0;
        handles.Figure(ifig).Axis(j).DayTick=    0;
        handles.Figure(ifig).Axis(j).HourTick=   0;
        handles.Figure(ifig).Axis(j).MinuteTick= 0;
        handles.Figure(ifig).Axis(j).SecondTick= 0;
 
        dt=xmax-xmin;
 
        if dt>1000
            handles.Figure(ifig).Axis(j).YearTick=   1;
            handles.Figure(ifig).Axis(j).DateFormatNr= 10;
        elseif dt>200
            handles.Figure(ifig).Axis(j).MonthTick=  1;
            handles.Figure(ifig).Axis(j).DateFormatNr= 24;
        elseif dt>12
            handles.Figure(ifig).Axis(j).DayTick=  round(dt/6);
            handles.Figure(ifig).Axis(j).DateFormatNr= 24;
        elseif dt>3
            handles.Figure(ifig).Axis(j).DayTick=  1;
            handles.Figure(ifig).Axis(j).DateFormatNr= 24;
        elseif dt>1
            handles.Figure(ifig).Axis(j).HourTick=   12;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/2
            handles.Figure(ifig).Axis(j).HourTick=   2;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/4
            handles.Figure(ifig).Axis(j).HourTick=   1;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/12
            handles.Figure(ifig).Axis(j).MinuteTick=   30;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/24
            handles.Figure(ifig).Axis(j).MinuteTick=   10;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/48
            handles.Figure(ifig).Axis(j).MinuteTick=   5;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/96
            handles.Figure(ifig).Axis(j).MinuteTick=   2;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/192
            handles.Figure(ifig).Axis(j).MinuteTick=   1;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        elseif dt>1/360
            handles.Figure(ifig).Axis(j).MinuteTick=   1;
            handles.Figure(ifig).Axis(j).DateFormatNr= 15;
        else
            handles.Figure(ifig).Axis(j).SecondTick=round(dt*86400/6);
            handles.Figure(ifig).Axis(j).DateFormatNr= 13;
        end
        handles.Figure(ifig).Axis(j).DateFormat=handles.DateFormats{handles.Figure(ifig).Axis(j).DateFormatNr};
        for i=1:5
            if round(handles.Figure(ifig).Axis(j).YTick*10^i)==handles.Figure(ifig).Axis(j).YTick*10^i
                handles.Figure(ifig).Axis(j).DecimY=i;
                break
            end
        end

        for i=1:5
            if round(handles.Figure(ifig).Axis(j).YTickRight*10^i)==handles.Figure(ifig).Axis(j).YTickRight*10^i
                handles.Figure(ifig).Axis(j).DecimYRight=i;
                break
            end
        end
        
        handles.Figure(ifig).Axis(j).XScale='linear';
        handles.Figure(ifig).Axis(j).YScale='linear';
        handles.Figure(ifig).Axis(j).XGrid=0;
        handles.Figure(ifig).Axis(j).YGrid=0;
        handles.Figure(ifig).Axis(j).XGridRight=0;
        handles.Figure(ifig).Axis(j).YGridRight=0;

        handles.Figure(ifig).Axis(j).AddDate=0;
        handles.Figure(ifig).Axis(j).AxesEqual=0;

        handles.Figure(ifig).Axis(j).AdjustAxes=1;
       
        handles.Figure(ifig).Axis(j).DrawBox=1;

        handles.Figure(ifig).Axis(j).PlotType='timeseries';
 
    case {'xyseries','3dprofile','2dcrosssection','bar'}
 
        if new==1
            xmin=min(min(handles.DataProperties(i).x));
            xmax=max(max(handles.DataProperties(i).x));
            ymin=min(min(handles.DataProperties(i).y));
            ymax=max(max(handles.DataProperties(i).y));
        else
            xmin=min(min(min(handles.DataProperties(i).x)),xminori);
            xmax=max(max(max(handles.DataProperties(i).x)),xmaxori);
            ymin=min(min(min(handles.DataProperties(i).y)),yminori);
            ymax=max(max(max(handles.DataProperties(i).y)),ymaxori);
        end
        
        if xmax==xmin
            xmax=xmax+1;
            xmin=xmin-1;
        end
        if ymax==ymin
            ymax=ymax+1;
            ymin=ymin-1;
        end
        
        x1=handles.Figure(ifig).Axis(j).Position(3)*0.01;
        y1=handles.Figure(ifig).Axis(j).Position(4)*0.01;
 
        dx=xmax-xmin;
        dy=ymax-ymin;
 
        order=floor(log10(dy));
 
        ymin1=10^(order-1)*floor(ymin/10^(order-1));
        ymax1=10^(order-1)*ceil(ymax/10^(order-1));
 
 
        handles.Figure(ifig).Axis(j).XMin=xmin;
        handles.Figure(ifig).Axis(j).XMax=xmax;
        handles.Figure(ifig).Axis(j).XTick=(xmax-xmin)/10;
 
        handles.Figure(ifig).Axis(j).YTick=(ymax1-ymin1)/8;
        handles.Figure(ifig).Axis(j).YMin=ymin1;
        handles.Figure(ifig).Axis(j).YMax=ymax1;
 
        handles.Figure(ifig).Axis(j).XGrid=0;
        handles.Figure(ifig).Axis(j).YGrid=0;
        handles.Figure(ifig).Axis(j).XGridRight=0;
        handles.Figure(ifig).Axis(j).YGridRight=0;
 
        for i=1:5
            if round(handles.Figure(ifig).Axis(j).XTick*10^i)==handles.Figure(ifig).Axis(j).XTick*10^i
                handles.Figure(ifig).Axis(j).DecimX=i;
                break
            end
        end
 
        for i=1:5
            if round(handles.Figure(ifig).Axis(j).YTick*10^i)==handles.Figure(ifig).Axis(j).YTick*10^i
                handles.Figure(ifig).Axis(j).DecimY=i;
                break
            end
        end
 
        handles.Figure(ifig).Axis(j).XScale='linear';
        handles.Figure(ifig).Axis(j).YScale='linear';

        handles.Figure(ifig).Axis(j).AxesEqual=0;
        handles.Figure(ifig).Axis(j).AdjustAxes=1;

        handles.Figure(ifig).Axis(j).DrawBox=1;
 
        handles.Figure(ifig).Axis(j).PlotType='xy';
 
end

% Set Color Limits

switch lower(typ),
    case {'2dscalar','kubint','3dcrosssectionscalar','samples'}
        
        handles.Figure(ifig).Axis(j).ContourType='limits';
        
        zmin=min(min(handles.DataProperties(i).z));
        zmax=max(max(handles.DataProperties(i).z));

        if zmin==zmax
            handles.Figure(ifig).Axis(j).CMin=zmin-1.0;
            handles.Figure(ifig).Axis(j).CMax=zmin+1.0;
            handles.Figure(ifig).Axis(j).CStep=(handles.Figure(ifig).Axis(j).CMax-handles.Figure(ifig).Axis(j).CMin)/10;
        else

            zmin=min(min(handles.DataProperties(i).z));
            zmax=max(max(handles.DataProperties(i).z));
            dz=zmax-zmin;
            logdif=round(log10(dz))-1;
            zmin1=10^logdif*floor(zmin*10^-logdif);
            zmax1=10^logdif*ceil(zmax*10^-logdif);
            dz1=zmax1-zmin1;
            logdif1=round(log10(dz1))-1;
            dz2=10^logdif1;
            
            handles.Figure(ifig).Axis(j).CMin=zmin1;
            handles.Figure(ifig).Axis(j).CMax=zmax1;
            handles.Figure(ifig).Axis(j).CStep=dz2;
            
        end
        
        nstep=10;
        zmin=min(min(handles.DataProperties(i).z));
        zmax=max(max(handles.DataProperties(i).z));
        
        dz=max(zmax-zmin,1e-9);
        logdif=round(log10(dz))-1;
        zmin1=10^logdif*floor(zmin*10^-logdif);
        zmax1=10^logdif*ceil(zmax*10^-logdif);
        dz1=max(zmax1-zmin1,1e-9);
        logdif1=round(log10(dz1))-1;
        dz2=10^logdif1;
        
        if and(zmin==0,zmax==0)
            handles.DataProperties(i).z=handles.DataProperties(i).z+1.0e-8;
        end
        handles.Figure(ifig).Axis(j).Contours=handles.Figure(ifig).Axis(j).CMin:handles.Figure(ifig).Axis(j).CStep:handles.Figure(ifig).Axis(j).CMax;
end

