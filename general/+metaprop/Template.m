function Template(object)
% TEMPLATE Template for the metaproperty definition
% object: instance of the object for which the template should be generated
mc = metaclass(object);

propnames = {mc.PropertyList(~[mc.PropertyList.Hidden]).Name};

%% property name definition
str = '';
for ii = 1:length(propnames)
    switch class(object.(propnames{ii}))
        case 'logical'
            if numel(object.(propnames{ii})) == 1
                suggestedMetaprop = 'logicalScalar';
            else
                suggestedMetaprop = 'logicalArray';
            end            
        case 'double'
            if numel(object.(propnames{ii})) == 1
                % if ti looks like a datenum, suggest a datenum
                if abs(object.(propnames{ii})-now())<10000
                    suggestedMetaprop = 'date';
                else
                    suggestedMetaprop = 'doubleScalar';
                end
            elseif size(object.(propnames{ii}),1) == 1
                suggestedMetaprop = 'doubleRow';
            else
                suggestedMetaprop = 'doubleArray';
            end
        case 'char'
            % check if it looks like a file of folder path
            if exist(object.(propnames{ii}),'file')
                suggestedMetaprop = 'file';
            elseif exist(object.(propnames{ii}),'dir')
                suggestedMetaprop = 'folder';
            else
                suggestedMetaprop = 'char';
            end
        case 'cell'
            if iscellstr(object.(propnames{ii}))
                suggestedMetaprop = 'cellstring';
            else
                suggestedMetaprop = 'doubleScalar';
            end
        otherwise
            suggestedMetaprop = 'doubleScalar';
    end
    str = [str sprintf('\t\t\t''%s'',@metaprop.%s,{\n\t\t\t\t''Category'',''Add a category''\n\t\t\t\t''Description'',''Add a description''\n\t\t\t\t}\n',propnames{ii},suggestedMetaprop)];
end
fprintf(1,'\tproperties (Hidden)\n\t\t%% Code template generated by calling metaprop.Template(%s)\n\t\t%s_metaprops = metaprop.Construct(mfilename(''class''),{\n%s        });\n\tend\n\n',mc.Name,mc.Name,str);

%% 
fprintf(1,'\tmethods (Hidden,Access = protected)\n\t\tfunction value = construct_metaprops(self)\n\t\t\tvalue = self.%s_metaprops;\n\t\tend\n\tend\n\n',mc.Name);

%% property setter methods
str = '';
for ii = 1:length(propnames)
    str = [str sprintf('\t\tfunction set.%-16s(self,value); self.metaprops.%-16s.Check(value); self.%-16s = value; end\n',propnames{ii},propnames{ii},propnames{ii})];
end
fprintf(1,'\tmethods\n%s\tend\n',str);
