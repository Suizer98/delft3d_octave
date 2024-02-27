function [firstmeaning, meaning] = getDictionaryInfoForWord (word)
% GETDICTIONARYINFOFORWORD gets the meaning for a word from an online dictionary
%
% Based on the user input an url is contructed to retrieve information from http://dictionary.reference.com. This information is processed. Html codes are removed. And the meaning as suggested by the online dictonary is fed back.
%
% Syntax:
% [firstmeaning, meaning] = getDictionaryInfoForWord (word)
%
% Input:
%   word         = string indicating a word to retrieve from an internet source
%
% Output:
%   firstmeaning = string with the first meaning suggested by the online dictionary
%   meaning      = cell array with all meanings suggested by the online dictionary
%
% example:
%   [meaning, firstmeaning] = getDictionaryInfoForWord('quadruped');
%   [meaning, firstmeaning] = getDictionaryInfoForWord('estuary');
%   [meaning, firstmeaning] = getDictionaryInfoForWord('coast');
%   [meaning, firstmeaning] = getDictionaryInfoForWord('Western-Scheldt');
%   [meaning, firstmeaning] = getDictionaryInfoForWord('Delta');
%
% See also: returns all meanings suggested by the online dictionary

%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2007  FOR INTERNAL USE ONLY
% Version:  Version 1.0, June 2008 (Version 1.0, June 2008)
% By:      <Mark van Koningsveld (email:m.vankoningsveld@tudelft.nl)>
%--------------------------------------------------------------------------------


% example:
% [meaning, firstmeaning] = getDictionaryInfoForWord('quadruped');
% [meaning, firstmeaning] = getDictionaryInfoForWord('estuary');
% [meaning, firstmeaning] = getDictionaryInfoForWord('coast');
% [meaning, firstmeaning] = getDictionaryInfoForWord('Western-Scheldt');
% [meaning, firstmeaning] = getDictionaryInfoForWord('Delta');

if nargin == 0
    global session;
    try
        idfrom = find(ismember(vertcat(session.vertices{:,3}),gco));
        word = session.vertices{idfrom,1};
    catch
        return
    end
end

clc
try
    a=urlread(['http://dictionary.reference.com/browse/' word]);
    startstr = '<table class="luna-Ent"><tr><td valign="top" class="dn">';
    stopstr  = '</table>';
    id = strfind(a,startstr);
    for i = 1:length(id)
        id2 = strfind(a(id(i):end),stopstr);
        str = a(id(i):id(i)+id2(1)-2);
        str = str(length(startstr)+1:end);
        while ~isempty(find((str=='<')==1,1,'first'))
            idstart = find((str=='<')==1,1,'first');
            idstop  = find((str=='>')==1,1,'first');
            str = str([1:idstart-1 idstop+1:end]);
        end
        meaning{i,1} = strtrim(str);
    end

    [dummy, firstmeaning] = strtok(meaning{1,1},'.');
    firstmeaning = firstmeaning(2:end-1);

catch
    disp('no result found')
    clear firstmeaning meaning
    return
end

if nargin == 0 && ~isempty(firstmeaning)
    %% put info in gui
    set(findobj('Tag','txtDic'), 'string', firstmeaning);
end
