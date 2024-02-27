function std=optiComputeStd(this,dataGroup)

% OPTICOMPUTESTD - computes standard deviation per condition from optiStruct
%
% Usage:
%  std=optiComputeStd(optiStruct,dataGroup);
%

for ii=1:size(this.input(dataGroup).data,2)
    % id=find(this.input(dataGroup).data(:,ii)<999&abs(this.input(dataGroup).data(:,ii))>0&~isnan(this.input(dataGroup).data(:,ii)));
    id=find(abs(this.input(dataGroup).data(:,ii))>0&~isnan(this.input(dataGroup).data(:,ii)));
    std(ii)=sqrt(sum(sum(this.input(dataGroup).data(id,ii).^2))/length(id));
end
std(find(isnan(std)))=0;