function [m,n] = nesthd_convertstring2mn(string )

% Gets M,N coordinates out of a string
%
i_start = strfind(string,'(');
i_end   = strfind(string,')');
i_cent  = strfind(string,',');

if strcmpi(strtrim(string(i_start(1) + 1:i_cent(1) - 1)),'m') &&  ...
   strcmpi(strtrim(string(i_cent (1) + 1:i_end (1) - 1)),'n')
    m = str2num(string(i_start(end) + 1:i_cent(end) - 1));
    n = str2num(string(i_cent (end) + 1:i_end (end) - 1));
else
    m = nan;
    n = nan;
end
