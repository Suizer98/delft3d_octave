% Use Morris method to sample model runs

clear all; 
close all;
% add library folder, containing the necessary functions
addpath(fullfile(pwd,'lib'));

% model parameter definition (index and name)
TauShields = 1;     var_names{TauShields} = 'TauShields';        
VSedIM1 = 2;        var_names{VSedIM1} = 'VSedIM1';              
VSedIM2 = 3;        var_names{VSedIM2} = 'VSedIM2';              
VSedIM3 = 4;        var_names{VSedIM3} = 'VSedIM3';              
TaucRS1IM1 = 5;     var_names{TaucRS1IM1} = 'TaucRS1IM1';        
TaucRS1IM2 = 6;     var_names{TaucRS1IM2} = 'TaucRS1IM2';        
TaucRS1IM3 = 7;     var_names{TaucRS1IM3} = 'TaucRS1IM3';        

FactResPup = 8;     var_names{FactResPup} = 'FactResPup';        
FrIM1SedS2 = 9;     var_names{FrIM1SedS2} = 'FrIM1SedS2';        
FrIM2SedS2 = 10;    var_names{FrIM2SedS2} = 'FrIM2SedS2';        
FrIM3SedS2 = 11;    var_names{FrIM3SedS2} = 'FrIM3SedS2';        
VResIM1 = 12;       var_names{VResIM1} = 'VResIM1';              
VResIM2 = 13;       var_names{VResIM2} = 'VResIM2';              
VResIM3 = 14;       var_names{VResIM3} = 'VResIM3';              

% parameter ranges (in the order of the indices defined above)
low =     [ 0.4  ,  5.04,   43.2,  0.10,  0.05, 0.05, 0.05,    8e-9, 0.05, 0.05, 0.05, 0.05, 0.20, 0.20];
high =    [ 1.2  , 43.20 , 172.8,  5.04,  0.20, 0.20, 0.20,    8e-8, 0.40, 0.40, 0.40, 0.50, 1.20, 1.20];

% Sensitivity analysis settings (Morris method)
p = 4;                          % Morris grid points
k = 2;							% Morris step size (in # ofgrid cells)
r = 10;                         % number of Morris paths
n = 14;                         % number of variables
corr = diag(ones(1,n));			% n x n correlation matrix
c = 1;
% Define the rank correlations between parameters: -1 (fully inversely correlated) <= corr(i,j) <= 1 (fully positively correlated)
% The correlations may be different and will define the copula.
corr(TauShields,FactResPup) = c; corr(FactResPup,TauShields) = c;
corr(TaucRS1IM1,VResIM1) = c; corr(VResIM1,TaucRS1IM1) = c;
corr(TaucRS1IM2,VResIM2) = c; corr(VResIM2,TaucRS1IM2) = c;
corr(TaucRS1IM3,VResIM3) = c; corr(VResIM3,TaucRS1IM3) = c;
corr(VSedIM1,FrIM1SedS2) = -c; corr(FrIM1SedS2,VSedIM1) = -c;
corr(VSedIM2,FrIM2SedS2) = -c; corr(FrIM2SedS2,VSedIM2) = -c;
corr(VSedIM3,FrIM3SedS2) = -c; corr(FrIM3SedS2,VSedIM3) = -c;

% Define groups
groups(1).indices = [TauShields,FactResPup];							% variables in this group
groups(1).name = [var_names{TauShields} '-' var_names{FactResPup}];		% also their names, for plotting
groups(1).prob = [0.5 1; 0 0.5];                % upper triangular probability matrix 
                                                % prob(i,j) = P(Xi increases | Xj increases)
                                                % prob(i,i) = P(Xi increases)
                                                % lower triangular part will be filled in automatically, according to Bayes' rule
%  type = 2, to determine sensitivity of the group (as one entity)
%  type = 1, to determine individual parameter sensitivities												
groups(1).type = 2;                             

groups(2).indices = [TaucRS1IM1,VResIM1];
groups(2).prob = [0.5 1; 0 0.5];
groups(2).type = 2;
groups(2).name = [var_names{TaucRS1IM1} '-' var_names{VResIM1}];

groups(3).indices = [TaucRS1IM2,VResIM2];
groups(3).prob = [0.5 1; 0 0.5];
groups(3).type = 2;
groups(3).name = [var_names{TaucRS1IM2} '-' var_names{VResIM2}];

groups(4).indices = [TaucRS1IM3,VResIM3];
groups(4).prob = [0.5 1; 0 0.5];
groups(4).type = 2;
groups(4).name = [var_names{TaucRS1IM3} '-' var_names{VResIM3}];

groups(5).indices = [VSedIM1,FrIM1SedS2];
groups(5).prob = [0.5 0; 0 0.5];
groups(5).type = 2;
groups(5).name = [var_names{VSedIM1} '-' var_names{FrIM1SedS2}];

groups(6).indices = [VSedIM2,FrIM2SedS2];
groups(6).prob = [0.5 0; 0 0.5];
groups(6).type = 2;
groups(6).name = [var_names{VSedIM2} '-' var_names{FrIM2SedS2}];

groups(7).indices = [VSedIM3,FrIM3SedS2];
groups(7).prob = [0.5 0; 0 0.5];
groups(7).type = 2;
groups(7).name = [var_names{VSedIM3} '-' var_names{FrIM3SedS2}];

% use Morris to generate the paths
[paths,vars] = extended_morris(p,k,r,corr,groups);

% extract model evaluations
A = cell2mat(paths(:));

% remove duplicates (highly unlikely to have duplicates)
[A,~,map] = unique(A,'rows');
[nPaths,nPoints] = size(paths);
map = map(reshape(1:nPaths*nPoints, nPaths, nPoints));

% scale to parameter ranges
A = bsxfun(@times, A, high) + bsxfun(@times, 1-A, low);

% write simulation files
% with the configuration above, tihs will generate 80 (10 paths * (7 groups +1)) sets of parameters,
% written in input#.txt files (where # is 1 to 80)
for i=1:size(A,1)
    % open file
    filename = ['input' num2str(i) '.txt'];
    fid = fopen(filename, 'w');
    
    % write names and values
    for j=1:length(var_names)
        fprintf(fid, '%s = %e\r\n', var_names{j}, A(i,j));
    end
    
    % close file
    fclose(fid);
end

% these files save the configuration and the paths, in Matlab format
save('setup.mat','var_names','low','high','groups','p','k','r','n','corr');
save('paths.mat','paths','vars','map');