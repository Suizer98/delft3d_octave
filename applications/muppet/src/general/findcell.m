function i=findcell(cellarray,str);
 
b=regexp(cellarray,str,'once');
i=find(~cellfun('isempty',b));
