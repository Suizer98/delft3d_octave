function ddb_shorelines_save_input(opt)

handles=getHandles;

inp=handles.model.shorelines.domain;

switch lower(opt)
    case{'save'}
        [filename, pathname, filterindex] = uiputfile('shorelines.inp','Select ShorelineS file');
        shorelines_save_input(filename,inp);
        
end

function shorelines_save_input(filename,data)
fid=fopen(filename,'w');
fieldnms=fields(data);
for ii=1:length(fieldnms)
    key=fieldnms{ii};
    val=data.(fieldnms{ii});
    
    if ischar(val)
        str=[key,'=','''',val,''''];
    elseif isnumeric(val)
        if length(val)==1
           str=[key,'=',num2str(val)];
        end
    end
    
    try
    fprintf(fid,'%s \n',str);
    end
end
fclose(fid);


