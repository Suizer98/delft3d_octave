function val=muppet_extractmatrix(parameter,fld,sz,timestep,istation,m,n,k)

nind=0;
val=[];
if isfield(parameter,fld)
    if ~isempty(parameter.(fld))
        if sz(1)>0
            nind=nind+1;
            str{nind}='timestep';
        end
        if sz(2)>0
            nind=nind+1;
            str{nind}='istation';
        end
        if sz(3)>0
            nind=nind+1;
            str{nind}='m';
        end
        if sz(4)>0
            nind=nind+1;
            str{nind}='n';
        end
        if sz(5)>0
            nind=nind+1;
            str{nind}='k';
        end
        sind='';
        for ii=1:nind
            sind=[sind str{ii} ','];
        end
        sind=sind(1:end-1);
        if isempty(sind)
            evalstr=['val=squeeze(parameter.(fld));'];
        else
            evalstr=['val=squeeze(parameter.(fld)(' sind '));'];
        end
        eval(evalstr);
    end
end
