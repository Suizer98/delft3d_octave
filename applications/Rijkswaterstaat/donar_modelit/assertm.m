function assertm(condition,msg)
% assert - check condition. If false call error(msg)
% 
% CALL
%     assertm(condition)
%     assertm(condition,msg)
%     
% INPUT
%     condition:
%         boolean
%      msg:
%          error message that will be displayed if condition==false
%          
% OUTPUT
%     This function returns no output arguments
%     
% EXAMPLE
%     assertm(exist(fname,'file'),'input file does not exist')
%     
% NOTE
%     assertm.m replaces assert.m because 2008a contains a duplicate
%     function assert
    
if condition
    return
end
if nargin<2
    msg='Assertion failed';
end
command=sprintf('error(''%s'');',msg);
evalin('caller',command);