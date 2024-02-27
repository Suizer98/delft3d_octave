clear variables;close all;

url='http://www.ndbc.noaa.gov/activestations.xml';
ddb_urlwrite(url,'activestations.xml');
v = xml_parseany(fileread('activestations.xml'));
for i=1:length(v.station)
    disp(v.station{i}.ATTRIBUTE.pgm);
    disp(v.station{i}.ATTRIBUTE.owner);
%     x(i)=str2double()
%     if strcmpi(v.station{i}.ATTRIBUTE.pgm,'NOS/CO-OPS')
% %        v.station{i}.ATTRIBUTE
%     end
end
