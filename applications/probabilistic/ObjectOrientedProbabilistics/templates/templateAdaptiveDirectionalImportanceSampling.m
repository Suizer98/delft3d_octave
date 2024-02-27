%% AdaptiveDirectionalImportanceSampling.m template

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
MyLimitState.ResponseSurface    = AdaptiveResponseSurface; %ADIS makes use of a response surface

%% (OPTIONAL) 3.a Use a weighted fit for the response surface (this is still WIP!)
MyLimitState.ResponseSurface.DefaultFit     = false;
MyLimitState.ResponseSurface.WeightedARS    = true;
MyLimitState.ResponseSurface.FitFunction    = @wpolyfitn;

%% 4. Create a LineSearch object (currently only 1 type available)
MyLineSearcher  = LineSearch;

%% 5. Create a AdaptiveDirectionalImportanceSampling object
MyADISObject    = AdaptiveDirectionalImportanceSampling(...
    MyLimitState, MyLineSearcher, MyAccuracy, MyConfidence, ChosenSeed);

%% (OPTIONAL) 5.a Use a StartUpMethod (for increased efficiency)
MyADISObject.StartUpMethod  = StartUpAxialPoints;

%% 6. Calculate the probability of failure
MyADISObject.CalculatePf;