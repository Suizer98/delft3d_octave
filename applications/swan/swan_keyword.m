function [R,r1] = swan_keyword(rec,keys,varargin)
%SWAN_KEYWORD   read swan keywords from text line 
%
%    R = swn_keyword(rec,keys,<R_default>)
%
% where rec can be 'a=1 b=2' or '1 2'
% when keys is {'a','b'}.
%
% Optionally, when a keyword is not present,
% the field from R_default is used.
%
% When a keyword is present, the type from the same
% field from R_default is used (char or numeric),
% otherwise automatic str2num-detection is used.
%
%See also: swan

 OPT.debug = 0;
 
 if nargin>2
    R0 = varargin{1};
 else
    R0 = struct();
 end

 for i=1:length(keys)
    key      = keys{i};
    if ~isfield(R0,key)
       R0.(key) = [];
    end
   [k1,r1] = strtok(rec);

    if OPT.debug;disp(['keyword:',key,'  key:',k1,'  rest:',r1]);end

    i1 = strfind(k1,'=');
    if any(i1)
    
        key1 = k1(1:i1-1);
        if strcmpi(key,key1)
           if i1==length(k1)
           
% type: 'a= 3'
% 'a= 3'
               rec     = r1;
               [k1,r1] = strtok(rec);
           else
           
% type: 'a=3'
% 'a=3'
           k1 = k1(i1+1:end);
           end
        else
% 'wrong keyword'        
            r1  =  [k1,' ',r1];
            k1  = '';
            %error(['wrong keyword order, expected ''',key,''' instead of ''',key1,'''']);
        end
    else    
      [k2,r2] = strtok(r1);
       i2 = strfind(k2,'=');
       if any(i2)
         key1 = k1;
         if strcmpi(key,key1)
          if i2(1)==1
           if length(k2)==1
       
% type: 'a = 3'
% 'a = 3'
            [k1,r1] = strtok(r2);
           else
       
% type: 'a =3'
%'a =3'
            k1 = k2(i2+1:end);
            r1 = r2;
           end
          end
         else
%%
% 'wrong keyword'        
         end
       else
       
% type: '3'
% '3'
         key1 = '';
       end
    end
    if strcmpi(key1,key) | isempty(key1)
       if isempty(k1) & nargin > 2
           R.(key) = R0.(key);
       else
         if ~isempty(R0.(key)) & isnumeric(R0.(key))
           R.(key) = str2num(k1);
         else
           val = str2num(k1);
           if ~isempty(val)
           R.(key) = val;
           else
             if ~isempty(k1)
               R.(key) = k1;
             end
           end
         end
       end
       rec     = r1;
    end
    
    if OPT.debug;disp(['     ',key,' = ',k1]);end
    
 end    
 

 tmp = whos('R');
 if length(tmp)==0
    R = struct([]);
 end
