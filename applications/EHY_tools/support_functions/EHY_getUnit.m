function unit = EHY_getUnit(varName,fName)
[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fName);
varName = EHY_nameOnFile(fName, varName);

unit = '';
if ismember(typeOfModelFileDetail,{'his_nc','map_nc'})
    infonc = ncinfo(fName,varName);
    ind = strmatch('units',{infonc.Attributes.Name},'exact');
    unit = infonc.Attributes(ind).Value;
elseif ismember(typeOfModelFileDetail,{'trih','trim'})
    FI = qpfopen(fName);
    ind = strmatch(varName,{FI.ElmDef.Name},'exact');
    if ~isempty(ind)
        unit = FI.ElmDef(ind).Units;
    end
end
unit(ismember(unit,' []()')) = []; % remove brackets and spaces
