function out = mat2clip(a)

%MAT2CLIP  Copies matrix to system clipboard.
%
% MAT2CLIP(A) copies the contents of 2-D matrix A to the system clipboard. A
% can be a numeric array (doubles or logicals), or a cell array. The cell
% array can have mixture of data types, as long as they are one of strings,
% doubles, or logicals.
%
% Each element of the matrix will be separated by tabs, and each row will
% be separated by a NEWLINE character. For numeric elements, it tries to
% preserve the current FORMAT.
%
% OUT = MAT2CLIP(A) returns the actual string that was copied to the
% clipboard.
%
% Example:
%   format long g
%   a = {'hello', 123;pi, 'bye'}
%   mat2clip(a);
%
% See also CLIPBOARD.
%
% VERSIONS:
%   v1.0 - First version
%
% Jiro Doke
% Sept 2005
% Inspired by NUM2CLIP by Grigor Browning (File ID: 8472) Matlab FEX.
%

if nargin < 1
  return;
end

if ndims(a) ~= 2
  error('Only 2-D matrices are allowed.');
end

% each element is separated by tabs and each row is separated by a NEWLINE
% character.
sep = {'\t', '\n', ''};

% try to determine the format of the numeric elements.
switch get(0, 'Format')
  case 'short'
    fmt = {'%s', '%0.5f'};
  case 'shortE'
    fmt = {'%s', '%0.5e'};
  case 'shortG'
    fmt = {'%s', '%0.5g'};
  case 'long'
    fmt = {'%s', '%0.15f'};
  case 'longE'
    fmt = {'%s', '%0.15e'};
  case 'longG'
    fmt = {'%s', '%0.15g'};
  otherwise
    fmt = {'%s', '%0.5f'};
end

switch class(a)
  case 'cell'
    a = a';
    
    str = cellfun('isclass', a, 'char');
    numtypes = {'double', 'logical'};
    num = zeros(size(a));
    for i = 1:length(numtypes)
      num = or(num, cellfun('isclass', a, numtypes{i}));
    end
    classType = zeros(size(a));
    classType(str) = 1; classType(num) = 2;
    if any(~classType(:))
      error('Unknown type in the cell array. Only strings, doubles, and logicals are allowed.');
    end
    sepType = ones(size(a));
    sepType(end, :) = 2; sepType(end) = 3;
    tmp = [fmt(classType(:));sep(sepType(:))];
    
    b=sprintf(sprintf('%s%s', tmp{:}), a{:});
    
  case {'double', 'logical'}
    a = a';
    
    classType = repmat(2, size(a));
    sepType = ones(size(a));
    sepType(end, :) = 2; sepType(end) = 3;
    tmp = [fmt(classType(:));sep(sepType(:))];
    
    b=sprintf(sprintf('%s%s', tmp{:}), a(:));
    
  case 'char'
    % if multiple rows, convert to a single line with line breaks
    if size(a, 1) > 1
      b = cellstr(a);
      b = [sprintf('%s\n', b{1:end-1}), b{end}];
    else
      b = a;
    end
    
  otherwise
    error('Unknown matrix type. Only strings, doubles, and logicals are allowed.');
end

clipboard('copy', b);

if nargout
  out = b;
end
