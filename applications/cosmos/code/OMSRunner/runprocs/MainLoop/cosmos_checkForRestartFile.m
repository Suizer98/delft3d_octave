function [trst,rstfil]=cosmos_checkForRestartFile(hm,m,t0,tspinup,tp)

trst=[];
rstfil=[];

dr=hm.models(m).dir;

switch lower(tp)
    case{'ww3'}
        rstdir=[dr 'restart' filesep ];
        rstfiles=dir([rstdir 'restart.*']);
    case{'delft3dflow'}
        rstdir=[dr 'restart' filesep 'tri-rst' filesep ''];
        rstfiles=dir([rstdir 'tri-rst.*']);
    case{'delft3dwave'}
        rstdir=[dr 'restart' filesep 'hot' filesep ''];
        rstfiles=dir([rstdir 'hot_1_*']);
end

nrst=length(rstfiles);

if nrst>0
    for j=1:nrst

        fname=rstfiles(j).name(1:end-4);

        switch lower(tp)
            case{'ww3'}
                dt=fname(13:end);
            case{'delft3dflow'}
                dt=fname(end-14:end);
            case{'delft3dwave'}
                dt=fname(7:end);
        end
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if rsttime<=t0 && rsttime>=t0-tspinup
            trst=rsttime;
            rstfil=fname;
        end

    end
end
