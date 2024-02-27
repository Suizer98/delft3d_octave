clear variables;close all;

% url='http://www.ndbc.noaa.gov/activestations.xml';
% urlwrite(url,'activestations.xml');
v = xml_parseany(fileread('activestations.xml'));
for i=1:length(v.station)
    disp(v.station{i}.ATTRIBUTE.pgm);
    disp(v.station{i}.ATTRIBUTE.owner);
%     x(i)=str2double()
%     if strcmpi(v.station{i}.ATTRIBUTE.pgm,'NOS/CO-OPS')
% %        v.station{i}.ATTRIBUTE
%     end
end


% Dart buoys
load('ndbc.mat');
s.DatabaseName='DART';
s.Institution='NOAA National Data Buoy Center and Participators in Data Assembly Center';
s.URL='http://dods.ndbc.noaa.gov/thredds/dodsC/data/dart/';
k=0;
s.Name=[];
s.IDCode=[];
s.x=[];
s.y=[];
s.Parameters=[];

for i=1:length(v.station)
%    disp(v.station{i}.ATTRIBUTE.pgm);
%    disp(v.station{i}.ATTRIBUTE.owner);
    if strcmpi(v.station{i}.ATTRIBUTE.pgm,'tsunami')
        k=k+1;
        s.Name{k}=v.station{i}.ATTRIBUTE.name;
        s.IDCode{k}=v.station{i}.ATTRIBUTE.id;
        s.x(k)=str2double(v.station{i}.ATTRIBUTE.lon);
        s.y(k)=str2double(v.station{i}.ATTRIBUTE.lat);
        s.Parameters(k).Name{1}='height';
        s.Parameters(k).Status(1)=1;
    end
%     x(i)=str2double()
%     if strcmpi(v.station{i}.ATTRIBUTE.pgm,'NOS/CO-OPS')
% %        v.station{i}.ATTRIBUTE
%     end
end
