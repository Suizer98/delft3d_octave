function s = cleanUpStruct(s)
% Lift up the 'Text' single struct elements to the parent field


if isstruct(s)
    s = process(s);
else
    disp('Input is not a structure')
end

function s = process(s)
children    = fieldnames(s);
numChildren = length(children);

for nc = 1: numChildren
   child =  s.(children{nc});
   if isstruct(child)
       s.(children{nc})   = subprocess(child);
   end    
%    if isstruct(child)
%        if isfield(child, 'Text') && numel(fieldnames(child))==1
%             s.(children{nc}) = child.Text;
%        else
%            s = process(child);
%        end       
%    end
end


function sub = subprocess(sub)
       if isfield(sub, 'Text') && numel(fieldnames(sub))==1
            sub = sub.Text;
       else
           sub = process(sub);
       end       

