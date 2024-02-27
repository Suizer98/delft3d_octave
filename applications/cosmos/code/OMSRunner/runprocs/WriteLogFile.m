function WriteLogFile(varargin)

fid=fopen('oms.log','a');
 
if nargin>0
    str=varargin{1};
    fprintf(fid,'%s\n',[datestr(now) ' - ' str]);  
    disp(str);
end

fclose(fid);
