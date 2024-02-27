function txt=ReadTextFile(FileName)
 
fid=fopen(FileName);

eof=0;

k=0;

while ~eof

    tx0=fgets(fid);
    
    if tx0==-1
        eof=1;
        break;
    end
    
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if size(v0,1)>0
        if strcmp(tx0(1),'#')==0
            v=strread(tx0,'%q');
            nowords=size(v,1);
            for j=1:nowords
                k=k+1;
                txt{k}=v{j};
            end
            clear v;
        end
    end
end
 
fclose(fid);
