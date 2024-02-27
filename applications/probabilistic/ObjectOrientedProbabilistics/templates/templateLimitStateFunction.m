%% Template for creating a LimitStateFunction (used in the LimitState object)

function z = MyLimitStateFunction(varargin)
% Description of MyLimitStateFunction

OPT = struct(...
    'VariableName1', [], ...   % These names have to match the names used in the RandomVariable object exactly!
    'VariableName2', [], ...
    'VariableName3', []);

OPT = setproperty(OPT, varargin{:});

%% limit state function

z = ... %Actual LimitStateFunction using OPT.VariableName1, OPT.VariableName2
% e.g. z = OPT.VariableName1 + 5*OPT.VariableName2^2 - sqrt(OPT.VariableName3)