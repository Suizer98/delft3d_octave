function saveDisFile(fname,reftime,discharges)

nr=1;

Info.Check='OK';
Info.FileName=fname;

Info.NTables=nr;

for n=1:nr
    
    Info.Table(n).Name=['Discharge : ' num2str(n)];
    Info.Table(n).Contents=discharges(n).type;
    Info.Table(n).Location=discharges(n).name;
    Info.Table(n).TimeFunction='non-equidistant';
    itd=str2double(datestr(reftime,'yyyymmdd'));
    Info.Table(n).ReferenceTime=itd;
    Info.Table(n).TimeUnit='minutes';
    Info.Table(n).Interpolation=discharges(n).interpolation;
    Info.Table(n).Parameter(1).Name='time';
    Info.Table(n).Parameter(1).Unit='[min]';
    t=discharges(n).timeSeriesT;
    t=(t-reftime)*1440;
    Info.Table(n).Data(:,1)=t;
    Info.Table(n).Parameter(2).Name='flux/discharge rate';
    Info.Table(n).Parameter(2).Unit='[m3/s]';
    Info.Table(n).Data(:,2)=discharges(n).timeSeriesQ;

    k=2;

    if isfield(discharges(n),'salinity')
        k=k+1;
        Info.Table(n).Parameter(k).Name='Salinity';
        Info.Table(n).Parameter(k).Unit='[ppt]';
        Info.Table(n).Data(:,k)=discharges(n).salinity.timeSeries;
    end
    if isfield(discharges(n),'temperature')
        k=k+1;
        Info.Table(n).Parameter(k).Name='Temperature';
        Info.Table(n).Parameter(k).Unit='[C]';
        Info.Table(n).Data(:,k)=discharges(n).temperature.timeSeries;
    end
    if isfield(discharges(n),'sediment')
        for i=1:length(discharges(n).sediment)
            k=k+1;
            Info.Table(n).Parameter(k).Name=discharges(n).sediment(i).name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=discharges(n).sediment(i).timeSeries;
        end
    end
    if isfield(discharges(n),'tracer')
        for i=1:1:length(discharges(n).tracer)
            k=k+1;
            Info.Table(n).Parameter(k).Name=discharges(n).tracer(i).name;
            Info.Table(n).Parameter(k).Unit='[kg/m3]';
            Info.Table(n).Data(:,k)=discharges(n).tracer(i).timeSeries;
        end
    end
    if strcmpi(discharges(n).type,'momentum')
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow magnitude';
        Info.Table(n).Parameter(k).Unit='[m/s]';
        Info.Table(n).Data(:,k)=discharges(n).timeSeriesM;
        k=k+1;
        Info.Table(n).Parameter(k).Name='flow direction';
        Info.Table(n).Parameter(k).Unit='[deg]';
        Info.Table(n).Data(:,k)=discharges(n).timeSeriesM;
    end
    
    npar=length(Info.Table(n).Parameter);
    for i=1:npar
        quant=deblank(Info.Table(n).Parameter(i).Name);
        quant=[quant repmat(' ',1,20-length(quant))];
        Info.Table(n).Parameter(i).Name=quant;
    end
    
end
ddb_bct_io('write',fname,Info);

