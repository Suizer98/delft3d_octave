function dateformats=muppet_readDateFormats(fname)

fid=fopen(fname,'r');

n=0;
while 1
    tx=fgets(fid);    
    if ~ischar(tx)
        break
    end
    tx=deblank2(tx);
    if ~isempty(tx)
        if ~strcmpi(tx(1),'#') % comment
            n=n+1;
            if strcmpi(tx(1),'"')
                tx=tx(2:end);
            end
            if strcmpi(tx(end),'"')
                tx=tx(1:end-1);
            end
            dateformats{n}=tx;
        end
    end
end

fclose(fid);
