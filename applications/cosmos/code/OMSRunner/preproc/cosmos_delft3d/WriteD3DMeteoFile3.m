function writeD3DMeteoFile3(meteodir,meteoname,rundir,fname,xlim,ylim,dx,dy,coordsys,coordsystype,reftime,tstart,tstop,dt,varargin)

inclh=0;
if ~isempty(varargin)
    if strcmpi(varargin{1},'includeheat')
        inclh=1;
    end
end
        
dt=dt/24;

nt=(tstop-tstart)/dt+1;

xlimg=xlim;ylimg=ylim;

xlim(2)=max(xlim(2),xlim(1)+dx);
ylim(2)=max(ylim(2),ylim(1)+dy);

if ~strcmpi(coordsystype,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=convertCoordinates(xg,yg,'persistent','CS1.name',coordsys,'CS1.type',coordsystype,'CS2.name','WGS 84','CS2.type','geographic');
    xlimg(1)=min(min(xgeo));
    xlimg(2)=max(max(xgeo));
    ylimg(1)=min(min(ygeo));
    ylimg(2)=max(max(ygeo));
    unit='m';
else
    unit='degree';
end

parstr={'u','v','p','airtemp','relhum','cloudcover'};
meteostr={'x_wind','y_wind','air_pressure','air_temperature','relative_humidity','cloudiness'};
unitstr={'m s-1','m s-1','Pa','Celsius','%','%'};
extstr={'amu','amv','amp','amt','amr','amc'};

if inclh
    npar=6;
else
    npar=3;
end

for ipar=1:npar
    for it=1:nt
        
        t=tstart+(it-1)*dt;
        tstr=datestr(t,'yyyymmddHHMMSS');
        fstr=[meteodir meteoname '.' parstr{ipar} '.' tstr '.mat'];
        if exist(fstr,'file')
            s=load(fstr);
        else
            % find first available file
            for n=1:1000
                t0=t+n*dt;
                tstr=datestr(t0,'yyyymmddHHMMSS');
                fstr=[meteodir meteoname '.' parstr{ipar} '.' tstr '.mat'];
                if exist(fstr,'file')
                    s=load(fstr);
                    break
                end
            end
        end
        
        [val,lon,lat]=getMeteoMatrix(s.(parstr{ipar}),s.lon,s.lat,xlimg,ylimg);
        
        if ~strcmpi(coordsystype,'geographic')
            val=interp2(lon,lat,val,xgeo,ygeo);
        end
        
        s2.time(it)=t;
        
        if ~strcmpi(coordsystype,'geographic')
            s2.x=xlim(1):dx:xlim(2);
            s2.y=ylim(1):dy:ylim(2);
            s2.dx=dx;
            s2.dy=dy;
        else
            if isfield(s,'dLon')
                csz(1)=s.dLon;
                csz(2)=s.dLat;
            else
                csz(1)=abs(s.lon(2)-s.lon(1));
                csz(2)=abs(s.lat(2)-s.lat(1));
            end
            s2.x=lon;
            s2.y=lat;
            s2.dx=csz(1);
            s2.dy=csz(2);
        end
        
        s2.(parstr{ipar})(:,:,it)=val;
        
    end
    
    writeD3Dmeteo([rundir fname '.' extstr{ipar}],s2,parstr{ipar},meteostr{ipar},unitstr{ipar},unit,reftime);

end
