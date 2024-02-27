function txt=ImportText(pathname,filename)

fid=fopen([pathname filename]);
 
k=0;
for j=1:1000
    tx0{j}=fgetl(fid);
    if and(ischar(tx0{j}), size(tx0{j}>0))
        ilast=j;
    end
end
for j=1:ilast
    txt{j}=tx0{j};
end

fclose(fid);
