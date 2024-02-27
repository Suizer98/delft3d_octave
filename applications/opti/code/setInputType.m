function this=setInputType(this,iType,dataGroup)

% SETINPUTTYPE - sets inputtype in opti structure for data load
%
%   optiStruct=setInputType(optiStruct,iType,dataGroup)
%
% in which iType is numeric and can have the following values:
%   1 - old opti method with map-files
%   2 - one trim-file with all conditions
%   3 - series of trim-files (one trim per condition)
%

if nargin~=3
    error('Not sufficient input arguments. Input type not set!');
    return
end

if ~numeric(iType)
    error('Input type is no numeric value!');
    return
end

this.input(dataGroup).inputType=iType;
