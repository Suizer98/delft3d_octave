function [str1,iac] = remove_from_structure(str0, iac)

k=0;
str1=[];
n=length(str0);
for i=1:length(str0)
    if i~=iac
        k=k+1;
        fldnames=fieldnames(str0(i));
        for j=1:length(fldnames)
            str1(k).(fldnames{j})=str0(i).(fldnames{j});
        end
    end
end
if iac==n
    iac=iac-1;
end
iac=max(iac,1);
