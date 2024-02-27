clear variables;close all;

mkdir('figureoptions');

s0=xml2struct('d:\checkouts\OpenEarthTools\trunk\matlab\applications\muppet_v4\src\xml\figureoptions\figureoptions.xml');

for ii=1:length(s0.figureoption)
    s.figureoption(ii).figureoption=s0.figureoption(ii).figureoption;
    if ~isfield(s0.figureoption(ii).figureoption,'variable')
        s.figureoption(ii).figureoption.variable=s0.figureoption(ii).figureoption.name;
    end
    if isfield(s0.figureoption(ii).figureoption,'check')
        for ic=1:length(s0.figureoption(ii).figureoption.check)
            check=s0.figureoption(ii).figureoption.check(ic).check;
            s.figureoption(ii).figureoption.dependency.dependency.action='write';
            s.figureoption(ii).figureoption.dependency.dependency.checkfor='all';
            if isfield(check,'variable')            
                s.figureoption(ii).figureoption.dependency.dependency.check(ic).check.variable=check.variable;
                s.figureoption(ii).figureoption.dependency.dependency.check(ic).check.operator=check.operator;
                s.figureoption(ii).figureoption.dependency.dependency.check(ic).check.value=check.value;
            else
                s.figureoption(ii).figureoption.dependency.dependency.check(ic).check.variable=s.figureoption(ii).figureoption.variable;
                s.figureoption(ii).figureoption.dependency.dependency.check(ic).check.operator='ne';
                s.figureoption(ii).figureoption.dependency.dependency.check(ic).check.value=s0.figureoption(ii).figureoption.default;
            end            
        end
        s.figureoption(ii).figureoption=rmfield(s.figureoption(ii).figureoption,'check');
    end    
end

struct2xml('figureoptions\figureoptions.xml',s,'structuretype','short');
