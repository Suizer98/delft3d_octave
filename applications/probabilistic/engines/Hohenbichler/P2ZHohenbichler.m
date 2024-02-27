
function Z = P2ZHohenbichler(varargin)

%% Set defaults
OPT = struct('Pu1st', [], 'Pu2st', [], 'Var', []);

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});


%% read input for Z-function
%samples=struct(varargin{1:end-1});
Var = OPT.Var;
%[Xt, Smaxpars, factSmax] = deal(Var.Xt, Var.Smaxpars, Var.factSmax);



% samples=struct(varargin{1:end-1});
% Var = varargin{end};

% single Z-function that describes (Z2<0|Z1<0)
rho=Var.rho;
u1st=norminv(1-Var.pf1*OPT.Pu1st);
u2st=norminv(OPT.Pu2st);
Z = Var.beta2 - rho*u1st-sqrt(1-rho.^2)*u2st;

