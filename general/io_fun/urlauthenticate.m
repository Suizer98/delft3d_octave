function url2 = urlauthenticate(url,user,passwd)
%urlauthenticate   insert user,passw into url
%
% urlauthenticate(url,user,passwd)
%
% Example: urlauthenticate(http:/www.whathever.nl,user,passwd)
% returns % http://USER:PASSWORD@www.whathever.nl
%
%See also: urlread_basicauth, urlread_basicauth2

if     (length(url) >7 && strcmpi(url(1:8),'https://'));ind = 9;prot = 'https://';
elseif (length(url) >6 && strcmpi(url(1:7),'http://' ));ind = 8;prot = 'http://';
elseif (length(url) >5 && strcmpi(url(1:6),'ftp://'  ));ind = 7;prot = 'ftp://';
end
    
url2 = ['https://',user,':',passwd,'@',url(ind:end)];
