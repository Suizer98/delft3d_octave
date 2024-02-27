function [nearest index]=findnearest(data,value)

dif=abs(data-value);
[aa index]=min(dif);
nearest=data(index);

end
