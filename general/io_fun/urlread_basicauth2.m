function [output,status] = urlread_basicauth2(urlChar,username,password,method,params)
%URLREAD_BASICAUTH2 urlread with username, password
%
% Works with https unlike urlread_basicauth.
%
% Slight modification of matlabs native urlread according to tips from the mathworks site.
% Implemented by Thijs Damsma
% 
%URLREAD_BASICAUTH2 Returns the contents of a URL as a string, with username, password
%   S = urlread_basicauth2('URL',username,password) reads the content at a URL into a string, S.  If the
%   server returns binary data, the string will contain garbage.
%
%   S = urlread_basicauth2('URL',username,password,'method',PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a 
%   cell array of param/value pairs.
%
%   [S,STATUS] = urlread_basicauth2(...) catches any errors and returns 1 if the file
%   downloaded successfully and 0 otherwise.
%
%   Examples:
%   s = urlread_basicauth2('http://www.mathworks.com','john','%$#%$#$%#')
%   s = urlread_basicauth2('ftp://ftp.mathworks.com/README','john','%$#%$#$%#')
%   s = urlread_basicauth2(['file:///' fullfile(prefdir,'history.m')],'john','%$#%$#$%#')
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLREAD, URLWRITE, URLREAD_BASICAUTH

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2011 The MathWorks, Inc.
%   $Revision: 7052 $ $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $

% This function requires Java.
if ~usejava('jvm')
   error(message('MATLAB:urlread:NoJvm'));
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
narginchk(3,5)
nargoutchk(0,2)
if ~ischar(urlChar)
    error('MATLAB:urlread:InvalidInput','The first input, the URL, must be a character array.');
end
if (nargin > 3) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
    error('MATLAB:urlread:InvalidInput','Second argument must be either "get" or "post".');
end

% Do we want to throw errors or catch them?
if nargout == 4
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
output = '';
status = 0;

% GET method.  Tack param/value to end of URL.
if (nargin > 3) && strcmpi(method,'get')
    if mod(length(params),2) == 1
        error('MATLAB:urlread:InvalidInput','Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(params)
        if (i == 1), separator = '?'; else separator = '&'; end
        param = char(java.net.URLEncoder.encode(params{i}));
        value = char(java.net.URLEncoder.encode(params{i+1}));
        urlChar = [urlChar separator param '=' value];
    end
end

% Create a urlConnection.
[urlConnection,errorid,errormsg] = urlreadwrite(mfilename,urlChar);
if isempty(urlConnection)
    if catchErrors, return
    else error(errorid,errormsg);
    end
end

% add authorization
encoder = sun.misc.BASE64Encoder;
encodedPassword = encoder.encode(double([username ':' password]));
myPwd = ['Basic ' encodedPassword.toCharArray'];
urlConnection.setRequestProperty('Authorization',myPwd);

% POST method.  Write param/values to server.
if (nargin > 3) && strcmpi(method,'post')
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

% Read the data from the connection.
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

function [urlConnection,errorid,errormsg] = urlreadwrite(fcn,urlChar)
%URLREADWRITE A helper function for URLREAD and URLWRITE.

%   Matthew J. Simoneau, June 2005
%   Copyright 1984-2011 The MathWorks, Inc.
%   $Revision: 7052 $ $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $

% Default output arguments.
urlConnection = [];
errorid = '';
errormsg = '';

% Determine the protocol (before the ":").
protocol = urlChar(1:min(find(urlChar==':'))-1);

% Try to use the native handler, not the ice.* classes.
switch protocol
    case 'http'
        try
            handler = sun.net.www.protocol.http.Handler;
        catch exception %#ok
            handler = [];
        end
    case 'https'
        try
            handler = sun.net.www.protocol.https.Handler;
        catch exception %#ok
            handler = [];
        end
    otherwise
        handler = [];
end

% Create the URL object.
try
    if isempty(handler)
        url = java.net.URL(urlChar);
    else
        url = java.net.URL([],urlChar,handler);
    end
catch exception %#ok
    errorid = ['MATLAB:' fcn ':InvalidUrl'];
    errormsg = 'Either this URL could not be parsed or the protocol is not supported.';
    return
end

% Get the proxy information using the MATLAB proxy API.
proxy = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(url); 

% Open a connection to the URL.
if isempty(proxy)
    urlConnection = url.openConnection;
else
    urlConnection = url.openConnection(proxy);
end

% build up the MATLAB User Agent
mlUserAgent = ['MATLAB R' version('-release') ' '  version('-description')];

% set User-Agent
urlConnection.setRequestProperty('User-Agent', mlUserAgent);
