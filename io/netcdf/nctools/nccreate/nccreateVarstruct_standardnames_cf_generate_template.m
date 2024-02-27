function varstruct = nccreateVarstruct_standardnames_cf(standard_name,varargin)
% NCCREATEVARSTRUCT_STANDARDNAMES_CF Creates a varstruct with defaultsd set to those belonging to a specific standardised name 

%% get varstruct structure from nccreateVarstruct
OPT            = nccreateVarstruct();

% set specifics for standard names
OPT.long_name  = ''; 
OPT.units      = ''; 
OPT.definition = ''; 

% parse varargin
OPT            = setproperty(OPT,varargin);

%% define the lists of standard_names, long_names, units and definitions
list = getList;
  
% lookup the standard name in the list
if nargin==0
    varstruct = list.standard_names;
    return
end

n = find(strcmpi(standard_name,list.standard_names),1);
if isempty(n)
    error('standard name not found')
end

if isempty(OPT.long_name);    OPT.long_name    = list.long_names{n};  end
if isempty(OPT.units);        OPT.units        = list.units{n};       end
if isempty(OPT.definition);   OPT.definition   = list.definitions{n}; end



% add attributes belonging to the standard name
OPT.Attributes =  [{...
    'standard_name',standard_name,...
    'long_name',OPT.long_name,...
    'units',OPT.units,...
    'definition',OPT.definition}...
    OPT.Attributes];

OPT = rmfield(OPT,{'long_name','units','definition'});

% finally check is the varstruct is valid
varstruct = nccreateVarstruct(OPT);

function list = getList()
% iput below is auto generated
list.standard_names = {'$standard_names'};

list.long_names = {'$long_names'};

list.units = {'$units'};

list.definitions = {'$definitions'};
    