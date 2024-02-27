%% setting up a probabilistic calculation
% This is a script with a tutorial on setting up a probabilistic calculation. The script assumes that oetsettings has been run!

%% create a new function to define the stochastic variables
oetnewfun('prob_example1_stochast',...
    'output', 'stochast')

%% define the "stochast"-variable
% Define the stochastic variables within the newly created function.
% Create a structure with the fields 'Name', 'Distr' and 'Params'. Each
% stochastic variable must have a name, a distribution and parameters. The
% distribution functions should have as first input argument the P
% (probability), the second and possibly following input arguments are the
% parameters which have to be specified in "Params" (in the right order).
% The number of stochastic variables can be chosen depending on the system
% to solve. The definition of the stochast variable can be customised as
% long as the general structure is preserved. The following lines are
% optional; these lines allow the user to set (temporary) one or more 
% variables to deterministic without editting in the function itself.

stochast = struct(...
    'Name', {
        'R'... % example stochastic variable "R" (Resistance or Strength)
        'S'... % example stochastic variable "S" (Solicitation or Load)
        },...
    'Distr', {
        @norm_inv... % distribution function (of R)
        @norm_inv... % distribution function (of S)
        },...
    'Params', {
        {8 1}... % mu and sigma (of R)
        {6 1}... % mu and sigma (of S)
        } ...
    );

%%
OPT = struct(...
    'active', true(size(stochast)));

OPT = setproperty(OPT, varargin{:});

for i = find(~OPT.active)
    stochast(i).Distr = @deterministic;
end

%% create a new function to define the Z-function
% The input and output variables as specified here must be used.
oetnewfun('prob_example1_x2z',...
    'output', 'z',...
    'input', {'samples' 'Resistance' 'varargin'})

%% define the limit state function (Z-function)
% Define the Z-function in the newly created function. Z must be calculated. 
% This part can be customised, as long as the output "z" is a column vector 
% with the same number of rows as samples.R (or of samples.S, which is the 
% same). In this example, z is easily calculated in one line of code. 
% However, many alternatives are possible. Other functions can be called, 
% or even external programs. Note that in some cases a loop is required to 
% calculate all instances separately.

% calculate z (in this case: Z = R - S)
z = samples.R - samples.S;

%% run the calculation with FORM
% After saving both the stochast-function and the x2z-function, the model
% is ready to run. When calling the FORM routine, it is essential that both
% the stochast and the x2z-funtion are parsed.

FORMres = FORM(prob_example1_stochast,...
    'x2zFunction', @prob_example1_x2z);

%% get a summary of the calculations results
displayFORMresult(FORMres)

%% plot the calculation development
plotFORMresult(FORMres)

%% run the calculation with Monte Carlo
% A similar calculation can be easily carried out with the Monte Carlo
% method as well.

MCres = MC(prob_example1_stochast,...
    'x2zFunction', @prob_example1_x2z,...
    'NrSamples', 1000);

%% plot the calculation results
plotMCResult(MCres,...)
    'space', 'x');