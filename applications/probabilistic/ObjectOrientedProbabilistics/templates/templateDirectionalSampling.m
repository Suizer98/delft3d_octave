%% DirectionalSampling.m template

%% 1. Create random variables needed for LimitStateFunction
NrOfRandomVariables = 2;
MyVariables(NrOfRandomVariables,1) = RandomVariable;

for i=1:NrOfRandomVariables
    MyVariables(i,1).Name                     = ['U' num2str(i)]; % These names have to match the names used in the LimitStateFunction exactly!
    MyVariables(i,1).Distribution             = @norm_inv; % Each variable can have a different ditribution&parameters
    MyVariables(i,1).DistributionParameters   = {0 1};
end

%% 2. Create a LimitStateFunction

% Please follow the templateLimitStateFunction

%% 3. Create a LimitState object describing your problem
MyLimitState                    = LimitState; 
MyLimitState.Name               = 'MyProblem';
MyLimitState.LimitStateFunction = @MyLimitStateFunction; %given as a function handle
MyLimitState.RandomVariables    = MyVariables; %RandomVariable objects defined above

%% 4. Create a LineSearch object (currently only 1 type available)
MyLineSearcher  = LineSearch;

%% 5. Create a DirectionalSampling object
MyDirectionalSamplingObject     = DirectionalSampling(...
    MyLimitState, MyLineSearcher, MyAccuracy, MyConfidence, ChosenSeed);

%% 6. Make additional settings (if necessary)
MyDirectionalSamplingObject.MaxNrDirections = MyMaxNrDirections; % default is equal to 1000
MyDirectionalSamplingObject.MinNrDirections = MyMinNrDirections; % default is equal to 0
MyDirectionalSamplingObject.MaxCOV = MyMaxCOV;  % default is equal to 0.1

%% 7. Calculate the probability of failure
MyDirectionalSamplingObject.CalculatePf;