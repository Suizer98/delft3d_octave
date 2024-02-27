function GetWW3(fin,fout)

[hs0,header]=read_grads(fin,'HS');
[tp0,header]=read_grads(fin,'PEAKP');
[dp0,header]=read_grads(fin,'PEAKD');
[wu0,header]=read_grads(fin,'WU');
[wv0,header]=read_grads(fin,'WV');

t0=header.TDEF.vec(1);
dt=header.TDEF.vec(2);
n=header.TDEF.num;

ww3.lon=header.XDEF.vec;
ww3.lat=header.YDEF.vec;

for i=1:n

    t=t0+(i-1)*dt;
    
    hs=hs0(:,:,1,i);
    hs=hs';
    hs(hs<-999)=NaN;

    tp=tp0(:,:,1,i);
    tp=tp';
    tp(tp<-999)=NaN;

    dp=dp0(:,:,1,i);
    dp=dp';
    dp(dp<-999)=NaN;

    wu=wu0(:,:,1,i);
    wu=wu';
    wu(wu<-999)=NaN;
    
    wv=wv0(:,:,1,i);
    wv=wv';
    wv(wv<-999)=NaN;
    
    vecx=cos(dp).*hs;
    vecy=sin(dp).*hs;
    
    ww3.t(i)=t;
    ww3.output(i).Hs=hs;
    ww3.output(i).Tp=tp;
    ww3.output(i).Dp=dp;
    ww3.output(i).VecX=vecx;
    ww3.output(i).VecY=vecy;
    ww3.output(i).WindU=wu;
    ww3.output(i).WindV=wv;

end
save(fout,'ww3');
