function [I,AltStr]=ustrcmpi(Str,StrSet);
%USTRCMPI Find a unique string.
%
%      Index=USTRCMPI(Str,StrSet)
%      This function compares the string Str with the
%      strings in the string set StrSet and returns the
%      index of the string in the set that best matches
%      the string Str. The best match is determined by
%      checking in the following order:
%           1. exact match
%           2. exact match case insensitive
%           3. starts with Str
%           4. starts with Str case insensitive
%      If no string is found or if there is no unique
%      match, the function returns -1.
%
%      [Index,AltStr]=USTRCMPI(Str,StrSet)
%      Returns the string indicated by Index when there
%      is only one possibility. When there are multiple
%      matches, all appropriate strings are returned.
%
%      See also: STRCMP, STRCMPI, STRNCMP, STRNCMPI,
%                STRMATCH

% Copyright (c) 19/5/2000 H.R.A. Jagers (bert.jagers@wldelft.nl)
%                         WL | Delft Hydraulics, The Netherlands
%                         http://www.wldelft.nl

if nargin<2
  error('Not enough input arguments.')
end

if ~iscell(Str),
  if ischar(StrSet) & ~iscellstr(StrSet),
    StrSet=cellstr(StrSet);
  end;
end

I=strcmp(Str,StrSet);
if ~any(I),
  I=strcmpi(Str,StrSet);
  if ~any(I),
    if iscellstr(Str), % {list},string -> check whether any list starts in string
      for i=1:length(Str)
        if length(Str{i})<length(StrSet)
          I(i)=strncmp(Str{i},StrSet,length(Str{i}))*length(Str{i});
        end
      end
      if ~any(I),
        for i=1:length(Str)
          if length(Str{i})<length(StrSet)
            I(i)=strncmpi(Str{i},StrSet,length(Str{i}))*length(Str{i});
          end
        end
      end
      if any(I)
        m=max(I);
        I=I==m;
      end
    else, % string, {list}
      I=strncmp(Str,StrSet,length(Str));
      if ~any(I),
        I=strncmpi(Str,StrSet,length(Str));
      end
    end;
  end;
end;
I=find(I);
if nargout>1
   if iscellstr(Str)
      AltStr=Str(I);
   else
      AltStr=StrSet(I);
   end
   if length(AltStr)==1, AltStr=AltStr{1}; end
end
if ~isequal(size(I),[1 1]),
  I=-1;
end;
