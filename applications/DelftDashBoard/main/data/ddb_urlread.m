function [output,status] = ddb_urlread(urlChar,method,params)
%URLREAD Returns the contents of a URL as a string.
%   S = URLREAD('URL') reads the content at a URL into a string, S.  If the
%   server returns binary data, the string will contain garbage.
%
%   S = URLREAD('URL','method',PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a 
%   cell array of param/value pairs.
%
%   [S,STATUS] = URLREAD(...) catches any errors and returns 1 if the file
%   downloaded successfully and 0 otherwise.
%
%   Examples:
%   s = urlread('http://www.mathworks.com')
%   s = urlread('ftp://ftp.mathworks.com/README')
%   s = urlread(['file:///' fullfile(prefdir,'history.m')])
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLWRITE.

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2011 The MathWorks, Inc.
%   $Revision: 9558 $ $Date: 2013-10-31 23:59:20 +0800 (Thu, 31 Oct 2013) $

mv = version('-release');
T = 100; %Timeout in ms

switch ( mv )
    case { '11', '12', '13' };
        error('Not supported on releases below R14.');
    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a', '2008b', '2009a', '2009b', '2010a', '2010b', '2011a', '2011b', '2012a'} % set Timeout for old Matlab versions
        % This function requires Java.
        if ~usejava('jvm')
           error(message('MATLAB:urlread:NoJvm'));
        end

        import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

        % Be sure the proxy settings are set.
        com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

        % Check number of inputs and outputs.
        narginchk(1,3)
        nargoutchk(0,2)
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

        % GET method.  Tack param/value to end of URL.
        if (nargin > 1) && strcmpi(method,'get')
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
        [urlConnection,errorid,errormsg] = ddb_urlreadwrite(mfilename,urlChar);
        urlConnection.setReadTimeout(T); % timeout in 100 ms
        if isempty(urlConnection)
            if catchErrors, return
            else error(errorid,errormsg);
            end
        end

        % POST method.  Write param/values to server.
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
    otherwise % Timeout natively supported from Matlab2012b
        varargin={'Timeout',T};
        [output,status] = urlread(urlChar,varargin{:});
end
