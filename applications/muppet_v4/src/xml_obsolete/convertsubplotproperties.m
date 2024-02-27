clear variables;close all;

mkdir('subplotoptions');

s0=xml2struct('d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\subplotoptions\subplotoptions.xml');

for ii=1:length(s0.subplotoption)
    s.subplotoption(ii).subplotoption=s0.subplotoption(ii).subplotoption;
    if ~isfield(s0.subplotoption(ii).subplotoption,'variable')
        s.subplotoption(ii).subplotoption.variable=s0.subplotoption(ii).subplotoption.name;
    end
    if isfield(s0.subplotoption(ii).subplotoption,'check')
        for ic=1:length(s0.subplotoption(ii).subplotoption.check)
            check=s0.subplotoption(ii).subplotoption.check(ic).check;
            s.subplotoption(ii).subplotoption.dependency.dependency.action='write';
            s.subplotoption(ii).subplotoption.dependency.dependency.checkfor='all';
            if isfield(check,'variable')            
                s.subplotoption(ii).subplotoption.dependency.dependency.check(ic).check.variable=check.variable;
                s.subplotoption(ii).subplotoption.dependency.dependency.check(ic).check.operator=check.operator;
                s.subplotoption(ii).subplotoption.dependency.dependency.check(ic).check.value=check.value;
            else
                s.subplotoption(ii).subplotoption.dependency.dependency.check(ic).check.variable=s.subplotoption(ii).subplotoption.variable;
                s.subplotoption(ii).subplotoption.dependency.dependency.check(ic).check.operator='ne';
                s.subplotoption(ii).subplotoption.dependency.dependency.check(ic).check.value=s0.subplotoption(ii).subplotoption.default;
            end            
        end
        s.subplotoption(ii).subplotoption=rmfield(s.subplotoption(ii).subplotoption,'check');
    end    
end

struct2xml('subplotoptions\subplotoptions.xml',s,'structuretype','short');
