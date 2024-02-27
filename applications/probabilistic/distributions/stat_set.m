function options = stat_set(varargin)
%STATSET Create/alter STATS options structure.
%   OPTIONS = STATSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates a
%   statistics options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to [].  When
%   you pass OPTIONS to a statistics function, a parameter set to []
%   indicates that the function uses its default value for that parameter.
%   Case is ignored for parameter names, and unique partial matches are
%   allowed.  NOTE: For parameters that are string-valued, the complete
%   string is required for the value; if an invalid string is provided, the
%   default is used.
%
%   OPTIONS = STATSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of
%   OLDOPTS with the named parameters altered with the specified values.
%
%   OPTIONS = STATSET(OLDOPTS,NEWOPTS) combines an existing options
%   structure OLDOPTS with a new options structure NEWOPTS.  Any parameters
%   in NEWOPTS with non-empty values overwrite the corresponding old
%   parameters in OLDOPTS.
%
%   STATSET with no input arguments and no output arguments displays all
%   parameter names and their possible values, with defaults shown in {}
%   when the default is the same for all functions that use that option.
%   Use STATSET(STATSFUNCTION) (see below) to see function-specific
%   defaults for a specific function.
%
%   OPTIONS = STATSET (with no input arguments) creates an options
%   structure OPTIONS where all the fields are set to [].
%
%   OPTIONS = STATSET(STATSFUNCTION) creates an options structure with all
%   the parameter names and default values relevant to the statistics
%   function named in STATSFUNCTION.  STATSET sets parameters in OPTIONS to
%   [] for parameters that are not valid for STATSFUNCTION.  For example,
%   statset('factoran') or statset(@factoran) returns an options structure
%   containing all the parameter names and default values relevant to the
%   function 'factoran'.
%
%   STATSET parameters:
%      Display     - Level of display.  'off', 'iter', or 'final'.
%      MaxFunEvals - Maximum number of objective function evaluations
%                    allowed.  A positive integer.
%      MaxIter     - Maximum number of iterations allowed.  A positive integer.
%      TolBnd      - Parameter bound tolerance.  A positive scalar.
%      TolFun      - Termination tolerance for the objective function
%                    value.  A positive scalar.
%      TolTypeFun  - Flag to indicate how to use 'TolFun'. 'abs' indicates
%                    using 'TolFun' as an absolute tolerance; 'rel'
%                    indicates using it as a relative tolerance.
%      TolX        - Termination tolerance for the parameters.  A positive scalar.
%      TolTypeX    - Flag to indicate how to use 'TolX'. 'abs' indicates
%                    using 'TolX' as an absolute tolerance; 'rel'
%                    indicates using it as a relative tolerance.
%      GradObj     - Flag to indicate whether the objective function can return
%                    a gradient vector as a second output.  'off' or 'on'.
%      Jacobian    - Flag to indicate whether the model function can return a
%                    Jacobian as a second output.  'off' or 'on'.
%      DerivStep   - Relative difference used in finite difference derivative
%                    calculations.  A positive scalar, or a vector of
%                    positive scalars the same size as the vector of model
%                    parameters being estimated.
%      FunValCheck - Check for invalid values, such as NaN or Inf, from
%                    the objective function.  'off' or 'on'.
%      Robust      - Flag to invoke the robust fitting option.  'off' (the default)
%                    or 'on'.
%      WgtFun      - A weight function for robust fitting.  Valid only when Robust
%                    is 'on'.  'bisquare' (the default), 'andrews', 'cauchy',
%                    'fair', 'huber', 'logistic', 'talwar', or 'welsch'.  Can
%                    also be a function handle that accepts a normalized residual
%                    as input and returns the robust weights as output.
%      Tune        - The tuning constant used in robust fitting to normalize the
%                    residuals before applying the weight function.  A positive
%                    scalar.  The default value depends upon the weight function.
%                    This parameter is required if the weight function is
%                    specified as a function handle.
%      UseParallel - Flag to indicate whether eligible functions should use
%                    capabilities of the Parallel Computing Toolbox (PCT),
%                    if the capabilities are available. Valid values are
%                    'never' (the default), to indicate serial computation,
%                    and 'always', to request parallel computation.
%                    See PARALLELSTATS for more complete information about
%                    this parameter.
%      UseSubstreams-Flag to indicate whether the random number generator
%                    in eligible functions should use the substream feature
%                    of the random number stream. 'never' (default) or
%                    'always'. If 'always', the function will use the
%                    substream feature during iterative loops in such a way
%                    as to generate reproducible random number streams in
%                    parallel and/or serial mode computation.
%                    See PARALLELSTATS for more complete information about
%                    this parameter.
%      Streams     - A single random number stream, or a cell array of random
%                    number streams.  The Streams option is accepted by some
%                    Statistics Toolbox functions to govern what stream(s) to
%                    use when generating random numbers within the function.
%                    Acceptable values for the Streams parameter vary depending
%                    on the Statistics Toolbox function and on other factors.
%                    See PARALLELSTATS for more complete information about
%                    this parameter.
%      OutputFcn   - Function handle specified using @, a cell array with
%                    function handles or an empty array (default).  The
%                    solver calls all output functions after each
%                    iteration.
%
%   See also STATGET.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 5405 $  $Date: 2011-11-01 21:21:37 +0800 (Tue, 01 Nov 2011) $

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    fprintf('                Display: [ {off} | final | iter ]\n');
    fprintf('            MaxFunEvals: [ positive integer ]\n');
    fprintf('                MaxIter: [ positive integer ]\n');
    fprintf('                 TolBnd: [ positive scalar ]\n');
    fprintf('                 TolFun: [ positive scalar ]\n');
    fprintf('             TolTypeFun: [''abs'' |''rel'']\n')
    fprintf('                   TolX: [ positive scalar ]\n')
    fprintf('               TolTypeX: [''abs'' |''rel'']\n')
    fprintf('                GradObj: [ {off} | on ]\n')
    fprintf('               Jacobian: [ {off} | on ]\n')
    fprintf('              DerivStep: [ positive scalar or vector ]\n')
    fprintf('            FunValCheck: [ off | {on} ]\n')
    fprintf('                 Robust: [ {off} | on ]\n')
    fprintf('                 WgtFun: [ {bisquare} | andrews | cauchy | fair | huber | logistic | talwar | welsch | function handle ]\n')
    fprintf('                   Tune: [ positive scalar ]\n')
    fprintf('            UseParallel: [ {never} | always ]\n')
    fprintf('          UseSubstreams: [ {never} | always ]\n')
    fprintf('                Streams: [ {} | RandStream or cell array ]\n')
    fprintf('              OutputFcn: [ {[]} | function handle or cell array ]\n')
    fprintf('\n');
    return;
end

options = struct('Display', [], 'MaxFunEvals', [], 'MaxIter', [], ...
    'TolBnd', [], 'TolFun', [], 'TolTypeFun',[],'TolX', [], 'TolTypeX',[], ...
    'GradObj', [], 'Jacobian', [], 'DerivStep', [], 'FunValCheck', [], ...
    'Robust',[], 'WgtFun',[], 'Tune',[], ...
    'UseParallel',[], 'UseSubstreams',[], 'Streams', [], 'OutputFcn', []);

% If a function name/handle was passed in, then return the defaults.
if nargin == 1
    arg = varargin{1};
    if (ischar(arg) || isa(arg,'function_handle'))
        if isa(arg,'function_handle')
            arg = func2str(arg);
        end
        % Display is off by default.  The individual fitters have their own
        % warning/error messages that can be controlled via IDs.  The
        % optimizers print out text when display is on, but do not generate
        % warnings or errors per se.
        options.Display = 'off';
        switch lower(arg)
            case 'factoran' % this uses statsfminbx
                options.MaxFunEvals = 400;
                options.MaxIter = 100;
                options.TolFun = 1e-8;
                options.TolX = 1e-8;
            case {'normfit' 'lognfit' 'gamfit' 'bisafit' 'invgfit' 'logifit'...
                  'loglfit' 'nakafit' 'coxphfit'} % these use statsfminbx
                options.MaxFunEvals = 200;
                options.MaxIter = 100;
                options.TolBnd = 1e-6;
                options.TolFun = 1e-8;
                options.TolX = 1e-8;
            case {'evfit' 'wblfit'} % these use fzero (gamfit sometimes does too)
                options.TolX = 1e-6;
            case 'copulafit' % this uses fminbnd
                options.MaxFunEvals = 200;
                options.MaxIter = 100;
                options.TolX = 1e-6;
                options.TolBnd = 1e-6;
            case {'gpfit' 'gevfit' 'nbinfit' 'ricefit' 'tlsfit'} % these use fminsearch
                options.MaxFunEvals = 400;
                options.MaxIter = 200;
                options.TolBnd = 1e-6;
                options.TolFun = 1e-6;
                options.TolX = 1e-6;
            case 'kmeans'
                options.MaxIter = 100;
            case 'svmtrain'
                % do nothing because QP and SMO have different MaxIter values.
            case 'nlinfit'
                options.MaxIter = 200;
                options.TolFun = 1e-8;
                options.TolX = 1e-8;
                options.DerivStep = eps^(1/3);
                options.FunValCheck = 'on';
                options.Robust = 'off';
                options.WgtFun = 'bisquare';
                options.Tune = []; % default varies by WgtFun, must be supplied for user-defined WgtFun
            case 'nlmefit'
                options.MaxIter = 200;
                options.TolFun = 1e-4;
                options.TolX = 1e-4;
                options.DerivStep = eps^(1/3);
                options.Jacobian = 'off';
                options.FunValCheck = 'on';
                options.OutputFcn = '';
            case 'nlmefitsa'
                options.DerivStep = eps^(1/3);
                options.FunValCheck = 'on';
                options.Streams = {};
                options.OutputFcn = {@nlmefitoutputfcn};
            case 'mlecustom' % this uses fminsearch, or maybe fmincon
                options.MaxFunEvals = 400;
                options.MaxIter = 200;
                options.TolBnd = 1e-6;
                options.TolFun = 1e-6;
                options.TolX = 1e-6;
                options.GradObj = 'off';
                options.DerivStep = eps^(1/3);
                options.FunValCheck = 'on';
            case 'mlecov'
                options.GradObj = 'off';
                options.DerivStep = eps^(1/4);
            case 'mdscale'
                options.MaxIter = 200;
                options.TolFun = 1e-6;
                options.TolX = 1e-6;
            case {'mvncdf' 'mvtcdf'}
                options.MaxFunEvals = 1e7;
                options.TolFun = []; % 1e-8 for dim < 4, 1e-4 otherwise
            case {'gmdistribution'}
                options.MaxIter = 100;
                options.TolFun = 1e-6;
            case {'nnmf'}
                options.MaxIter = 100;
                options.TolFun = 1e-4;
                options.TolX = 1e-4;
                options.UseParallel = 'never';
                options.UseSubstreams = 'never';
                options.Streams = {};
            case {'sequentialfs'}
                options.MaxIter = Inf;
                options.TolTypeFun = 'rel';
                options.UseParallel = 'never';
                options.UseSubstreams = 'never';
                options.Streams = {};
            case {'bootci' 'bootstrp' 'candexch' 'cordexch' 'crossval' 'daugment' 'dcovary' 'plsregress' 'rowexch' 'treebagger'}
                options.UseParallel = 'never';
                options.UseSubstreams = 'never';
                options.Streams = {};
            case {'jackknife'}
                options.UseParallel = 'never';
            otherwise
                error(message('stats:statset:BadFunctionName', arg));
        end
        return
    end
end

names = fieldnames(options);
lowNames = lower(names);
numNames = numel(names);

% Process OLDOPTS and NEWOPTS, if it's there.
i = 1;
while i <= nargin
    arg = varargin{i};
    % Check if we're into the param name/value pairs yet.
    if ischar(arg), break; end

    if ~isempty(arg) % [] is a valid options argument
        if ~isa(arg,'struct')
            error('stats:statset:BadInput',...
                ['Expected argument %d to be a parameter name string or ' ...
                'an options structure\ncreated with STATSET.'], i);
        end
        argNames = fieldnames(arg);
        for j = 1:numNames
            name = names{j};
            if any(strcmp(name,argNames))
                val = arg.(name);
                if ~isempty(val)
                    if ischar(val)
                        val = lower(deblank(val));
                    end
                    [valid, errid, errmsg] = checkparam(name,val);
                    if valid
                        options.(name) = val;
                    elseif ~isempty(errmsg)
                        error(errid,errmsg);
                    end
                end
            end
        end
    end
    i = i + 1;
end

% Done with OLDOPTS and NEWOPTS, now parse parameter name/value pairs.
if rem(nargin-i+1,2) ~= 0
    error(message('stats:statset:BadInput'));
end
expectval = false; % start expecting a name, not a value
while i <= nargin
    arg = varargin{i};

    % Process a parameter name.
    if ~expectval
        if ~ischar(arg)
            error('stats:statset:BadParameter',...
                'Expected argument %d to be a parameter name string.', i);
        end
        lowArg = lower(arg);
        j = strmatch(lowArg,lowNames);
        if numel(j) == 1 % one match
            name = names{j};
        elseif length(j) > 1 % more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,lowNames,'exact');
            if numel(k) == 1
                name = names{k};
            else
                matches = [names{j(1)}, sprintf(', %s',names{j(2:end)})];
                error('stats:statset:BadParameter',...
                    'Ambiguous parameter name ''%s'' (%s)', arg, matches);
            end
        else %if isempty(j) % no matches
            error('stats:statset:BadParameter',...
                'Unrecognized parameter name ''%s''.', arg);
        end
        expectval = true; % expect a value next

        % Process a parameter value.
    else
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        [valid, errid, errmsg] = checkparam(name,arg);
        if valid
            options.(name) = arg;
        elseif ~isempty(errmsg)
            error(errid,errmsg);
        end
        expectval = false; % expect a name next
    end
    i = i + 1;
end

% The default wgt function for robust fit is bisquare.
if (strcmp(options.Robust, 'on') && isempty(options.WgtFun))
    options.WgtFun = 'bisquare';
end
if strcmp(options.Robust, 'on')
    if ischar(options.WgtFun)
        [~,~,~,options.Tune] = statrobustwfun(options.WgtFun,[]);
    end
    if isempty(options.Tune) || ~isnumeric(options.Tune)
        error('stats:statset:BadParameter', 'Tune must be provided for user-defined WgtFun');
    end
end

%-------------------------------------------------
function [valid, errid, errmsg] = checkparam(name,value)
%CHECKPARAM Validate a STATSET parameter value.
%   [VALID,ID,MSG] = CHECKPARAM('name',VALUE) checks that the specified
%   value VALUE is valid for the parameter 'name'.
valid = true;
errmsg = '';
errid = '';

% Empty is always a valid parameter value.
if isempty(value)
    return
end

switch name
    case {'TolBnd','TolX'} % positive real scalar
        if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || value <= 0
            valid = false;
            errid = 'stats:statset:BadTolerance';
            if ischar(value)
                errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
            else
                errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
            end
        end
    case  {'TolFun'}
        if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || value < 0
            valid = false;
            errid = 'stats:statset:BadTolerance';
            if ischar(value)
                errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
            else
                errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
            end
        end
    case {'TolTypeFun', 'TolTypeX'}
        values = ['abs'; 'rel'];
        if ~ischar(value) || isempty(strmatch(value,values,'exact'))
            valid = false;
            errid = 'stats:statset:BadTolType';
            errmsg = sprintf('STATSET parameter ''%s'' must be ''abs'' or ''rel''.',name);
        end
    case {'Display'} % off,final,iter; we accept notify, but don't advertise it
        values = ['off   '; 'notify'; 'final '; 'iter  '];
        if ~ischar(value) || isempty(strmatch(value,values,'exact'))
            valid = false;
            errid = 'stats:statset:BadDisplay';
            errmsg = sprintf('STATSET parameter ''%s'' must be ''off'', ''final'', or ''iter''.',name);
        end
    case {'MaxIter' 'MaxFunEvals'} % non-negative integer, possibly inf
        if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || any(value < 0)
            valid = false;
            errid = 'stats:statset:BadMaxValue';
            if ischar(value)
                errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
            else
                errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
            end
        end
    case {'GradObj' 'Jacobian' 'FunValCheck' 'Robust'}
        values = ['off'; 'on '];
        if ~ischar(value) || isempty(strmatch(value,values,'exact'))
            valid = false;
            errid = 'stats:statset:BadFlagValue';
            errmsg = sprintf('STATSET parameter ''%s'' must be ''off'' or ''on''.',name);
        end
    case {'WgtFun'}
        values = ['andrews ';'bisquare';'cauchy  ';'fair    '; 'huber   '; 'logistic'; 'talwar  ';  'welsch  '];
        % allow custom wgt function
        if ~strcmp(class(value), 'function_handle')&&(~ischar(value) || isempty(strmatch(value,values,'exact')))
            valid = false;
            errid = 'stats:statset:BadWeightFunction';
            errmsg = sprintf('STATSET parameter ''%s'' is not valid.',name);
        end
    case 'DerivStep'
        if ~isfloat(value) || ~isreal(value) || any(value <= 0) || ~isvector(value)
            valid = false;
            errid = 'stats:statset:BadDifference';
            errmsg = sprintf('STATSET parameter ''%s'' must be a scalar or vector containing real positive values.',name);
        end
    case 'Tune'
        if ~isfloat(value) || ~isreal(value) || any(value <= 0)
            valid = false;
            errid = 'stats:statset:BadTune';
            errmsg = sprintf('STATSET parameter ''%s'' must contain real positive values.',name);
        end
    case {'UseParallel' 'UseSubstreams'}
        values = ['never '; 'always'];
        if ~ischar(value) || isempty(strmatch(value,values,'exact'))
            valid = false;
            errid = 'stats:statset:BadParameterValue';
            errmsg = sprintf('STATSET parameter ''%s'' must be ''never'' or ''always''.',name);
        end
    case {'Streams'}
        if ~( isempty(value) || isa(value,'RandStream') || (iscell(value) && all(cellfun(@(x)isa(x,'RandStream'),value))) )
            valid = false;
            errid = 'stats:statset:BadParameterValue';
            errmsg = sprintf('STATSET parameter ''%s'' must be a RandStream or cell array of RandStreams',name);
        end
    case {'OutputFcn'}
        if ~((iscell(value) && all(cellfun(@(x) isa(x,'function_handle'),value))) || isa(value,'function_handle'))
            valid = false;
            errid = 'stats:statset:BadParameterValue';
            errmsg = sprintf('STATSET parameter ''%s'' must be a function handle class or a cell array with function handles.',name);
        end

    otherwise
        valid = false;
        errid = 'stats:statset:BadParameter';
        errmsg = sprintf('Invalid STATSET parameter name: ''%s''.',name);
end
