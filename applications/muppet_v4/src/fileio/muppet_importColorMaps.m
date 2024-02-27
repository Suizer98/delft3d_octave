function colormaps=muppet_importColorMaps(pth)

a=dir([pth '*.clrmap']);
nr=length(a);
 
for i=1:nr
 
    name=a(i).name;
 
    colormaps(i).name=name(1:end-7);

    fid=fopen([pth filesep name]);
 
    tx0=fgets(fid);
    tx0=fgets(fid);
    % name string
    f=strread(tx0,'%s','delimiter','=');
    colormaps(i).name=f{2};
    tx0=fgets(fid);
 
    for j=1:100
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
            k=size(v,1);
            if k==3
                colormaps(i).val(j,2)=str2num(v{1});
                colormaps(i).val(j,3)=str2num(v{2});
                colormaps(i).val(j,4)=str2num(v{3});
                m=3;
            else
                colormaps(i).val(j,1)=str2num(v{1});
                colormaps(i).val(j,2)=str2num(v{2});
                colormaps(i).val(j,3)=str2num(v{3});
                colormaps(i).val(j,4)=str2num(v{4});
                m=4;
            end
        end
    end
 
    if m==3
        p=size(colormaps(i).val,1);
        for j=1:p
            colormaps(i).val(j,1)=(j-1)/(p-1);
        end
    end

    fclose(fid);
    
end
 
 
