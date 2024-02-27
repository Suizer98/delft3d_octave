function s = geturl(urlChar)
%function s = geturl(urlChar);
% get content of a url as a cellarray of strings
% example: data=geturl('http://matroos.deltares.nl')

%
% use java to make a connection
%
import java.net.*;
import java.io.*;

%check for pasword
ii=findstr('@',urlChar);
loginPassword='';
if(~isempty(ii)),
   loginPassword=java.lang.String(urlChar(8:(ii(end)-1)));
   urlChar=['http://',urlChar(ii(end)+1:end)];
end;
u=URL(urlChar); %java-object
con=u.openConnection();

%detect password in http url and use this in the connection
if(~isempty(loginPassword)),
%  fprintf('login and password detected: %s \n');disp(loginPassword);
   enc = sun.misc.BASE64Encoder();
   encodedPassword=['Basic ',char(enc.encode(loginPassword.getBytes()))];
   %fprintf('Encoded password = %s \n',encodedPassword);
   con.setRequestProperty('Authorization',encodedPassword);
end;

% now start reading
content = con.getInputStream();
in = java.io.BufferedReader(java.io.InputStreamReader(content));

i=1;
s={};
while(1==1),
    javaLine = in.readLine();
    line=char(javaLine);
    if (strcmp(line,'')==1), break;end;
%%    fprintf('>> %s \n',line);
    s{i}=line;
    i=i+1;
end;

