function fname = extensie(fname, ext)
% Verify extension, append extension if needed
% 
% CALL:
%  fname = extensie(fname, ext)
%
% INPUT:
%  fname: string, candidate filename
%  ext  : string, required file extension
%
% OUTPUT:
%  fname: string, filename including extension
% 
% EXAMPLE:
%  fname1 = extensie('donar', 'dia')
%  fname2 = extensie('donar.dia', 'dia')
% 
% APPROACH:
%  controleer de extensie.
%  als deze niet klopt, voeg extensie toe.
% 
% AUTHOR:
%  Nanne van der Zijpp, ModelIT
% 
% See also: fileparts, putfile, getfile

if length(fname)<length(ext)+1 |...
      ~strcmp(lower(fname(end-length(ext):end)),['.' lower(ext)])
   fname=[fname '.' ext];
end
