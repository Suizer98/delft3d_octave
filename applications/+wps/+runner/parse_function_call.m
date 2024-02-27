% PARSE_FUNCTION_CALL  Obtain list of input and output arguments
%
%    [OUTARGS,INARGS] = PARSE_FUNCTION_CALL(FILENAME) parses the specified
%    file and returns cell arrays with the names of the input (INARGS) and
%    output (OUTARGS) arguments of the first function in the file.
%
%    [OUTARGS,INARGS,FCN] = ... also returns a string (FCN) with the name
%    of the function definition. This name is actually irrelevant since the
%    function will be known to MATLAB under the name of the file.
%
%See also: runner

...

    function ...
    [argout, argin, ... and optionally
    fcn] = ...
    parse_function_call ...
    (filename)

%% get function definition line, ignoring any preceding lines

fid  = fopen(filename,'r');
Line = '...';
Cnt  = strfind(Line,'...');
while ~isempty(Cnt) % remove any continuation mark, and add next line
    Line  = Line(1:Cnt(1)-1);
    Line2 = [];
    while isempty(Line2)
        Line2 = fgetl(fid);
        Cmt   = strfind(strtrim(Line2),'%'); % only to be preceded by spaces
        if ~(Cmt==1) % remove comment
            Line2 = Line2(1:Cmt(1)-1);
        end
        Line2 = deblank(Line2);
    end
    Line = [Line Line2];
    Cnt  = strfind(Line,'...');
end
fclose(fid);

%% interpret function definition line

Equal = strfind(Line,'=');
if isempty(Equal)
    argout = {};
    InLine = Line;
    ifun = 2;
else
    OutLine = Line(1:Equal-1);
    argout = regexp(OutLine,'[^ \[\](,)]+','match');
    argout = argout(2:end);
    %
    InLine = Line(Equal+1:end);
    ifun = 1;
end
argin  = regexp(InLine,'[^ (,)]+','match');
fcn    = argin{ifun};
argin  = argin(ifun+1:end);
