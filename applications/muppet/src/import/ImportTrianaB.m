function DataProperties=ImportTrianaB(DataProperties,i)
 
filename=[DataProperties(i).PathName DataProperties(i).FileName];
 
fid=fopen(filename);
 
DataProperties(i).Type='Bar';

nostat=0;
for j=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
        if size(v0,1)>3
            if strcmp(v0{2},'Station')
                loc='';
                for k=4:size(v0,1)
                    loc=strcat([loc ' ' v0{k}]);
                end
                loc=loc(2:end);
                if strcmp(loc,DataProperties(i).Location)
                    for n=1:13
                        tx0=fgets(fid);
                        v0=strread(tx0,'%q');
                        if lower(v0{1}(1))=='w'
                            tx0=fgets(fid);
                            v0=strread(tx0,'%q');
                            norow=str2num(v0{1});
                            nocol=str2num(v0{2});
                            for k=1:norow
                                tx0=fgets(fid);
                                v0=strread(tx0,'%q');
                                DataProperties(i).XTickLabel{k}=v0{10};
                                DataProperties(i).x(k)=k;
                                DataProperties(i).y(k)=str2num(v0{DataProperties(i).Column});
                            end
                        end
                    end
                end
            end
        end
    end
end

DataProperties(i).TC='c';

fclose(fid);

