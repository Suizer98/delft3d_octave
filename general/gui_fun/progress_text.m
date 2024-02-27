function progress_text(a,b,i1,i2)
% Displays progress text
% e.g. 
% nt = 100;
% for it=1:nt        
%     progress_text('Calculating process for','time steps',it,nt);        
% end

persistent reverseStr
if i1==1
    reverseStr = ''; % initial empty string for progress text
end
msg = sprintf([a ' ' num2str(i1) ' of ' num2str(i2) ' ' b ' ...']);
fprintf([reverseStr, msg]);
if i1==i2
    fprintf(['\n', '']);
end
reverseStr = repmat(sprintf('\b'),1, length(msg));
