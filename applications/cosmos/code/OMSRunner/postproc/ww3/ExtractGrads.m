function ExtractGrads(hm,m)

model=hm.models(m);

[hs0,header]=read_grads('ww3.ctl','HS');

[tp0,header]=read_grads('ww3.ctl','PEAKP');

[dp0,header]=read_grads('ww3.ctl','PEAKD');


% [wu0,header]=read_grads('ww3.ctl','WU');
% [wv0,header]=read_grads('ww3.ctl','WV');

t0=header.TDEF.vec(1);
dt=header.TDEF.vec(2);
n=header.TDEF.num;

ww3.lon=header.XDEF.vec;
ww3.lat=header.YDEF.vec;

% pars={'hs','tp'};

for i=1:n

    t=t0+(i-1)*dt;
    
    % Hs
    s=[];
    s.Parameter='hs';
    s.Time=t;
    s.x=ww3.lon;
    s.y=ww3.lat;
    hs=hs0(:,:,1,i);
    hs=hs';
    hs(hs<-999)=NaN;
    s.Val=hs;
    fout=[model.appendeddirmaps 'hs.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
    save(fout,'-struct','s','Parameter','Time','x','y','Val');


    % Tp
    s=[];
    s.Parameter='tp';
    s.Time=t;
    s.x=ww3.lon;
    s.y=ww3.lat;
    tp=tp0(:,:,1,i);
    tp=tp';
    tp(tp<-999)=NaN;
    s.Val=tp;
    fout=[model.appendeddirmaps 'tp.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
    save(fout,'-struct','s','Parameter','Time','x','y','Val');

    
%     % Wind
%     s=[];
%     s.parameter='wnd';
%     s.time=t;
%     s.x=ww3.lon;
%     s.y=ww3.lat;
%     wu=wu0(:,:,1,i);
%     wu=wu';
%     wu(wu<-999)=NaN;    
%     wv=wv0(:,:,1,i);
%     wv=wv';
%     wv(wv<-999)=NaN;
%     s.u=wu;
%     s.v=wv;
%     fout=[archdir 'appended' filesep 'maps' filesep 'wnd.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
%     save(fout,'-struct','s','Parameter','Time','x','y','u','v');
%     fout=[archdir filesep hm.cycStr filesep 'maps' filesep 'wnd.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
%     save(fout,'-struct','s','Parameter','Time','x','y','u','v');
    

%     dp=dp0(:,:,1,i);
%     dp=dp';
%     dp(dp<-999)=NaN;
% 
%     wu=wu0(:,:,1,i);
%     wu=wu';
%     wu(wu<-999)=NaN;
%     
%     wv=wv0(:,:,1,i);
%     wv=wv';
%     wv(wv<-999)=NaN;
%     
%     vecx=cos(dp).*hs;
%     vecy=sin(dp).*hs;
%     
%     ww3.hs=hs;
%     ww3.tp=tp;
%     ww3.Dp=dp;
%     ww3.VecX=vecx;
%     ww3.VecY=vecy;
%     ww3.windU=wu;
%     ww3.windV=wv;

    
end

s=[];
s.Parameter='hs';
s.Time=t0:dt:t0+(n-1)*dt;
ifirst=find(s.Time==hm.cycle);
s.Time=s.Time(ifirst:end);
s.X=ww3.lon;
s.Y=ww3.lat;
hs=squeeze(hs0(:,:,1,ifirst:end));
hs=permute(hs,[3 2 1]);
hs(hs<-999)=NaN;
s.Val=hs;
fout=[model.cycledirmaps 'hs.mat'];
save(fout,'-struct','s','Parameter','Time','X','Y','Val');

clear hs hs0

s=[];
s.Parameter='tp';
s.Time=t0:dt:t0+(n-1)*dt;
ifirst=find(s.Time==hm.cycle);
s.Time=s.Time(ifirst:end);
s.X=ww3.lon;
s.Y=ww3.lat;
tp=squeeze(tp0(:,:,1,ifirst:end));
tp=permute(tp,[3 2 1]);
tp(tp<-999)=NaN;
s.Val=tp;
fout=[model.cycledirmaps 'tp.mat'];
save(fout,'-struct','s','Parameter','Time','X','Y','Val');
