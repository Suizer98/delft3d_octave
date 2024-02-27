function [output,status] = urlreadfix(urlChar,method,params,cookies)
%URLREADFIX Wrapper for URLREAD.
% Runs URLREAD and if it returns an error, then trying to download file
% with 'wget' and process as local file. This is a workaround for old
% Matlab version, which does not support HTTPS.
% 
% See: URLREAD

% $Id: urlreadfix.m 15380 2019-05-01 16:12:22Z omouraenko.x $

% Oleg Mouraenko, 12/05/2016

if (nargin > 1) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
    error('MATLAB:urlreadfix:InvalidInput','Second argument must be either "get" or "post".');
end

if ~exist('method','var')
    method = 'get';
end
    
if ~exist('params','var')
    params = {};
end

if exist('cookies','var')
    cookiesChar = sprintf('--load-cookies "%s"',cookies);
else
    cookiesChar = '';
end

status = 0;
output = '';

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

try
    if isempty(cookiesChar)
        output = urlread(urlChar,method,params);
    else
        error('Cookies are specified. Using wget.');
    end
catch ME
    isurl = ~isempty(regexpi(urlChar, '^(h|f)tt?ps?://'));
    if isurl
        
        % param/value
        dataChar = '';
        if (nargin > 1)
            if mod(length(params),2) == 1
                error('MATLAB:urlreadfix:InvalidInput','Invalid parameter/value pair arguments.');
            end
            for i = 1:2:length(params)
                if (i == 1), separator = ''; else separator = '&'; end
                param = char(java.net.URLEncoder.encode(params{i}));
                value = char(java.net.URLEncoder.encode(params{i+1}));
                dataChar = [dataChar separator param '=' value];
            end
        end
        
        % save to local file
        tmpFileOut = fullfile(pwd,sprintf('tmp_%s_out.dat',mfilename));
        tmpFileLog = fullfile(pwd,sprintf('tmp_%s_log.dat',mfilename));
        switch lower(method)
            case 'get'
                cmd = sprintf('wget %s "%s" -O "%s" -o "%s"',cookiesChar,[urlChar '?' dataChar],tmpFileOut,tmpFileLog);
            case 'post'
                cmd = sprintf('wget %s --post-data="%s" "%s" -O "%s" -o "%s"',cookiesChar,dataChar,urlChar,tmpFileOut,tmpFileLog);
        end
        [s,~] = system(cmd);
        if s==0
            output = urlread(['file:///' tmpFileOut]);
            rmfile(tmpFileOut);
            rmfile(tmpFileLog);
        else
            if catchErrors, return
            else
                error('\n%s: failed command\n   %s\nFailed download.',upper(mfilename),cmd);
            end
        end
    else
        if catchErrors, return
        else rethrow(ME)
        end
    end
end

status = 1;