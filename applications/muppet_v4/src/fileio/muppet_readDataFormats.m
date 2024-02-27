function dateformats=muppet_readDataFormats(fname)

fid=fopen(fname,'r');

n=0;
while 1
    tx=fgets(fid);    
    if ~ischar(tx)
        break
    end
    tx=deblank2(tx);
    if ~isempty(tx)
        if ~strcmpi(tx,'#') % comment
            n=n+1;
            dateformats{n}=tx;
        end
    end
end

fclose(fid);
