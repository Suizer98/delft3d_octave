function s = matroos_urlread(urlChar,varargin);
%MATROOS_URLREAD   urlread with username:password authentication
%
%    data_stream = matroos_urlread
%
% get content of a matroos url url as a cell array of strings
% example:
% data = matroos_urlread ('http://user:password@matroos.deltares.nl........')
% data = matroos_urlread('https://user:password@matroos.deltares.nl........')
%
% Note that regular urlread cannot handle the required authentication, see:
% http://www.mathworks.com/support/solutions/en/data/1-4EO8VK/index.html?solution=1-4EO8VK
%
%See also: MATROOS, URLREAD, URLREAD_BASICAUTH

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Martin Verlaan
%
%       Martin.Verlaan@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: matroos_urlread.m 6955 2012-07-18 14:14:05Z boer_g $
% $Date: 2012-07-18 22:14:05 +0800 (Wed, 18 Jul 2012) $
% $Author: boer_g $
% $Revision: 6955 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_urlread.m $
% $Keywords: $


%% use java to make a connection

  import java.net.*;
  import java.io.*;
  
  OPT.debug = 0;
  
  OPT = setproperty(OPT,varargin);  

%% check for pasword

   ii=findstr('@',urlChar); % in a url all other @ should have been replaced with %40.
   loginPassword='';
   if(length(ii)>0),
      loginPassword=java.lang.String(urlChar(1:(ii(end)-1)));
      urlChar=['http://',urlChar(ii(end)+1:end)];
   end;
   u=URL(urlChar); %java-object
   con=u.openConnection();

%% detect password in http url and use this in the connection

   if(~isempty(loginPassword)),
      if(  strcmp(loginPassword.substring(0,7),'http://')  ),
          loginPassword=loginPassword.substring(7);
      elseif(  strcmp(loginPassword.substring(0,8),'https://')  ),
          loginPassword=loginPassword.substring(8);
      end;
      enc = sun.misc.BASE64Encoder();
      encodedPassword=['Basic ',char(enc.encode(loginPassword.getBytes())),'='];
      fprintf('Detected > encoded username:password "%s" > "%s" \n',char(loginPassword),encodedPassword);
      con.setRequestProperty('Authorization',encodedPassword);
   end;

%% now start reading

   content = con.getInputStream();
   disp(['Reading url now, please be patient : ',urlChar])
   in = java.io.BufferedReader(java.io.InputStreamReader(content));
   
   i=1;
   s={};
   while(1==1),
       javaLine = in.readLine();
       line=char(javaLine);
       if (strcmp(line,'')==1), break;end;
       if OPT.debug
          fprintf('>> %s \n',line);
       end
       s{i}=line;
       i=i+1;
   end;

