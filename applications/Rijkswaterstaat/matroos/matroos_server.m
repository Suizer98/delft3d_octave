function url = matroos_server(varargin)
%MATROOS_SERVER     retrieve url of a Rijkswaterstaat MATROOS database
%
%   url = matroos_server()
%
% returns matroos base url incl user:password authentication, e.g.
%
%    http://username:password@matroos.deltares.nl
%
% Adapt this function to contain your own server & username and password
% and place it in your local Matlab path.
%
%See also: MATROOS

   user   = '???????????'
   passwd = '???????????';
   url    = 'matroos.deltares.nl';
   
   try
   [user, passwd, url]=matroos_user_password(); % please make this local function to save your password, and do not add to OpenEarthTools.
   
   % ---------------------------
   % function [user, passwd, url]=matroos_user_password
   % %MATROOS_USER_PASSWORD  returns my matroos username and password
   % 
   %    user   = 'MyName';
   %    passwd = 'P@SsW0rD';
   %    url    = 'matroos.deltares.nl';
   % ---------------------------
   
   catch
   error(['MATROOS_SERVER: Please request a username/password at matroos.deltares.nl and substitute that in ',mfilename('fullfile')])
   end

%% urlread_basicauth & matroos_urlread handle any special character (like @) in username or password

   url      = ['http://',user,':',passwd,'@',url];
   
% EOF   
