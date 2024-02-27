function varargout = ncgen_writeFcn_memory(OPT,data)
% function meant to use ncgen functions to read datafiles to matlab memory 
% (in stead of writing the data to netcdf)

% This function can be used in two ways. Either call a readFcn with a
% specified fns and OPT to read a single file, of call the mainFcn to batch
% process multiple files. In that case you also have to define a schemaFcn,
% which will determine the data structure in memory
% Example:
%         writeFcn = @(OPT,data)         ncgen_writeFcn_memory(OPT,data);
%         readFcn  = @(OPT,writeFcn,fns) ncgen_readFcn_XXXXX  (OPT,writeFcn,fns);
%         
%         ncgen_writeFcn_memory('initialize');
%         readFcn(OPT,writeFcn,fns);
%         data = ncgen_writeFcn_memory('return');

if nargin == 0 || isempty(OPT)
    OPT.write.method = 'append';
    OPT.write.schema = [];
    varargout = {OPT.write};
    return
end

if isstruct(OPT)
    method = OPT.write.method;
else
    method = OPT;
end

persistent DATA

switch method
    case 'append'
        if isempty(DATA)
            DATA = data;
        else
            varname = fieldnames(data);
            for in= 1:numel(varname)
                DATA.(varname{in}) = [DATA.(varname{in}); data.(varname{in})];
            end
        end
    case 'collect'
        if isempty(DATA)
            DATA = data;
        else
            DATA(end+1) = data;
        end
    case 'initialize'
        clear DATA
    case 'return'
        varargout = {DATA};
        clear DATA
    otherwise
        error('Invalid method: %s',OPT.method);
end

