function handles=muppet_adjustAxes(handles)
% Adjust axis limits based on new dataset added to plot

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
data=handles.datasets(handles.activedataset).dataset;

if ~isfield(data,'x')
    data.x=[];
end
if ~isfield(data,'y')
    data.y=[];
    
end
if ~isfield(data,'z')
    data.z=[];
end

if isempty(data.y)
    if isfield(data,'u') && isfield(data,'v')
        if ~isempty(data.u) && ~isempty(data.v)
            data.y=sqrt(data.u.^2+data.v.^2);
        end
    end
end

%% Axis limits
switch plt.type
    case{'timeseries','timestack','map','3d','xy'}
        
        % Original subplot limits
        switch plt.type
            case{'timeseries','timestack'}
                if isempty(plt.yearmin)
                    xmin0=[];
                    xmax0=[];
                else
                    xmin0=datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
                    xmax0=datenum(plt.yearmax,plt.monthmax,plt.daymax,plt.hourmax,plt.minutemax,plt.secondmax);
                end
            otherwise
                xmin0=plt.xmin;
                xmax0=plt.xmax;
        end
        
        ymin0=plt.ymin;
        ymax0=plt.ymax;
        zmin0=plt.zmin;
        zmax0=plt.zmax;

        newplot=0;
        
        if isempty(xmin0)
            xmin0=1e9;
            xmax0=-1e9;
            newplot=1;
        end
        if isempty(ymin0)
            ymin0=1e9;
            ymax0=-1e9;
        end
        if isempty(zmin0)
            zmin0=1e9;
            zmax0=-1e9;
        end
                
        % Data limits
        dataxmin=min(min(data.x));
        dataxmax=max(max(data.x));
        dataymin=min(min(data.y));
        dataymax=max(max(data.y));
        datazmin=min(min(data.z));
        datazmax=max(max(data.z));
        % Add margin to data
        marg=0.05;
        dx=dataxmax-dataxmin;
        dy=dataymax-dataymin;
        dz=datazmax-datazmin;
        if dx==0
            dx=20;
        end
        if dy==0
            dy=20;
        end
        if dz==0
            dz=20;
        end
        dataxmin=dataxmin-dx*marg;
        dataxmax=dataxmax+dx*marg;
        dataymin=dataymin-dy*marg;
        dataymax=dataymax+dy*marg;
        datazmin=datazmin-dz*marg;
        datazmax=datazmax+dz*marg;
        
        % New axis limits and ticks
        
        xmin=min(xmin0,dataxmin);
        xmax=max(xmax0,dataxmax);
        ymin=min(ymin0,dataymin);
        ymax=max(ymax0,dataymax);
        zmin=min(zmin0,datazmin);
        zmax=max(zmax0,datazmax);
        
        switch plt.type
            case{'timeseries','timestack'}
                tmin=datevec(xmin);
                tmax=datevec(xmax);
                plt.yearmin=tmin(1);
                plt.monthmin=tmin(2);
                plt.daymin=tmin(3);
                plt.hourmin=tmin(4);
                plt.minutemin=tmin(5);
                plt.secondmin=tmin(6);
                plt.yearmax=tmax(1);
                plt.monthmax=tmax(2);
                plt.daymax=tmax(3);
                plt.hourmax=tmax(4);
                plt.minutemax=tmax(5);
                plt.secondmax=tmax(6);
                plt.yeartick=   0;
                plt.monthtick=  0;
                plt.daytick=    0;
                plt.hourtick=   0;
                plt.minutetick= 0;
                plt.secondtick= 0;
                dt=xmax-xmin;
                if dt>1000
                    plt.yeartick=   1;
                    plt.datetickformatnumber= 10;
                elseif dt>200
                    plt.monthtick=  1;
                    plt.datetickformatnumber= 24;
                elseif dt>12
                    plt.daytick=  round(dt/6);
                    plt.datetickformatnumber= 24;
                elseif dt>3
                    plt.daytick=  1;
                    plt.datetickformatnumber= 24;
                elseif dt>1
                    plt.hourtick=   12;
                    plt.datetickformatnumber= 15;
                elseif dt>1/2
                    plt.hourtick=   2;
                    plt.datetickformatnumber= 15;
                elseif dt>1/4
                    plt.hourtick=   1;
                    plt.datetickformatnumber= 15;
                elseif dt>1/12
                    plt.minutetick=   30;
                    plt.datetickformatnumber= 15;
                elseif dt>1/24
                    plt.minutetick=   10;
                    plt.datetickformatnumber= 15;
                elseif dt>1/48
                    plt.minutetick=   5;
                    plt.datetickformatnumber= 15;
                elseif dt>1/96
                    plt.minutetick=   2;
                    plt.datetickformatnumber= 15;
                elseif dt>1/192
                    plt.minutetick=   1;
                    plt.datetickformatnumber= 15;
                elseif dt>1/360
                    plt.minutetick=   1;
                    plt.datetickformatnumber= 15;
                else
                    plt.secondtick=round(dt*86400/6);
                    plt.datetickformat= 13;
                end
%                plt.dateformat=handles.dateformatnumbers(plt.datetickformatnumber);
                
                [ymin1,ymax1,dy]=roundlimits(ymin,ymax);
                plt.ymin=ymin1;
                plt.ymax=ymax1;
                plt.ytick=dy;
                
            case{'xy'}
                [xmin1,xmax1,dx]=roundlimits(xmin,xmax);
                plt.xmin=xmin1;
                plt.xmax=xmax1;
                plt.xtick=dx;
                [ymin1,ymax1,dy]=roundlimits(ymin,ymax);
                plt.ymin=ymin1;
                plt.ymax=ymax1;
                plt.ytick=dy;
                
            case{'map','3d'}
                
                if newplot
                    if isfield(data,'coordinatesystem')
                        plt.coordinatesystem=data.coordinatesystem;
                    else
                        plt.coordinatesystem.name='unspecified';
                        plt.coordinatesystem.type='projected';
                    end
                    switch plt.coordinatesystem.type
                        case{'geographic'}
                            plt.projection='mercator';
                            %                            plt.projection='albers';
                            plt.labda0=0.5*(xmin+xmax);
                            plt.labda0=xmin-10;
                            plt.phi0=0.5*(ymin+ymax);
                            plt.phi1=xmin;
                            plt.phi2=xmax;
                    end
                end

                plt.xmin=xmin;
                plt.xmax=xmax;
                plt.ymin=ymin;
                plt.ymax=ymax;

                plt=muppet_updateLimits(plt,'updateall');
                
                if ~isempty(zmin)
                  [zmin1,zmax1,dz]=roundlimits(zmin,zmax);
                  plt.zmin=zmin1;
                  plt.zmax=zmax1;
                  plt.ztick=dz;
                end

                % 3D

                plt.dataaspectratio=[1.0 1.0 1/(0.2*(plt.xmax-plt.xmin)/(plt.zmax-plt.zmin))];
                
                plt.viewmode3d=2;
                plt.cameraangle=[315 30];
                plt.cameradistance=3*(plt.xmax-plt.xmin);
                cameratargetx=0.5*(plt.xmin+plt.xmax);
                cameratargety=0.5*(plt.ymin+plt.ymax);
                if ~isempty(zmax) && ~isempty(zmin)
                    cameratargetz=0.5*(zmax+zmin);
                else
                    cameratargetz=0.0;
                end
                plt.cameratarget=[cameratargetx cameratargety cameratargetz];
                plt.cameraposition=cameraview('viewangle',[plt.cameraangle plt.cameradistance],'target',plt.cameratarget,'dataaspectratio',plt.dataaspectratio);
                plt.cameraviewangle=8.0;
                
                plt.light=1;
                plt.lightangle=[0 70];
                plt.lightstrength=0.5;

                plt.perspective=1;
                
        end
        
end

%% Color limits
switch plt.type
    case {'timestack','map','3d','xy'}        
        if ~isempty(data.z)
            zmin=min(min(data.z));
            zmax=max(max(data.z));            
            if zmin==zmax
                plt.cmin=zmin-1.0;
                plt.cmax=zmin+1.0;
                plt.cstep=0.2;
            else
                [plt.cmin,plt.cmax,plt.cstep]=roundlimits(zmin,zmax);
            end            
            plt.contours=plt.cmin:plt.cstep:plt.cmax;
        end        
end

%% Vector legend
switch plt.type
    case {'timestack','map','3d','xy'}
        % Vector Legend
        if plt.vectorlegend.position(1)==0
            x0=plt.position(1)+1.0;
            y0=plt.position(2)+1.0;
            plt.vectorlegend.position=[x0 y0];
        end
end

% Other
switch plt.type

    case {'image'}
        imagesize(1)=size(data.c,1);
        imagesize(2)=size(data.c,2);
        ysz=plt.position(3)*imagesize(1)/imagesize(2);
        plt.position(4)=round(ysz*10)/10;
        plt.drawbox=0;
        plt.axesequal=1;

    case {'text'}
        plt.drawbox=1;
        
end

handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;

return

% Set Axes Limits
xminori=plt.xmin;
xmaxori=plt.xmax;
yminori=plt.ymin;
ymaxori=plt.ymax;
zminori=plt.zmin;
zmaxori=plt.zmax;

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
        x1=plt.Position(3)*0.01;
        y1=plt.Position(4)*0.01;
        scalex=dx/x1;
        scaley=dy/y1;
 
        xmin0=xmin+0.5*dx-0.5*max(scalex,scaley)*x1;
        ymin0=ymin+0.5*dy-0.5*max(scalex,scaley)*y1;
 
        dx=max(scalex,scaley)*plt.Position(3)*0.01;
        dy=max(scalex,scaley)*plt.Position(4)*0.01;
 
        order=floor(log10(dx));
        xmin1=10^(order-1)*floor(xmin0/10^(order-1));
 
        order=floor(log10(dy));
        ymin1=10^(order-1)*floor(ymin0/10^(order-1));
        
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
        
        plt.Scale=10^(round(log10(scale))-1)*ceil(scale/10^(round(log10(scale))-1));
        plt.xmin=xmin1;
        plt.ymin=ymin1;
        plt.zmin=zmin1;
        plt.xmax=xmin1+plt.Scale*x1;
        plt.ymax=ymin1+plt.Scale*y1;
        plt.zmax=zmax1;
        plt.ytick=plt.Scale*0.02;
        plt.YTick=plt.Scale*0.02;
        plt.ZTick=dz2;
 
        CameraTargetX=0.5*(plt.xmin+plt.xmax);
        CameraTargetY=0.5*(plt.ymin+plt.ymax);
        CameraTargetZ=0.5*(zmax+zmin);
        plt.CameraTarget=[CameraTargetX CameraTargetY CameraTargetZ];
        plt.CameraAngle=[315 45];
        plt.CameraViewAngle=8.0;
        plt.DataAspectRatio=[1.0 1.0 max(0.001,round(0.02*(xmax-xmin)/max(zmax-zmin,1e-9)))];
        plt.LightStrength=0.5;
        plt.Perspective=1;
 
        plt.XScale='linear';
        plt.YScale='linear';
        
        plt.AxesEqual=1;
        plt.AdjustAxes=1;
        
        switch lower(typ),
            case {'2dscalar','2dvector','polyline','annotation','crosssections','kubint','lint'}
                plt.AxesEqual=1;
            case {'3dcrosssectionvector','3dcrosssectionscalar','3dcrosssectiongrid'}
                plt.AxesEqual=0;
                plt.xmin=xmin-(0.1*(xmax-xmin));
                plt.ymin=ymin-(0.1*(ymax-ymin));
                plt.xmax=xmax+(0.1*(xmax-xmin));
                plt.ymax=ymax+(0.1*(ymax-ymin));
        end

        plt.DrawBox=1;

%        plt.PlotType='2d';
 
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
 
        x1=plt.Position(3)*0.01;
        y1=plt.Position(4)*0.01;
 
        dx=xmax-xmin;
        dy=ymax-ymin;
 
        order=floor(log10(dy));
 
        ymin1=10^(order-1)*floor(ymin/10^(order-1));
        ymax1=10^(order-1)*ceil(ymax/10^(order-1));
 
        plt.YTick=(ymax1-ymin1)/8;
        plt.ymin=ymin1;
        plt.ymax=ymax1;

        plt.YTickRight=(ymax1-ymin1)/8;
        plt.yminRight=ymin1;
        plt.ymaxRight=ymax1;
        
        plt.YearMin=str2num(datestr(xmin,'yyyy'));
        plt.YearMax=str2num(datestr(xmax,'yyyy'));
        plt.MonthMin=str2num(datestr(xmin,'mm'));
        plt.MonthMax=str2num(datestr(xmax,'mm'));
        plt.Daymin=str2num(datestr(xmin,'dd'));
        plt.Daymax=str2num(datestr(xmax,'dd'));
        plt.HourMin=str2num(datestr(xmin,'HH'));
        plt.HourMax=str2num(datestr(xmax,'HH'));
        plt.MinuteMin=str2num(datestr(xmin,'MM'));
        plt.MinuteMax=str2num(datestr(xmax,'MM'));
        plt.SecondMin=str2num(datestr(xmin,'SS'));
        plt.SecondMax=str2num(datestr(xmax,'SS'));
 
        plt.xmin=xmin;
        plt.xmax=xmax;
 
        plt.YearTick=   0;
        plt.MonthTick=  0;
        plt.DayTick=    0;
        plt.HourTick=   0;
        plt.MinuteTick= 0;
        plt.SecondTick= 0;
 
        dt=xmax-xmin;
 
        if dt>1000
            plt.YearTick=   1;
            plt.DateFormatNr= 10;
        elseif dt>200
            plt.MonthTick=  1;
            plt.DateFormatNr= 24;
        elseif dt>12
            plt.DayTick=  round(dt/6);
            plt.DateFormatNr= 24;
        elseif dt>3
            plt.DayTick=  1;
            plt.DateFormatNr= 24;
        elseif dt>1
            plt.HourTick=   12;
            plt.DateFormatNr= 15;
        elseif dt>1/2
            plt.HourTick=   2;
            plt.DateFormatNr= 15;
        elseif dt>1/4
            plt.HourTick=   1;
            plt.DateFormatNr= 15;
        elseif dt>1/12
            plt.MinuteTick=   30;
            plt.DateFormatNr= 15;
        elseif dt>1/24
            plt.MinuteTick=   10;
            plt.DateFormatNr= 15;
        elseif dt>1/48
            plt.MinuteTick=   5;
            plt.DateFormatNr= 15;
        elseif dt>1/96
            plt.MinuteTick=   2;
            plt.DateFormatNr= 15;
        elseif dt>1/192
            plt.MinuteTick=   1;
            plt.DateFormatNr= 15;
        elseif dt>1/360
            plt.MinuteTick=   1;
            plt.DateFormatNr= 15;
        else
            plt.SecondTick=round(dt*86400/6);
            plt.DateFormatNr= 13;
        end
        plt.DateFormat=handles.DateFormats{plt.DateFormatNr};
        for ii=1:5
            if round(plt.YTick*10^i)==plt.YTick*10^i
                plt.DecimY=ii;
                break
            end
        end

        for ii=1:5
            if round(plt.YTickRight*10^i)==plt.YTickRight*10^i
                plt.DecimYRight=ii;
                break
            end
        end
        
        plt.XScale='linear';
        plt.YScale='linear';
        plt.XGrid=0;
        plt.YGrid=0;
        plt.XGridRight=0;
        plt.YGridRight=0;

        plt.AddDate=0;
        plt.AxesEqual=0;

        plt.AdjustAxes=1;
       
        plt.DrawBox=1;

        plt.PlotType='timeseries';
        
    case {'timestack'}
        
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
 
        x1=plt.Position(3)*0.01;
        y1=plt.Position(4)*0.01;
 
        dx=xmax-xmin;
        dy=ymax-ymin;
 
        order=floor(log10(dy));
 
        ymin1=10^(order-1)*floor(ymin/10^(order-1));
        ymax1=10^(order-1)*ceil(ymax/10^(order-1));
 
        plt.YTick=(ymax1-ymin1)/8;
        plt.ymin=ymin1;
        plt.ymax=ymax1;

        plt.YTickRight=(ymax1-ymin1)/8;
        plt.yminRight=ymin1;
        plt.ymaxRight=ymax1;
        
        plt.YearMin=str2num(datestr(xmin,'yyyy'));
        plt.YearMax=str2num(datestr(xmax,'yyyy'));
        plt.MonthMin=str2num(datestr(xmin,'mm'));
        plt.MonthMax=str2num(datestr(xmax,'mm'));
        plt.Daymin=str2num(datestr(xmin,'dd'));
        plt.Daymax=str2num(datestr(xmax,'dd'));
        plt.HourMin=str2num(datestr(xmin,'HH'));
        plt.HourMax=str2num(datestr(xmax,'HH'));
        plt.MinuteMin=str2num(datestr(xmin,'MM'));
        plt.MinuteMax=str2num(datestr(xmax,'MM'));
        plt.SecondMin=str2num(datestr(xmin,'SS'));
        plt.SecondMax=str2num(datestr(xmax,'SS'));
 
        plt.xmin=xmin;
        plt.xmax=xmax;
 
        plt.YearTick=   0;
        plt.MonthTick=  0;
        plt.DayTick=    0;
        plt.HourTick=   0;
        plt.MinuteTick= 0;
        plt.SecondTick= 0;
 
        dt=xmax-xmin;
 
        if dt>1000
            plt.YearTick=   1;
            plt.DateFormatNr= 10;
        elseif dt>200
            plt.MonthTick=  1;
            plt.DateFormatNr= 24;
        elseif dt>12
            plt.DayTick=  round(dt/6);
            plt.DateFormatNr= 24;
        elseif dt>3
            plt.DayTick=  1;
            plt.DateFormatNr= 24;
        elseif dt>1
            plt.HourTick=   12;
            plt.DateFormatNr= 15;
        elseif dt>1/2
            plt.HourTick=   2;
            plt.DateFormatNr= 15;
        elseif dt>1/4
            plt.HourTick=   1;
            plt.DateFormatNr= 15;
        elseif dt>1/12
            plt.MinuteTick=   30;
            plt.DateFormatNr= 15;
        elseif dt>1/24
            plt.MinuteTick=   10;
            plt.DateFormatNr= 15;
        elseif dt>1/48
            plt.MinuteTick=   5;
            plt.DateFormatNr= 15;
        elseif dt>1/96
            plt.MinuteTick=   2;
            plt.DateFormatNr= 15;
        elseif dt>1/192
            plt.MinuteTick=   1;
            plt.DateFormatNr= 15;
        elseif dt>1/360
            plt.MinuteTick=   1;
            plt.DateFormatNr= 15;
        else
            plt.SecondTick=round(dt*86400/6);
            plt.DateFormatNr= 13;
        end
        plt.DateFormat=handles.DateFormats{plt.DateFormatNr};
        for ii=1:5
            if round(plt.YTick*10^i)==plt.YTick*10^i
                plt.DecimY=ii;
                break
            end
        end

        for ii=1:5
            if round(plt.YTickRight*10^i)==plt.YTickRight*10^i
                plt.DecimYRight=ii;
                break
            end
        end
        
        plt.XScale='linear';
        plt.YScale='linear';
        plt.XGrid=0;
        plt.YGrid=0;
        plt.XGridRight=0;
        plt.YGridRight=0;

        plt.AddDate=0;
        plt.AxesEqual=0;

        plt.AdjustAxes=1;
       
        plt.DrawBox=1;

        plt.PlotType='timestack';        
        
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
        
        x1=plt.Position(3)*0.01;
        y1=plt.Position(4)*0.01;
 
        dx=xmax-xmin;
        dy=ymax-ymin;
 
        order=floor(log10(dy));
 
        ymin1=10^(order-1)*floor(ymin/10^(order-1));
        ymax1=10^(order-1)*ceil(ymax/10^(order-1));
 
 
        plt.xmin=xmin;
        plt.xmax=xmax;
        plt.ytick=(xmax-xmin)/10;
 
        plt.YTick=(ymax1-ymin1)/8;
        plt.ymin=ymin1;
        plt.ymax=ymax1;
 
        plt.XGrid=0;
        plt.YGrid=0;
        plt.XGridRight=0;
        plt.YGridRight=0;
 
        for ii=1:5
            if round(plt.ytick*10^i)==plt.ytick*10^i
                plt.DecimX=ii;
                break
            end
        end
 
        for ii=1:5
            if round(plt.YTick*10^i)==plt.YTick*10^i
                plt.DecimY=ii;
                break
            end
        end
 
        plt.XScale='linear';
        plt.YScale='linear';

        plt.AxesEqual=0;
        plt.AdjustAxes=1;

        plt.DrawBox=1;
 
        plt.PlotType='xy';
 
end

% Set Color Limits

switch lower(typ),
    case {'2dscalar','kubint','3dcrosssectionscalar','samples','timestack'}
        
        plt.ContourType='limits';
        
        zmin=min(min(handles.DataProperties(i).z));
        zmax=max(max(handles.DataProperties(i).z));

        if zmin==zmax
            plt.CMin=zmin-1.0;
            plt.CMax=zmin+1.0;
            plt.CStep=(plt.CMax-plt.CMin)/10;
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
            
            plt.CMin=zmin1;
            plt.CMax=zmax1;
            plt.CStep=dz2;
            
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
        plt.Contours=plt.CMin:plt.CStep:plt.CMax;
end

% Set colorbar position
if plt.ColorBarPosition(3)==0
    x0=plt.Position(1)+plt.Position(3)-2.0;
    y0=plt.Position(2)+1.0;
    x1=0.5;
    y1=plt.Position(4)-2.0;
    plt.ColorBarPosition=[x0 y0 x1 y1];
end
plt.ColorBarUnit='';

% Set vector legend position
if plt.VectorLegendPosition(1)==0
    x0=plt.Position(1)+1.0;
    y0=plt.Position(2)+1.0;
    plt.VectorLegendPosition=[x0 y0];
end

% Other

switch lower(typ),

    case {'image'}
        ImageSize=size(handles.DataProperties(handles.ActiveAvailableDataset).x');
        ysz=plt.Position(3)*ImageSize(2)/ImageSize(1);
        plt.Position(4)=round(ysz*10)/10;
        plt.DrawBox=0;
        plt.AxesEqual=1;

    case {'teyt'}
        plt.DrawBox=1;
        
end

%%

