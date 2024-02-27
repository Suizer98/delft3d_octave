function [output,status] = urlread_basicauth(urlChar,method,params);
%URLREAD_BASICAUTH Returns the contents of a PASSWORD-PROTECTED URL as a string.
%   S = URLREAD_BASICAUTH('URL') reads the content at a URL into a string, S.  If the
%   server returns binary data, the string will contain garbage.
%   Any password-protection in the url (http://user:password@...) will be 
%   detected and used in the call to the server, UNLIKE URLREAD which does
%   not offer any support for that, see:
%   http://www.mathworks.com/support/solutions/en/data/1-4EO8VK/index.html?solution=1-4EO8VK
%
%
%   S = urlread_basicauth('URL','method',PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a 
%   cell array of param/value pairs.
%
%   [S,STATUS] = urlread_basicauth(...) catches any errors and returns 1 if the file
%   downloaded successfully and 0 otherwise.
%
%   Examples:
%   s = urlread_basicauth('http://user:password@www.mathworks.com')
%   s = urlread_basicauth('ftp://user:password@ftp.mathworks.com/README')
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLREAD, URLWRITE, URLREAD_BASICAUTH2

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 8619 $ $Date: 2013-05-13 23:18:22 +0800 (Mon, 13 May 2013) $
%   adapted according to http://www.mathworks.com/support/solutions/en/data/1-4EO8VK/index.html?solution=1-4EO8VK
%   and code from Martin Verlaan, TU Delft.

% This function requires Java.
if ~usejava('jvm')
   error(message('MATLAB:urlread:NoJvm'));
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
error(nargchk(1,3,nargin))
error(nargoutchk(0,2,nargout))
if ~ischar(urlChar)
    error('MATLAB:urlread:InvalidInput','The first input, the URL, must be a character array.');
end
if (nargin > 1) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
    error('MATLAB:urlread:InvalidInput','Second argument must be either "get" or "post".');
end

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
output = '';
status = 0;

%% GET method.  Tack param/value to end of URL.
if (nargin > 1) && strcmpi(method,'get')
    if mod(length(params),2) == 1
        error('MATLAB:urlread:InvalidInput','Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(params)
        if (i == 1), separator = '?'; else, separator = '&'; end
        param = char(java.net.URLEncoder.encode(params{i}));
        value = char(java.net.URLEncoder.encode(params{i+1}));
        urlChar = [urlChar separator param '=' value];
    end
end

%% detect password in http url, remove it from url, and encode it
%  Code from Martin Verlaan, TU Delft.

   ii=findstr('@',urlChar); % in a url all other @ should have been replaced with %40.
   loginPassword='';
   if(length(ii)>0),
      loginPassword=java.lang.String(urlChar(8:(ii(end)-1)));
      urlChar=['http://',urlChar(ii(end)+1:end)];
   end;

%% Create a urlConnection.

   [urlConnection,errorid,errormsg] = urlreadwrite(mfilename,urlChar);
   if isempty(urlConnection)
       if catchErrors, return
       else error(errorid,errormsg);
       end
   end

%% detect password in http url and use this in the connection
%  Code from Martin Verlaan, TU Delft.

   if(length(loginPassword)>0),
      enc = sun.misc.BASE64Encoder();
      encodedPassword=['Basic ',char(enc.encode(loginPassword.getBytes())),'='];
      fprintf('Detected > encoded username:password "%s" > "%s" \n',char(loginPassword),encodedPassword);
   end;

%urlConnection.setRequestProperty('Authorization','Basic YWRtaW46YWRtaW4=');
 urlConnection.setRequestProperty('Authorization', encodedPassword)
   
%% POST method.  Write param/values to server.
if (nargin > 1) && strcmpi(method,'post')
    try
        urlConnection.setDoOutput(true);
        urlConnection.setRequestProperty( ...
            'Content-Type','application/x-www-form-urlencoded');
        printStream = java.io.PrintStream(urlConnection.getOutputStream);
        for i=1:2:length(params)
            if (i > 1), printStream.print('&'); end
            param = char(java.net.URLEncoder.encode(params{i}));
            value = char(java.net.URLEncoder.encode(params{i+1}));
            printStream.print([param '=' value]);
        end
        printStream.close;
    catch
        if catchErrors, return
        else error('MATLAB:urlread:ConnectionFailed','Could not POST to URL.');
        end
    end
end

%% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream;
    byteArrayOutputStream = java.io.ByteArrayOutputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,byteArrayOutputStream);
    inputStream.close;
    byteArrayOutputStream.close;
    output = native2unicode(typecast(byteArrayOutputStream.toByteArray','uint8'),'UTF-8');
catch
    if catchErrors, return
    else error('MATLAB:urlread:ConnectionFailed','Error downloading URL. Your network connection may be down or your proxy settings improperly configured.');
    end
end

status = 1;
