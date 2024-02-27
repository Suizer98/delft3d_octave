% PARSE_OET_WPS  Parse a function that adheres to the OETWPS convention
%
%    [WPSSTRUCT] = PARSE_OET_WPS(FILENAME) parses the specified
%    file and returns a struct that contains all the metadata for the 
%    WPS server. FILENAME should include the extension .m.
%
%See also: runner

function [wpsstruct] = parse_oet_wps(filename)

    [argout, argin, fcn] = wps.runner.parse_function_call(filename); % [argout, argin, fcn] = m.parse.call()
    
    txt = fileread(filename); % txt = m.parse.header()
    
    % obtain argin, argout description from comment block
    
    % argument matching
    re = @(x) ['%\s*', x, '\s*\=\s*(?<type>\w+(/\w+)?)'];
    
    inputs = struct();
    for i=1:length(argin)
        % scan for type of input arguments
        arg   = argin{i};
        match = regexp(txt, re(arg), 'names');
        inputs.(arg) = match;
    end
    
    outputs = struct();
    for i=1:length(argout)
        % scan for type of output arguments
        arg   = argout{i};
        match = regexp(txt, re(arg), 'names');
        outputs.(arg) = match;
    end
    
    title = regexprep(lower(fcn),'(\<[a-z])','${upper($1)}');
    abstract = help(filename);
    
    wpsstruct = struct(...
        'identifier', fcn, ...
        'title', title, ...
        'abstract', abstract, ...
        'inputs'    , inputs,...
        'outputs'   , outputs ...
    );
end 