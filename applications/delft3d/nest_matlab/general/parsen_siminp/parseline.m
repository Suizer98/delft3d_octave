function Line = parseline(Line,separators)
%
% Locate quotes and strings.
%
quotes = Line=='''';
NotString = ~mod(cumsum(quotes),2);
quotes = find(quotes);
%
% Replace separators '\\/=(),:;\t' by spaces, outside strings.
%
Line(ismember(Line,separators) & NotString)=' ';
%
% Remove all text after the first hash not part of a string
%
hashes = Line=='#' & NotString;
if any(hashes)
   hash = find(hashes);
   Line(hash(1):end)=[];
   NotString(hash(1):end)=[];
   quotes(quotes>hash(1))=[];
end
%
% Change to upper case outside strings
%
Line(NotString) = upper(Line(NotString));
%
% Add spaces after quotes.
%
if mod(length(quotes),2)~=0
   error('Odd number of quotes encountered in line: %s',Line)
end
for i = length(quotes):-1:1
   q = quotes(i);
   if mod(i,2) == 0
      %
      % End quote: following space?
      %
      if q < length(Line)
         if Line(q+1) ~= ' '
            Line = [Line(1:q) ' ' Line(q+1:end)];
         end
      end
   else
      %
      % Start quote: preceding space?
      %
      if q > 1
         if Line(q-1) ~= ' '
            Line = [Line(1:q) ' ' Line(q+1:end)];
         end
      end
   end
end


