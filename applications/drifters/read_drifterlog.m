function [hour,minute,second,lat,lon,height,velocity] = read_drifterlog(fname)
fid = fopen(fname,'r');
data1 = {};
data2 = {};
l1 = 1;
j = 0;
l1 = fgetl(fid);
l2 = fgetl(fid);
while l1 ~= -1
    if rem(j,1000) == 0
        fprintf(['line ' int2str(j) '\n'])
    end
    j = j+1;
    i1 = [1 findstr(l1,',') length(l1)+1];
    i2 = [1 findstr(l2,',') length(l2)+1];
    for i = 1:length(i1)-1
        if i1(i+1) == i1(i)+1
            data1{j,i} = '';
        else
            data1{j,i} = l1(i1(i)+1:i1(i+1)-1);
        end
    end
    for i = 1:length(i2)-1
        if i2(i+1) == i2(i)+1
            data2{j,i} = '';
        else
            data2{j,i} = l2(i2(i)+1:i2(i+1)-1);
        end
    end
    l1 = fgetl(fid);
    l2 = fgetl(fid);
end
fclose(fid);

nanind = strcmpi(data1,'');
data1(nanind) = {'nan'};
nanind = strcmpi(data2,'');
data2(nanind) = {'nan'};
time = char(data1(:,2));
hour = str2num(time(:,1:2));
minute = str2num(time(:,3:4));
second = str2num(time(:,5:6));
lat = str2num(char(data1(:,3)));
lon = str2num(char(data1(:,5)));
sind = strcmpi(data1(:,4),'S');
wind = strcmpi(data1(:,6),'W');
lat(sind) = -lat(sind);
lon(wind) = -lon(wind);
height = str2num(char(data1(:,9)));
velocity = str2num(char(data2(:,8)));
end