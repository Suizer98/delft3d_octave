function indexFound = chooseOption(T, dialogueInterface, TParent) %answerRetriever can be a text input/output, or gui interface!
%chooseOption will return a valid row of a Table according to user input.
%
% Usage:
%    index = chooseOption(T)
%    index = chooseOption(T,dialogueInterface)
%
% Example:
%    index=(1:5)';% Must be a column vector
%    name = {'abcd'
%
% T: a table that must have the variables index, and name. Other variables
%   in the table are displayed, but not otherwise used.
%
% dialogueInterface: an optional struct or object that implements the
%   following functions for interacting with a user (defaults and usage are
%   shown):
%     dialogueInterface.displayTable = @disp;
%       dialogueInterface.displayTable(T);
%
%     dialogueInterface.requestInput = @(s) input(s,'s');
%      answerString = dialogueInterface.requestInput('Enter something...');
%
%     dialogueInterface.displayText = @disp;
%       dialogueInterface.displayText('Text to display');
%
%
% A user may enter either a table index or name for selecting the row.
% Names matches are attempted in order by 1) an exact match including case,
% 2) exact case insensitive match, 3) partical case sensitive match, 4)
% partial, case insensitive match. If any result has more than one match
% when searching for a name, then the table will be filtered and input
% requested again. If at any time a selection is invalid, an answer will be
% requested again. The user can cancel the selection by pressing enter
% without typing anything which will return an empty vector [].
%
% Indices need not be unique, since the value only need exist to be
% returned.

if nargin<3
    TParent = [];
end
if nargin<2
    dialogueInterface.displayTable = @disp;
    dialogueInterface.requestInput = @(s) input(s,'s');
    dialogueInterface.displayText = @disp;
end

checkTCompatible(T);
isSubSelection = ~isempty(TParent);

dialogueInterface.displayTable(T);

indexToLoad = dialogueInterface.requestInput ( 'Please enter option index or name (hit enter without entering anything to cancel):' );
if isempty(indexToLoad)
    if isSubSelection
        indexFound = chooseOption(TParent,dialogueInterface);
    else
        indexFound = [];
    end
    return;
end

indexFound = str2num(indexToLoad);
if isempty(indexFound)
    compareFunctions = {@strcmp,@strcmpi,@strncmp,@strncmpi};
    indexMatched = false;
    indexFound = 0;
    attempt = 1;
    while ~indexMatched%any(indexFound) && ~isempty(indexFound)
        if attempt <=2
            indexFound = compareFunctions{attempt}(indexToLoad,T.name);
        elseif attempt <=4
            indexFound = compareFunctions{attempt}(indexToLoad,T.name,length(indexToLoad));
        else
            dialogueInterface.displayText('Can not find a option name that matches, Please try again');
            indexFound = chooseOption(T,dialogueInterface);
            break;
        end
        
        if ~any(indexFound)
            attempt = attempt +1;
        elseif sum(indexFound)>1
            dialogueInterface.displayText('More than one name matched (use an index if names are identical):');
            indexFound = chooseOption(T(find(indexFound),:),dialogueInterface,T);
            indexMatched = true;
        else
            indexFound = T.index(indexFound);
            indexMatched = true;
        end
    end
end



if isSubSelection
    if isempty(indexFound)
        indexFound = chooseOption(TParent,dialogueInterface);
    elseif ~any(indexFound == T.index)
        dialogueInterface.displayText([ num2str(indexFound) ' is not one of the included indices. Please try again, or press enter to go up a level.']);
        indexFound = chooseOption(T,dialogueInterface,TParent);
    end
elseif isempty(indexFound)
    return;
else
    nonMatch=0;
    for i=1:length(indexFound)
        if ~any(indexFound(i) == T.index);
            nonMatch = i;
            break;
        end
    end
    if nonMatch>0
        dialogueInterface.displayText([ num2str(nonMatch) ' is not one of the included indices. Please try again.']);
        indexFound = chooseOption(T,dialogueInterface);
    end
end

    function checkTCompatible(T)
        varName = T.Properties.VariableNames;
        assert(any(strcmp('index',varName)),'"index" must be a variable in table T.')
        assert(any(strcmp('name',varName)),'"name" must be a variable in table T.')
    end
end
