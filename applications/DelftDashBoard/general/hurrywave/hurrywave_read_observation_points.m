function points=hurrywave_read_observation_points(filename)

fileID      = fopen(filename,'r');
%dataArray   = textscan(fileID, '%f%f%q%[^\n\r]', 'Delimiter', ' "''', 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
dataArray   = textscan(fileID, '%f%f%q%[^\n\r]', 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
fclose(fileID);
x           = dataArray{:, 1};
y           = dataArray{:, 2};
name        = dataArray{:, 3};

points.x=x;
points.y=y;
points.length=length(points.x);
points.names=name;
points.handle=[];

