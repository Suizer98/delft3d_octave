clear all;close all;

outdir='E:\work\OperationalModelSystem\SoCalCoastalHazards\scenarios\forecasts_old\models\northamerica\southcalifornia\results\output\';
runid='sca';

archdir='E:\work\OperationalModelSystem\SoCalCoastalHazards\scenarios\forecasts_old\models\northamerica\southcalifornia\archive\maps\';


dt=hm.models(m).mapTimeStep;

if ~exist([outdir 'wavm-' runid '.dat'],'file')
   killAll;
else
fid = qpfopen([outdir 'wavm-' runid '.dat']);
times = qpread(fid,1,'hsig wave height','times');

nt=length(times);
t0=times(1);
t1=times(end);

for t=t0:(dt/24):t1;
    it=find(times==t);
    hs = qpread(fid,1,'hsig wave height','griddata',it,0,0);
    s=[];
    s.parameter='hs';
    s.time=t;
    s.x=hs.X;
    s.y=hs.Y;
    s.Val=hs.Val;
    fout=[dr 'archive\timeseries\maps\hs.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
    save(fout,'-struct','s','Parameter','Time','x','y','Val');
end

for t=t0:(dt/24):t1;
    it=find(times==t);
    tp = qpread(fid,1,'smoothed peak period','griddata',it,0,0);
    s=[];
    s.parameter='tp';
    s.time=t;
    s.x=tp.X;
    s.y=tp.Y;
    s.Val=tp.Val;
    fout=[archdir 'tp.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
    save(fout,'-struct','s','Parameter','Time','x','y','Val');
end



s=load([archdir 'hs.' datestr(t,'yyyymmdd.HHMMSS') '.mat']);
