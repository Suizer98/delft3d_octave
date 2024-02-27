function ConvertBct2XBeach(fin,fout,trefxbeach)

% ConvertBct2XBeach(fin,fout,morfac,trefxbeach)
%
% fin    : bct file
% fout   : xbeach boundary file
% morfac : MORFAC
% trefxbeach : reference time xbeach

Info=ddb_bct_io('read',fin);

itd=Info.Table(1).ReferenceTime;
itd=datenum(num2str(itd),'yyyymmdd');

t=itd+Info.Table(1).Data(:,1)/1440;
TimeSeriesT=t;
TimeSeriesA=Info.Table(1).Data(:,2);
TimeSeriesB=Info.Table(1).Data(:,3);

%TimeSeriesT=(TimeSeriesT-trefxbeach)*86400/morfac;
TimeSeriesT=(TimeSeriesT-trefxbeach)*86400;

t0=find(TimeSeriesT>=0);
it0=t0(1);

dat(:,1)=TimeSeriesT(it0:end);
dat(:,2)=TimeSeriesA(it0:end);
dat(:,3)=TimeSeriesB(it0:end);

save(fout,'dat','-ascii');

%parfile=[tmpdir 'params.txt'];
%findreplace(parfile,'TIDELENKEY',num2str(size(dat,1)));
