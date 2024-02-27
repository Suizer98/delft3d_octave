function [data] = readkeys(filename)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
number=0;
fid=fopen(filename);
while 1
    s=fgetl(fid);
    if ~isempty(s)
        if ~ischar(s), break, end
        s = strip(s);
        if s(1)~='%'
            k=find(s=='=',1);
            if ~isempty(k)
                number=number+1;
                keywords{number}=strip(s(1:k-1));
                val=strip(s(k+1:end));
                % m=find(val==' '|val==';'|val=='%'|val=='/',1);
                m=find(val==';'|val=='%'|val=='/',1);
                if isempty(m)
                    values{number}=val;
                else
                    values{number}=val(1:m-1);
                end
            end
        end
    end
end
fclose(fid);
for i=1:length(keywords)
    keyword=keywords{i};
    value=values{i};
    eval(['data.',keyword,'=',value,';']);
end


