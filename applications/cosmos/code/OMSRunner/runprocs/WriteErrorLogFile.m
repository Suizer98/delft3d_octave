function WriteErrorLogFile(hm,str)

k=1;

err=lasterror;
ns=length(err.stack);

mess{k}=datestr(now);

%if nargin>0
%    str=varargin{1};
    k=k+1;
    mess{k}=str;
    disp([str ' - see oms.err']);
%end

k=k+1;
mess{k}=err.message;
for i=1:ns
    k=k+1;
    mess{k}=['file : ' err.stack(i).file];
    k=k+1;
    mess{k}=['name : ' err.stack(i).name];
    k=k+1;
    mess{k}=['line : ' num2str(err.stack(i).line)];
end

k=k+1;
mess{k}='';

fid=fopen('oms.err','a');
for i=1:k
    fprintf(fid,'%s\n',mess{i});
end
fclose(fid);

if hm.eMailOnError.send
    try
        setpref('Internet','SMTP_Server','smtp.deltares.nl');
        setpref('Internet','E_mail',hm.eMailOnError.adress);
        sendmail(hm.eMailOnError.adress,'Shite! An error occurred in the operational model!',mess);
    end
end
