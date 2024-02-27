function saveSrcFile(fname,discharges)

fid=fopen(fname,'w');

nr=length(discharges);

for i=1:nr

    name=deblank(discharges(i).name);
    if strcmpi(discharges(i).interpolation,'linear')
        cinterp='Y';
    else
        cinterp='N';
    end

    m=num2str(discharges(i).M);
    n=num2str(discharges(i).N);
    k=num2str(discharges(i).K);

    m=[repmat(' ',1,4-length(m)) m];
    n=[repmat(' ',1,4-length(n)) n];
    k=[repmat(' ',1,4-length(k)) k];
    
    ctype='';
    cmout='';
    cnout='';
    ckout='';

    switch lower(discharges(i).type)
        case{'walking'}
            ctype=' W';
        case{'inout'}
            ctype=' P';
            cmout=num2str(discharges(i).mOut);
            cnout=num2str(discharges(i).nOut);
            ckout=num2str(discharges(i).kOut);
            cmout=[repmat(' ',1,4-length(cmout)) cmout];
            cnout=[repmat(' ',1,4-length(cnout)) cnout];
            ckout=[repmat(' ',1,4-length(ckout)) ckout];
    end
    
    fprintf(fid,'%s\n',[name repmat(' ',1,21-length(name)) cinterp m n k ctype ' ' cmout ' ' cnout ' ' ckout]);

end

fclose(fid);

