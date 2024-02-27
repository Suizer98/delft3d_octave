function [M1,M2,MStep]=ReadFirstStepLast(txt);

b=findstr(txt,':');
if size(b,2)==0
    M1=str2num(txt);
    M2=M1;
    MStep=1;
elseif size(b,2)==1
    M1=str2num(txt(1:b-1));
    M2=str2num(txt(b+1:end));
    MStep=1;
else
    M1=str2num(txt(1:b(1)-1));
    MStep=str2num(txt(b(1)+1:b(2)-1));
    M2=str2num(txt(b(2)+1:end));
end
