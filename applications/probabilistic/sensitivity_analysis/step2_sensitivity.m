% Use model results to do sensitivity analysis

clear all;
close all;

% load configuration and paths
load('setup_copula.mat','var_names','var_names','low','high','groups','p','k');
load('paths_copula.mat','paths','vars','map');
step = k / (p-1);
[nPaths,nPoints] = size(paths);
nSegments = nPoints-1;

% get model results
M = importdata('model_results.csv',' ');
M = M(:,2);

% compute elementary effects
iVars = [groups([groups.type] ~= 2).indices];
iVars = [iVars setdiff(1:length(var_names), [groups.indices])];
iGroups = find([groups.type] == 2);
Effects = zeros(nPaths,nSegments);
for iPath=1:nPaths
    for iPoint=2:nPoints
        iSegment = iPoint-1;
        l1 = map(iPath,iPoint-1);
        l2 = map(iPath,iPoint);
        
        iVar = vars(iPath,iSegment);
        if iVar > 0
            iEntity = find(iVars == iVar);
        else
            iEntity = length(iVars) + find(iGroups == -iVar);
        end
        Effects(iPath,iEntity) = (M(l2) - M(l1)) / step;
    end
end

% compute mu, mu_star, sigma
mu = mean(Effects);
mu_star = mean(abs(Effects));
sigma = std(Effects);
names = [var_names(iVars) {groups(iGroups).name}];

% plot
h=figure('units','normalized','outerposition',[0 0 1 1]);
plot(mu_star,sigma,'*','MarkerSize',6);
xlim([0 5]);
xlabel('Absolute mean');
ylabel ('Standard deviation');
lim = xlim();
text(mu_star+0.01*(lim(2)-lim(1)), sigma, names);
xlim([-0.1 5]);
ylim([-0.1 5]);