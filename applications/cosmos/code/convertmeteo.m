clear variables;close all;

name='ncep_gfs_analysis';
drori='P:\z4394-micore\OperationalModelSystem\SoCalCoastalHazards\scenarios\year2009\meteo\';
drnew='F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\june2009\meteo\';

t0=datenum(2009,5,15);
t1=datenum(2009,7,1);

flist=dir([drori name filesep '*.mat']);
dr=[drnew name filesep];

for i=1:length(flist)
    fname=flist(i).name;
    tstr=fname(end-17:end-4);
    t=datenum(tstr,'yyyymmddHHMMSS');
    if t>=t0 && t<=t1
        
        s0=load([drori name filesep fname]);

        s=s0;
        s=rmfield(s,'v');
        s=rmfield(s,'p');
        fnamenew=[name '.u.' datestr(t,'yyyymmddHHMMSS') '.mat'];        
        save([dr fnamenew],'-struct','s');
        
        s=s0;
        s=rmfield(s,'u');
        s=rmfield(s,'p');
        fnamenew=[name '.v.' datestr(t,'yyyymmddHHMMSS') '.mat'];        
        save([dr fnamenew],'-struct','s');

        s=s0;
        s=rmfield(s,'u');
        s=rmfield(s,'v');
        fnamenew=[name '.p.' datestr(t,'yyyymmddHHMMSS') '.mat'];        
        save([dr fnamenew],'-struct','s');
        
    end
end
