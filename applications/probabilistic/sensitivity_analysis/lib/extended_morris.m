% Extended Morris method, which takes into account dependencies
%
% Paths = extended_morris(p,k,r,Corr,Groups)
%   p       = number of grid points; grid will be (p-1) x (p-1)
%   k       = Morris step size; integer, to be multiplied with 1/(p-1)
%   r       = number of Morris paths
%   Corr	= n x n correlation matrix, used to constrain the sampling of base values for the paths
%             alternatively, one can specify a scalar, n, and independence will be assumed
%   scalar
%   Groups  = structure vector describing groups, with fields:
%             * indices: row vector giving the indices of the variables
%             * prob: upper triangular probability matrix, which constrains the way variables vary together
%                     prob(i,i) = P(Xi increases), prob(i,j) = P(Xi increases | Xj increases)
%             * type: constrains the succession in which the variables should be changed 
%                     0, free
%                     1, consecutively within the group
%                     2, simultaneously
%             * name: label to be used on the sensitivity plot; only relevant if type=2
%   ! Groups are assumed disjunct
%
%   Paths   = r x (m+1) cell array describing the gridpoints along the paths
%   Vars    = r x m array giving the index of the target variable for each path segment
%   where m <= n is the number of separate entities to be changed (see type=2 and nSegments)

function [Paths,Vars] = extended_morris(p,k,r,Corr,Groups)

% parse input
if nargin < 4
    error('Insufficient arguments; need to provide at least p,k,r,Corr');
elseif p < 2
    error('p needs to be an integer >= 2');
elseif k < 1 || k > p-1
    error('k needs to be an integer between 1 and (p-1)');
elseif r<0
    error('r needs to be a positive integer');
elseif isempty(Corr) || length(size(Corr)) ~= 2 || size(Corr,1) ~= size(Corr,2)
    error('Corr needs to be a valid correlation matrix');
end

if size(Corr,1) == 1
    nVars = Corr;
    Corr = eye(nVars);
else
    nVars = size(Corr,1);
end

% create a separate group with the unspecified vars
if ~exist('Groups','var')
    nGroups = 0;
    leftovers = 1:nVars;
else
    nGroups = length(Groups);
    leftovers = setdiff(1:nVars,[Groups.indices]);
end
if ~isempty(leftovers)
    Groups(nGroups+1).indices = leftovers;
    Groups(nGroups+1).prob = triu(0.5*ones(length(leftovers)));     % all independent with even chance
    Groups(nGroups+1).type = 0;                                     % no order preference
end

nGroups = length(Groups);

% initialize Dichotomic Gaussians for each group
for iGroup = 1:nGroups
    n = length(Groups(iGroup).indices);
    Prob = Groups(iGroup).prob;
    %   Mu(i) = E[Xi] = P(Xi=1)
    Mu = diag(Prob);
    %   complete the lower part of Prob, according to Bayes' rule:
    %   P(Xj=1 | Xi=1) = P(Xi=1 | Xj=1) * P(Xj=1) / P(Xi=1)
    Prob = Prob + bsxfun(@rdivide, bsxfun(@times, Prob', Mu), Mu');
    Prob(1 : n+1 : n*n) = Mu; % restore diagonal
    %   Sigma(i,j) = Cov(Xi,Xj) = P(Xj=1 | Xi=1)*P(Xi=1) - P(Xi=1)*P(Xj=1)
    Sigma = bsxfun(@times, Prob', Mu) - Mu * Mu';
    %   Sigma(i,i) = Var(Xi) = P(Xi=1) - P(Xi=1)^2
    Sigma(1 : n+1 : n*n) = Mu - Mu.^2;
    
    [Groups(iGroup).Gamma, Groups(iGroup).Rho] = initDG(Mu,Sigma);
end
	 
% grid: (p-1) x (p-1) cells
% latin hypercube: (p-k) x (p-k) cells
step = k / (p-1);

% get next multiple of (p-k), after r
% see http://stackoverflow.com/questions/3844048/ceiling-to-nearest-50
nPaths = r + mod(-r, p-k); 

% sample the paths
simultGroups = find([Groups.type] == 2);
consecGroups = find([Groups.type] == 1);
freeVars = [Groups([Groups.type] == 0).indices];
nSegments = length(freeVars) + length([Groups(consecGroups).indices]) + length(simultGroups);
Paths = cell(nPaths,nSegments+1);
Vars = zeros(nPaths,nSegments);
for iCube = 1:nPaths/(p-k)
    % choose the target cells (i.e. the base values for the vars)
    %   get (p-k) samples from the copula
    u = copularnd('Gaussian',Corr,p-k); % (p-k) x n matrix
    %   compute rank statistics
    Rank = zeros(nVars,p-k);
    for iVar=1:nVars
        Rank(iVar,:) = tiedrank(u(:,iVar));
    end
    %   constrained Latin Hypercube samples
    Cells = (Rank' - 1) ./ (p-1);

    % for each cell
    for iCell=1:p-k
        % choose a corner
        Corner = zeros(1,nVars);
        for iGroup = 1:nGroups
            Corner(Groups(iGroup).indices) = sampleDG(Groups(iGroup).Gamma, Groups(iGroup).Rho, 1);
        end
        OppositeCorner = not(Corner);
        
        % choose an order
        %   get a permutation of the separate 'entities'
        Perm = randperm(length(freeVars)+length(consecGroups)+length(simultGroups));
        %   translate the permutation to indices of variables/groups
        j = 1;
        for i = 1:length(Perm)
            if Perm(i) <= length(freeVars)                                  
                % we have a free var
                Vars((iCube-1)*(p-k)+iCell, j) = Perm(i);
                j = j+1;
            elseif Perm(i) - length(freeVars) <= length(consecGroups)
                % we have a consecutive group
                iGroup = consecGroups(Perm(i) - length(freeVars));
                nGroupVars = length(Groups(iGroup).indices);
                Vars((iCube-1)*(p-k)+iCell, j : j+nGroupVars-1) = Groups(iGroup).indices(randperm(nGroupVars));
                j = j+nGroupVars;
            else
                % we have a simultaneous group
                iGroup = simultGroups(Perm(i) - length(freeVars) - length(consecGroups));
                Vars((iCube-1)*(p-k)+iCell, j) = -iGroup;  % placeholder
                j = j+1;
            end
        end
                
        % construct the paths 
        iPath = (iCube-1)*(p-k)+iCell;
        Paths{iPath, 1} = Cells(iCell, :) + step*Corner;
        Paths{iPath, nSegments+1} = Cells(iCell, :) + step*OppositeCorner;
        for iPoint = 2:nSegments
            iSegment = iPoint-1;
            Paths{iPath, iPoint} = Paths{iPath, iPoint-1};
            if Vars(iPath, iSegment) > 0
                % one var
                Paths{iPath, iPoint}(Vars(iPath, iSegment)) = Paths{iPath, end}(Vars(iPath, iSegment));
            else
                % a group of vars
                iGroup = -Vars(iPath, iSegment);
                Paths{iPath, iPoint}(Groups(iGroup).indices) = Paths{iPath, end}(Groups(iGroup).indices);
            end
        end
    end
end

% throw away the extra paths
Paths = Paths(1:r, :);
Vars = Vars(1:r,:);

end