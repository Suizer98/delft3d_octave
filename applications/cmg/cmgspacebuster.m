function newstring=cmgspacebuster(oldstring)
% get rid of both leading and trailing white spaces
% newstring=strjust(oldstring,'left');
if ~isempty(oldstring),
	ind=isspace(oldstring);
	indx=find(ind==1);
	oldstring(indx)=[];
end;
newstring=oldstring;
% newstring=deblank(newstring);
return;
