function ww3_grads2mat(fin,fout)

[hs0,header]=read_grads(fin,'HS');
[tp0,header]=read_grads(fin,'PEAKP');
[dp0,header]=read_grads(fin,'PEAKD');
[wu0,header]=read_grads(fin,'WU');
[wv0,header]=read_grads(fin,'WV');

t0=header.TDEF.vec(1);
dt=header.TDEF.vec(2);
n=header.TDEF.num;

x=header.XDEF.vec;
y=header.YDEF.vec;

s.parameters(1).parameter.name='Hs';
s.parameters(1).parameter.time=[];
s.parameters(1).parameter.x=x;
s.parameters(1).parameter.y=y;
s.parameters(1).parameter.val=zeros(n,length(y),length(x));
s.parameters(1).parameter.quantity='scalar';
s.parameters(1).parameter.size=[n 0 length(y) length(x) 0];

s.parameters(2).parameter.name='Tp';
s.parameters(2).parameter.time=[];
s.parameters(2).parameter.x=x;
s.parameters(2).parameter.y=y;
s.parameters(2).parameter.val=zeros(n,length(y),length(x));
s.parameters(2).parameter.quantity='scalar';
s.parameters(2).parameter.size=[n 0 length(y) length(x) 0];

s.parameters(3).parameter.name='Dp';
s.parameters(3).parameter.time=[];
s.parameters(3).parameter.x=x;
s.parameters(3).parameter.y=y;
s.parameters(3).parameter.val=zeros(n,length(y),length(x));
s.parameters(3).parameter.quantity='scalar';
s.parameters(3).parameter.size=[n 0 length(y) length(x) 0];

s.parameters(4).parameter.name='wind';
s.parameters(4).parameter.time=[];
s.parameters(4).parameter.x=x;
s.parameters(4).parameter.y=y;
s.parameters(4).parameter.u=zeros(n,length(y),length(x));
s.parameters(4).parameter.v=zeros(n,length(y),length(x));
s.parameters(4).parameter.quantity='vector';
s.parameters(4).parameter.size=[n 0 length(y) length(x) 0];

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
    
    s.parameters(1).parameter.time(i)=t;
    s.parameters(1).parameter.val(i,:,:)=hs;

    s.parameters(2).parameter.time(i)=t;
    s.parameters(2).parameter.val(i,:,:)=tp;

    s.parameters(3).parameter.time(i)=t;
    s.parameters(3).parameter.val(i,:,:)=dp;

    s.parameters(4).parameter.time(i)=t;
    s.parameters(4).parameter.u(i,:,:)=wu;
    s.parameters(4).parameter.v(i,:,:)=wv;
    
end

save(fout,'-struct','s');
