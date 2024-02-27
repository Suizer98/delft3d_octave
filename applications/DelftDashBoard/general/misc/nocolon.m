function [str,prefix]=nocolon(str)
% Get rid of everything in string up to and including last colon. This is needed to
% because field names in structures cannot contain colons 
n=find(str==':');
prefix=[];
if ~isempty(n)
    n1=n(end)+1;
    n2=length(str);
    prefix=str(1:n(end));
    str=str(n1:n2);
end
