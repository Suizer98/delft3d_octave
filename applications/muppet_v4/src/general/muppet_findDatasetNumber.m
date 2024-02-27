function datasetnr=muppet_findDatasetNumber(handles,name)
 
datasetnr=[];

for ii=1:length(handles.datasets)
    if strcmpi(name,handles.datasets(ii).dataset.name)
        datasetnr=ii;
        break
    end
end

% if isempty(datasetnr)
%     disp(['Dataset ' name ' not found!'])
% end
