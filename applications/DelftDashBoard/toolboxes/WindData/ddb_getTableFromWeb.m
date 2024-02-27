function out = ddb_getTableFromWeb(url,tableID)
% Function ddb_getTableFromWeb
% Inputs - none
% Outputs - data from selected table
%
% Usage:
% * Navigate to a webpage using MATLAB's web browser (note: this will NOT
% work with any other browser)
% * Once at the location of the table you want, execute this function
% (ddb_getTableFromWeb)
% * Click on the MATLAB logo next to the table you want to import
%
% This function takes no input arguments.  The varargin is so that when
% getting the data from a table it can identify which table you have
% chosen.


% if (nargin == 1)
%     varargout{1} = getHTMLTable(varargin{1});
%     return
% end

% newBrowser = 0;
% activeBrowser = [];
% if ~newBrowser
%     % User doesn't want a new browser, so find the active browser.
%     activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.getActiveBrowser;
% end
% if isempty(activeBrowser)
%     % If there is no active browser, create a new one.
%     activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.createBrowser(showToolbar, showAddressBox);
% end

% Call functionality to update the HTML with MATLAB hooks to grab data
% urlText = activeBrowser.getHtmlText;
urlText = ddb_urlread(url);
pageString = updateHTML(urlText);
out = getHTMLTable(pageString,tableID);
% activeBrowser.setHtmlText(newUrlText);

%%
function newUrlText = updateHTML(url)

% Setup
% Set the location to the icon
iconLocation = ['file://' regexprep(fullfile(pwd,'matlab.ico'), '\\', '\/')];
%
% Convert the Java string to a character array for MATLAB
% pageString = reshape(url.toCharArray, 1, []);
pageString = url;
% Regular expressions used in replacements
noDataTable = 'replaceMeFirst'; %used for tables with no visible data
dataTable = ['<a href="matlab:ddb_getTableFromWeb(replaceMe)"><img src="' iconLocation '" align="left" name="MLIcon"/></a>'];

% Find all tables
tables = regexprep(pageString, '(<table[^>]*>(?:(?>[^<]+)|<(?!table[^>]*>))*?</table)', [noDataTable '$1']);

% Remove the text in front of tables with no data
tables = regexprep(tables, [noDataTable '(<table[^>]*>(?:<[^>]*>\s*)+?)</table[^>]*>'], '$1');

% Add the string for accessing MATLAB in front of tables with data
tables = regexprep(tables, noDataTable, dataTable);

% Find all of the table with data tags and provide them with a unique
% identifier for grabbing the data
dataTableID = regexp(tables, 'replaceMe', 'tokens');
for i = 1:length(dataTableID)
    tables = regexprep(tables, 'replaceMe', num2str(i), 'once');
end

% output
% Output the new HTML
newUrlText = tables;

%%
function out = getHTMLTable(pageString,tableID)

% Pattern for finding MATLAB hooks
pattern = ['<a href="matlab:ddb_getTableFromWeb\(' num2str(tableID) '\)'];

% Find data from the table
% regexprep is very slow, so we use other method
% [s e tok match] = regexp(pageString, [pattern '.*?<table[^>]*>.*?(<tr.*?>).*?</table[^>]*>' ], 'once');
% anyData = strtrim(regexprep(match, '<.*?>', ''));
[s e tok anyData] = regexp(pageString, [pattern '.*?<table[^>]*>.*?(<tr.*?>).*?</table[^>]*>' ], 'once');
id1=strfind(anyData,'<');
id2=strfind(anyData,'>');
idt=strvcat([num2str(id1') repmat(':',length(id1),1) num2str(id2') repmat(' ',length(id1),1)]);
idt=reshape(idt',1,numel(idt));
anyData(eval(['[' idt ']']))=[];
anyData=strtrim(anyData);

if(isempty(anyData))
    r = regexp(pageString, [pattern '.*?</table><table[^>]*>(.*?)</table'], 'tokens', 'once');
else
    r = regexp(pageString, [pattern '(.*?)</table'], 'tokens');
end

% Convert any data in cell arrays to characters
if ~isempty(r)
    while(iscell(r))
        r = r{1};
    end
end

%Establish a row index
rowind = 0;

% Build cell aray of table data
if ~isempty(r)
    try
        rows = regexpi(r, '<tr.*?>(.*?)</tr>', 'tokens');
        for i = 1:numel(rows)
            colind = 0;
            if (isempty(regexprep(rows{i}{1}, '<.*?>', '')))
                continue
            else
                rowind = rowind + 1;
            end

            headers = regexpi(rows{i}{1}, '<th.*?>(.*?)</th>', 'tokens');
            if ~isempty(headers)
                for j = 1:numel(headers)
                    colind = colind + 1;
                    data = regexprep(headers{j}{1}, '<.*?>', '');
                    if (~strcmpi(data,'&nbsp;'))
                        out{rowind,colind} = strtrim(data);
                    end
                end
                continue
            end
            cols = regexpi(rows{i}{1}, '<td.*?>(.*?)</td>', 'tokens');
            for j = 1:numel(cols)
                if(rowind==1)
                    if(isempty(cols{j}{1}))
                        continue
                    else
                        colind = colind + 1;
                    end
                else
                    colind = j;
                end
                data = regexprep(cols{j}{1}, '&nbsp;', ' ');
                data = regexprep(data, '<.*?>', '');

                if (~isempty(data))
                    out{rowind,colind} = strtrim(data) ;
                end
            end
        end
    end
else
    out=[];
end
