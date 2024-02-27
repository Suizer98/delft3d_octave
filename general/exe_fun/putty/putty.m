function varargout = putty(server,varargin)
%PUTTY - Turn Matlab into PuTTY
%
%This function allows you to use the Matlab Environment (IDE) for PuTTY 
%functionality (SSH server connections only).
%
%To connect to a server, the server/host along with a username and password
%is required. These can be supplied as input for the function (optionally).
%
%After a connection is established, you can use the Matlab Command Window
%for the connected server, as well as interacting and running selections
%(F9) of e.g. shell (*.sh) scripts within the Matlab environment.
%
%To return from the host/server, simply call 'exit' in the Command Window.
%
%Syntax (all input is <optional>):
%
%   putty(<'server name'>,<'username'>,<'quiet'>);
%
%Examples:
%
%   putty; % all required input is interatively asked for
%   putty('server_name');
%   putty('server_name','username');
%
%You can end any of the above examples with 'quiet', to suppress the
%message window (summary and explanation), e.g.:
%
%   putty('quiet')
%   putty('server_name','username','quiet')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%
%       freek.scheel@deltares.nl	
%
%       Boussinesqweg 1
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

if ~ispc(); error('This function only works for Windows systems, as it relies upon Windows Command Prompt functionality'); end;

if nargout>0
    for ii=1:nargout
        varargout{ii} = [];
    end
    disp(['You''ve specified ' num2str(nargout) ' output variable' deblank(char(min([nargout-1 1]).*115)) ', this will be ignored']);
    disp(' ');
end

return_func = 0;
quiet       = 0;
user        = '';
pass        = '';

if exist('server','var')~= 1
    disp('Please specify a server/host');
    server_c = inputdlg('Specify the server/host to connect to','Server?');
    if length(server_c)==0 || strcmp(server_c{1},'')
        disp('No server specified by the user')
        return
    else
        server = server_c{1};
    end
else
    if ~ischar(server)
        error('Unknown input, please specify strings only');
    else
        if strcmp(server,'quiet')
            quiet = 1;
            disp('Please specify a server/host');
            server_c = inputdlg('Specify the server/host to connect to','Server?');
            if length(server_c)==0 || strcmp(server_c{1},'')
                disp('No server specified by the user')
                return
            else
                server = server_c{1};
            end
        end
    end
end

if length(varargin) == 0
    %
elseif ~isempty(find(length(varargin) == 1:2))
    if isempty(find(cellfun(@ischar,varargin)==0))
        if length(varargin) == 1
            if strcmp(varargin{1},'quiet')
                quiet = 1;
            else
                user = varargin{1};
            end
        elseif length(varargin) == 2
            user = varargin{1};
            if strcmp(varargin{2},'quiet')
                quiet = 1;
            else
                warning('Second input argument is discarted, best not put your password here...')
            end
        end
    else
        error('Unknown input, please specify strings only');
    end
else
    error('Unknown input (too many input arguments)');
end

[user,pass] = uilogin('username',user,'dialogname',['Specify credentials for ' server]);

if strcmp(user,'')
    disp('No username supplied')
    return_func = 1;
end
if strcmp(pass,'')
    disp('No password supplied')
    return_func = 1;
end

if return_func
    return
end

if ~quiet
    warndlg({['Connecting to server ''' server ''' using the following credentials:'];[' '];['Username:   ' user];['Password:   ' repmat('*',1,length(pass))];[' '];['Matlab will now act as a command prompt for this server (you can use the command line and run selections of shell scripts using F9).'];[' '];['To exit from the server and return to matlab, simply call ''exit'' in the command line;'];[' '];['To hide this message in the future, simply call the function ''putty'' with a final input keyword ''quiet''']},['Connecting to server ''' server '''']);
end

total_name  = mfilename('fullpath');
folder_name = total_name(1:max(strfind(total_name,filesep))-1);
drive_name  = total_name(1,1:2);

system([drive_name ' & cd ' folder_name ' & plink ' user '@' server ' -pw ' pass]);

end