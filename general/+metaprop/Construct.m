function metaprops = Construct(metaclass,metaPropertyBlock)
% CONSTRUCT Helper function to create structure of many metaprop object with a single call
%
%
% Example: 
% Create the metaprops structure for a class with two properties,
% DateProperty and NumberProperty
%         metaprops = metaprop.Construct(?<Classname>,{
%             'DateProperty',@metaprop.date,{
%                 'Category','When'
%                 'Description','Date field'
%                 }
%             'NumberProperty',@metaprop.doubleScalar,{
%                 'Category','What'
%                 'Description','A single double precision number greater than 1'
%                 'Attributes',{'>',1}
%                 }
%             });
%
% See also: metaprop, metaprop.example

if ischar(metaclass)
    metaclass = meta.class.fromName(metaclass);
end

% validate input
validateattributes(metaclass        ,{'meta.class'},{'scalar'});
validateattributes(metaPropertyBlock,{'cell'}      ,{'ncols',3});

% more assertions
assert(all(cellfun(@(x) isa(x,'char')            ,metaPropertyBlock(:,1))),...
    'Expected the first column of the metaPropertyBlock to contain only char');
assert(all(cellfun(@(x) isa(x,'function_handle') ,metaPropertyBlock(:,2))),...
    'Expected the second column of the metaPropertyBlock to contain function handles');
assert(all(cellfun(@(x) isa(x,'cell')            ,metaPropertyBlock(:,3))),...
    'Expected the thord column of the metaPropertyBlock to contain cell arrays with additional arguments');

PropertyList =  metaclass.PropertyList;

for ii = 1:size(metaPropertyBlock,1)
    name      = metaPropertyBlock{ii,1};
    fcn       = metaPropertyBlock{ii,2};
    % transpose for when the cell is a nx2 cell, so keyword/value pairs
    % stay together
    extraArgs = metaPropertyBlock{ii,3}';
    
    n = strcmp(name,{PropertyList.Name});
    assert(sum(n)==1,...
        'Unable to define metaproperty ''%s'' because no property with that name exists in class definition of ''%s''',...
        name,metaclass.Name)
    
    metaprops.(name) = fcn(PropertyList(n),extraArgs{:});
end
