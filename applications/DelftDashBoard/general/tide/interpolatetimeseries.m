function zout=interpolatetimeseries(tin,zin,tout,varargin)

maxgap=60;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'maximumgap'} % maximum gap in minutes
                maxgap=varargin{ii+1};
        end
    end
end

dtmax=maxgap/1440;

if size(tin,1)>1
    tin=tin';
    zin=zin';
end

%% Make sure that time vector is increasing
tmax=1e-9;
for it=2:length(tin)
    if tin(it)<=tmax
        tin(it)=NaN;
    end
    tmax=max(tmax,tin(it));
end
%tin(tin<tmax)=NaN;
zin=zin(~isnan(tin));
tin=tin(~isnan(tin));

dtvec=tin(2:end)-tin(1:end-1);
dzvec=zin(2:end)-zin(1:end-1);

t=zeros(1,length(tin)*2-1);
t(t==0)=NaN;
z=t;

tinterm=tin(1:end-1)+0.5*dtvec;
zinterm=zin(1:end-1)+0.5*dzvec;
zinterm(dtvec>dtmax+1e-5)=NaN;

t(1:2:end)=tin;
z(1:2:end)=zin;
t(2:2:end-1)=tinterm;
z(2:2:end-1)=zinterm;

zout=interp1(t,z,tout);
