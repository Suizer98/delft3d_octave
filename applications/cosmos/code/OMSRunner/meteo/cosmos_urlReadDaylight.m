function [output] = cosmos_urlReadDaylight

url = ['http://zonsopgang.info/'];

html = urlread(url);
A = strread(html, '%s', 'delimiter', sprintf('\n'));

[fc] = cellfun(@findstr,A,cellstr(repmat('span class="vandaag "',size(A))),'Uniformoutput',0);
id_fc = find(~cellfun(@isempty,fc));
strnow = A{id_fc(1)};

idvandaag = strfind(strnow,'vandaag');
ids1 = strfind(strnow,'>');
ids2 = strfind(strnow,'<');
idstart = ids1(min(find(ids1>idvandaag)));
idend = ids2(min(find(ids2>idvandaag)));
daylight = strnow(idstart+1:idend-1);

sunup = datenum(0,0,0,str2num(daylight(1:2)),str2num(daylight(4:5)),00);
sundown = datenum(0,0,0,str2num(daylight(9:10)),str2num(daylight(12:13)),00);

output = [sunup sundown];