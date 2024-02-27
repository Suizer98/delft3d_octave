function [output] = url_readWeather(city)

url = ['http://www.weather-forecast.com/locations/' city '/forecasts/latest'];

html = urlread(url);
A = strread(html, '%s', 'delimiter', sprintf('\n'));

[fc] = cellfun(@findstr,A,cellstr(repmat('table class="forecasts"',size(A))),'Uniformoutput',0);
id_fc = find(~cellfun(@isempty,fc));

tel = 0;
for ii = [4:5:45]
    tel = tel + 1;
    strnow = A{id_fc(1)+ii};
    day{tel} = strnow(strfind(strnow,'dayname')+9:findstr(strnow,'</div')-1);
    strnow = A{id_fc(1)+ii+1};
    date{tel} = strnow(strfind(strnow,'dom')+5:findstr(strnow,'</div')-1);
    strnow = A{id_fc(1)+ii+2};
    time{tel} = strrep(strnow(strfind(strnow,'pname')+7:findstr(strnow,'</div')-1),'-<br/>','');
end

[sm] = cellfun(@strfind,A,cellstr(repmat('<th> Summary</th>',size(A))),'Uniformoutput',0);
id_sm = find(~cellfun(@isempty,sm));
for ii = 1:tel
    strnow = A{id_sm(1)+1+ii};
    summ{ii} = strnow(strfind(strnow,'<b>')+3:findstr(strnow,'</b')-1);
end

[mt] = cellfun(@findstr,A,cellstr(repmat('Max.&nbsp;Temp',size(A))),'Uniformoutput',0);
id_mt = find(~cellfun(@isempty,mt));

for ii = 1:tel
    strnow = A{id_mt(1)+1+ii};
    maxt(ii) = str2num(strnow(strfind(strnow,'"temp"')+7:findstr(strnow,'</span')-1));
end

datnow = now();

for ii = -1:3
    dates(find(strcmp(datestr(datnow+ii,8),day))) = round(datnow+ii);
end

for ii = 1:tel
    if strcmp(time{ii},'night')
        dates(ii) = dates(ii) + 21/24;
    elseif strcmp(time{ii},'morning')
        dates(ii) = dates(ii) + 6/24;
    elseif strcmp(time{ii},'afternoon')
        dates(ii) = dates(ii) + 12/24;
    end
end

for ii = 1:tel
    if strcmp(summ{ii},'cloudy')
        weather(ii) = 26;
    elseif strcmp(summ{ii},'clear')
        weather(ii) = 32;
    elseif strcmp(summ{ii},'some clouds')
        weather(ii) = 28;
    elseif strcmp(summ{ii},'rain shwrs')
        weather(ii) = 39;
    elseif strcmp(summ{ii},'light rain')
        weather(ii) = 12;
    elseif strcmp(summ{ii},'mod. rain')
        weather(ii) = 11;
    else
        weather(ii) = 0;
    end
end

output = [dates' maxt' weather'];