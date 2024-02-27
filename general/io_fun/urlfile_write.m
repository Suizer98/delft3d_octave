function urlfile_write(fname,url,date)
%urlfile_write write url to Intern Explorer *.url shortcut file
%
% urlfile_write(fname,url)
% urlfile_write(fname,url,access_date)
%
%See also: urlencode

%% http://www.fmtz.com/formats/url-file-format/article
% http://www.lyberty.com/encyc/articles/tech/dot_url_format_-_an_unofficial_guide.html
% http://microformats.org/wiki/url-formats
%
% [InternetShortcut]
% URL=http://www.someaddress.com/
% WorkingDirectory=C:\WINDOWS\
% ShowCommand=7
% IconIndex=1
% IconFile=C:\WINDOWS\SYSTEM\url.dll
% Modified=20F06BA06D07BD014D

    fid = fopen(fname, 'w+');
    fprintf(fid,'[InternetShortcut]\r\n'); % window eol (as *.url is IE thing)
    fprintf(fid,'URL=%s\r\n',url);
    if nargin > 2
        
%    #include <winbase.h>
%    #include <winnt.h>
%    #include <time.h>
% 
%    void UnixTimeToFileTime(time_t t, LPFILETIME pft)
%    {
%      // Note that LONGLONG is a 64-bit value
%      LONGLONG ll;
% 
%      ll = Int32x32To64(t, 10000000) + 116444736000000000;
%      pft->dwLowDateTime = (DWORD)ll;
%      pft->dwHighDateTime = ll >> 32;
%    }        
    fprintf(fid,'Modified=%s\r\n',datestr(date,'yyyy-mm-ddTHH:MM:SS')); % need to http://support.microsoft.com/kb/167296
    end
    fclose(fid);