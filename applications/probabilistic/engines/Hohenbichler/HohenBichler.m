function [betaOR, betaAND] = HohenBichler(beta, pf, rho, method)

% the Hohenbichler method for computing P(Z1<0 OR PZ2<0) and P(Z1<0 AND
% PZ2<0). Z1 is described by its failure probability pf.
% Z2 is described by reliability index beta. The
% mutual correlation is described by random variable rho

% Input
%   - beta: reliability index of Z2
%   - pf: failure probability of Z1
%   - rho: correlation between Z1 and Z2
%   - method: 'Numerical'(default) or 'FORM'
%
% Output
%   - betaOR:    beta for P[Z1<0 OR Z2<0]
%   - betaAND:   beta for P[Z1<0 AND Z2<0]

if abs(rho-1)<1e-5
    beta1 = -norminv(pf);
    betaOR = min(beta, beta1);
    betaAND = max(beta, beta1);

% otherwise: start HohenBichler procedure
else

    % put beta1 in structure for FORM procedure
    x2zvariables = struct(...
        'beta2',  beta,...      % betavalue of Z2
        'pf1', pf, ...          % probability of failure of Z1
        'rho', rho ...         % correlation between Z1 and Z2
        );

    % structure with stochastic variables
    stochast = struct('Name', {
        'Pu1st'
        'Pu2st'
        });
    ns=length(stochast);
    for jj=1:ns
        stochast(jj).Distr = @unif_inv;  % all variables standard uniformly distributed
        stochast(jj).Params = {0 1};
        stochast(jj).propertyName = true;
    end

    
 %% option default: compute P(Z'<0) with Numerical integration
    if strcmp(method,'Numerical')
        
        beta1 = -norminv(pf);  % beta-value of element 1
        ngrid=1001;            % number of grids for numerical integration
        
        u1 = linspace(-beta1-10, -beta1, ngrid);    % grid end points
        u1c = mean([u1(1:end-1);u1(2:end)]);        % grid centers
        PZu1c = normcdf(-(beta+rho*u1c)/sqrt(max(0,1-rho^2))); %P[Z1<0|U1=u1];
        PZcond = sum(PZu1c.*diff(u1).*normpdf(u1c))/normcdf(-beta1); %P[Z1<0|Z2<0]
        
%         % other method, same results
%         u1 = linspace(beta1, beta1+10, ngrid);    % grid end points
%         u1c = mean([u1(1:end-1);u1(2:end)]);        % grid centers
%         PZu1c = normcdf(-(beta-rho*u1c)/sqrt(max(0,1-rho^2))); %P[Z1<0|U1=u1];
%         PZcond = sum(PZu1c.*diff(u1).*normpdf(u1c))/normcdf(-beta1); %P[Z1<0|Z2<0]
    end
    
 %% option 2: compute P(Z'<0) with form
    if strcmp(method,'FORM')
        
     done = false;
     try
         resultFORM = FORM('stochast', stochast, ...
             'du', .1,...               % step size for dz/du / Perturbation Value
             'maxdZ', 0.001,...         % second stop criterion for change in z-value
            'method', 'loop', ...
            'DerivativeSides', 1,... % 1 or 2 sided derivatives
            'x2zVariables', {'Var', x2zvariables}, ...
            'x2zFunction', @P2ZHohenbichler ...                     % Function to transform x to z
            );
        PZcond = resultFORM.Output.P_f;
        done=true;
    catch
        if ~isempty(which('FORM.m'))
            warning('FORM crashed in Hohenbichler procedure, NI used instead');
        end

     end
     
    % if FORM unsuccesful or not executed, compute conditional probability with NI
                if ~done
                    beta1 = -norminv(pf);  % beta-value of element 1
                    ngrid=1001;            % number of grids for numerical integration

                    u1 = linspace(-beta1-10, -beta1, ngrid);    % grid end points
                    u1c = mean([u1(1:end-1);u1(2:end)]);        % grid centers
                    PZu1c = normcdf(-(beta+rho*u1c)/sqrt(max(0,1-rho^2))); %P[Z1<0|U1=u1];
                    PZcond = sum(PZu1c.*diff(u1).*normpdf(u1c))/normcdf(-beta1); %P[Z1<0|Z2<0]
                end
    
    end
    

 

%% compute AND and OR relations

    % compute P(Z1<0 AND PZ2<0)
    PfAND = PZcond*pf;
    betaAND = norminv(1-PfAND);

    % compute P(Z1<0 OR PZ2<0)
    PfOR = normcdf(-beta)+pf-PfAND;
    betaOR = norminv(1-PfOR);
end