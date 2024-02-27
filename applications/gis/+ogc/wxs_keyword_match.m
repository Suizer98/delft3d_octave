function [val,i] = wxs_keyword_match(txt,val,set,OPT)
%wxs_KEYWORD_MATCH  validate choice against cellstr set, make choice from UI
%
%  Keep case:
%  Note that the parameter names in all KVP encodings shall be handled
%  in a case insensitive manner while parameter values shall be handled in a case sensitive
%  manner. [csw 2.0.2 p 128]
%
%See also: strcmpi

import ogc.*

   if ischar(set)
       set = cellstr(set);
   end
   if isempty(set)
       set = {''};
   end
           
   if isnumeric(val)
      i = min(val,length(set));
      val  = set{i};
      if OPT.disp;disp(['wxs:selected:  ',txt,'(',num2str(i),')="',val,'"']);end
   elseif isempty(val)
       
       
       if     isempty(set)  ;i = [];val = [];
       elseif length(set)==1;i =  1;val = set{1};
          dprintf(2,['wxs:not valid: only valid option returned: ',val])
       else
      [i, ok] = listdlg('ListString', set, .....
                     'SelectionMode', 'single', ...
                      'PromptString',['Select ',txt,':'], ....
                              'Name',OPT.server,...
                          'ListSize', [500, 300]);
       val = set{i};
       end
   else
      i = strmatch(lower(val),lower(set),'exact'); % EPSG or epsg is same
      if isempty(i)
          dprintf(2,['wxs:not valid: ',txt,'="',val,'", choose from valid options:'])
          % throw menu to show options that are available
          [val,i] = wxs_keyword_match(txt,'',set,OPT);
      else       
          if OPT.disp;disp(['wxs:validated: ',txt,'="',val,'"']);end
      end    
   end