function ColorMaps=ImportColorMaps(pth)

a=dir([pth 'settings' filesep 'colormaps' filesep '*.clrmap']);
nr=size(a,1);
 
for i=1:nr
 
    name=a(i).name;
 
    ColorMaps(i).Name=name(1:end-7);

    fid=fopen([pth 'settings' filesep 'colormaps' filesep name]);
 
    tx0=fgets(fid);
    tx0=fgets(fid);
    tx0=fgets(fid);
 
    for j=1:100
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
            k=size(v,1);
            if k==3
                ColorMaps(i).Val(j,2)=str2num(v{1});
                ColorMaps(i).Val(j,3)=str2num(v{2});
                ColorMaps(i).Val(j,4)=str2num(v{3});
                m=3;
            else
                ColorMaps(i).Val(j,1)=str2num(v{1});
                ColorMaps(i).Val(j,2)=str2num(v{2});
                ColorMaps(i).Val(j,3)=str2num(v{3});
                ColorMaps(i).Val(j,4)=str2num(v{4});
                m=4;
            end
        end
    end
 
    if m==3
        p=size(ColorMaps(i).Val,1);
        for j=1:p
            ColorMaps(i).Val(j,1)=(j-1)/(p-1);
        end
    end

    fclose(fid);
    
end
 
 
