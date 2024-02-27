function s2=extractMeteoData(meteodir,model,dt,par)

coordsys=model.coordinateSystem;
coordsystype=model.coordinateSystemType;
meteowind=model.meteowind;
meteopressure=model.meteopressure;

xlim=model.xLim;
ylim=model.yLim;

% ylim(1)=max(ylim(1),-80);
% ylim(2)=min(ylim(2),80);

if ~strcmpi(coordsystype,'geographic')
    dx=model.dXMeteo;
    dy=model.dXMeteo;
else
    if ~isempty(model.meteospw)
        dx=0.1;
        dy=0.1;
    else        
    dx=[];
    dy=[];
    end
end

tstart=model.tFlowStart;
tstop=model.tStop;

dt=dt*60; % minutes

tmpdir=[];
fname=[];

switch lower(par)
    
    case{'windvel'}
        
        parameter={'u','v'};

        if ~isempty(model.meteospw)        
            spwfile=[meteodir 'spiderwebs' filesep model.meteospw];
        else
            spwfile=[];
        end
        
        s=write_meteo_file([meteodir meteowind filesep], meteowind, parameter, tmpdir, fname, xlim, ylim, tstart, tstop, 'dx',dx,'dy',dy,'dt',dt,'spwfile',spwfile,'model','none');
        
        s2.Parameter=par;
        s2.Time=s.parameter(1).time;
        s2.X=s.parameter(1).x;
        s2.Y=s.parameter(1).y;
        s2.XComp=s.parameter(1).val;
        s2.YComp=s.parameter(2).val;
        
end

