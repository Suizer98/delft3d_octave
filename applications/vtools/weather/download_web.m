%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17455 $
%$Date: 2021-08-15 21:42:18 +0800 (Sun, 15 Aug 2021) $
%$Author: chavarri $
%$Id: download_web.m 17455 2021-08-15 13:42:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/weather/download_web.m $
%

function err=download_web(url_down,fpath_out,varargin)

parin=inputParser;

% addOptional(parin,'chrome','c:\Program Files (x86)\Google\Chrome\Application\chrome.exe');
addOptional(parin,'chrome','c:\Program Files\Google\Chrome\Application\chrome.exe');

parse(parin,varargin{:})

fpath_chrome=parin.Results.chrome;

if exist(fpath_chrome,'file')~=2
    err=true;
    return
end
% "c:\Program Files (x86)\Google\Chrome\Application\new_chrome.exe" --headless --dump-dom https://www.buienradar.nl/weer/delft/nl/2757345/14daagse > c:\Users\chavarri\Downloads\file.html
cmd_down=sprintf('"%s" --headless --dump-dom %s > %s',fpath_chrome,url_down,fpath_out);

fpath_bat='c:\Users\chavarri\Downloads\dw.bat';
fid=fopen(fpath_bat,'w');
fprintf(fid,'%s \n',cmd_down);
fclose(fid);
status=system(fpath_bat);
err=false;
if status~=0
    err=true;
end

%for some reason this does not work
% system(cmd_down);
% dos(cmd_down)

end