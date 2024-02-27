%% Maximum Dissimilarity algorithm [Model 9]

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

%   Input:
%           data    =   Matrix (N x 3) with observations [Hs Tp Dir]
%           k       =   Number of centroids required                      
%           type    =   Type of distance and normalization

%   Output:
%           Clu     =   Cluster that is nearest by observations that are
%                       not centroids [N-k x 1]
%           v       =   Wave condition of centroids: [k x[ Hs T Dir F]]
%           F       =   Probability of occurance per cluster [k x 1]
%           X_new   =   Observations that are not centroids [N-k x [Hs T Dir]] 
%           Index   = Index of the centroids in the original data
%        M08 = structure where:     
%                       Result = matrix [cond x 4] with selected wave
%                       conditions and probability [H Tp Dir P]
%                       Clu = Cluster that is nearest by observations that are
%                       not centroids [N-k x 1]%  


function [v,inds_f,data_new] = MDA(data,k,type)

%% Step 1: Normalization 
% Pre-Selection of observation has to be added to the script
% Normalization: so that values are between [0 1]

N = size(data,1);
Dim = size(data,2);
X = Norma_3D(data,type,data);
Ind = (1:N)';

X_new = X;          % Is a matrix containing all remaining observations (that are thus not selected yet) 
Index = NaN(k,1);   % Index of the centroids in the original data
Ind_new = Ind;      % Indices of the observations that are not selected yet
v = NaN(k,3);
%% Step 1: First centroid
% Determine the first centroid. This is the centroid with the largest dissimilatity
% To decrease the memory size of matrices the search for the largest
% dissimilar observation is done in blocks of 1000. 

% Check how much blocks of 1000 are nessessary to analyze the dataset
Q = 0;
if mod(N,1000)>0
    Q = 1;
end

loopl = floor(N/1000)+Q;             % Number of loops nessesary
ind_D_a = NaN(loopl,2);  % Matrix: properties of the observation with the largest distance per block 
%                                       [Distance indices_in_origal_data] 

for a = 0:loopl-1
   
   if a <loopl-1            
   D = Dista(X(a*1000+1:a*1000+1000,:),X,type,[]);        % Determine distances in block with all other observations
   else
       D = Dista(X(a*1000+1:end,:),X,type,[]);            % If last iteration use other method
   end
   [D_max_a,ind_max_a] = max(max(D,[],2));          % Determine the largest dist of the block
   ind_D_a(a+1,:) = [D_max_a a*1000+ind_max_a];     % Write that obs away
end 

[d,ind_max_D] = max(ind_D_a(:,1));                  % Find obs with largest dist over the blocks
ind_max = ind_D_a(ind_max_D,2);                     % Dermine the index in the original matrix of the largest distance
v(1,:) = X(ind_max,:);                              % Set this obs as first centroid
Index(1,1) = Ind(ind_max,:);                        % Save obs index from the original matrix
X_new(ind_max,:) = [];                              % delete selected obs from mattrix
Ind_new(ind_max,:) = [];                             

%% Step 2: Second centroid

D = Dista(X_new,v(1,:),type,[]);                    % Dermine dist obs with  dist to v1
[D_max,ind_max] = max(max(D,[],2));                 % Find obs with largest distance
v(2,:) = X_new(ind_max,:);                          % Write obs away as v2
Index(2,1) = Ind_new(ind_max,:);                    % save index from original data
X_new(ind_max,:) = [];                              % Delete obs from database
Ind_new(ind_max,:) = [];
D(ind_max,:) = [];
D_2 = D;                                            % Save distance matrix to use in next step

%% Step 3: All other centroids

for i = 3:k
    
    D_1 = Dista(X_new,v(i-1,:),type,[]);                  % Determine dist obs and last centroid
    D = min([D_1 D_2],[],2);                        % Determine minimum between previous results and new distances
    [D_min,ind_min] = max(D);                       % Find obs maximum distance
    v(i,:) = X_new(ind_min,:);                      % write it away as v3, v4 ...
    Index(i,1) = Ind_new(ind_min,:);                % save index from original data
    X_new(ind_min,:) = [];                          % Delete obs from database
    Ind_new(ind_min,:) = [];
    D(ind_min,:) = [];
    D_2 = D;
end

%% Determine the nearest observations to the centroids

% Sort the centroids
v = sortrows(v,1);

D = Dista(X_new,v,type,[]);
[D_min ind_min] = min(D,[],2);
Clu = ind_min;
F = NaN(k,1);
for j = 1:k
    F(j,1) = sum(Clu(:,1) == j);
end
F = F./length(X_new);


%% Denormalize results

X_new = DeNorma_3D(data,X_new,type);
v = DeNorma_3D(data,v,type);

Result=array2table([v F],'VariableNames',{'H','T','Dir','P'});
inds_f = Clu;
v=[v F];
data_new=X_new;

end