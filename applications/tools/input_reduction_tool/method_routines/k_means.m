%% K harmonic means

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
%           ita     =   maximum iterations
%       Del_eps_min =   minimum improvement of internal error 
%                       (If the internal error is lower then iteration stops)
%           o       =   Non-linearity parameter of the fuzziness
%           type    =   Type of distance used - (Euclidean = type 1)
%                       Type = 1: 3D Euclidean distance (Hs Tp Dir)
%                       Type = 2: 3D Mahler Distance
%                       Type = 3: 3D Euclidean distance (Hs Dir [Day of the year])
%                       Type = 4: 4D Euclidean distance (Hs Tp Dir [Day of the year])
%           info_dir =   Information about the range of variation of the angle
%                        info_dir = 1 means range of variation of 0 to 360 
%                        info_dir = 0 means angle relative to the shore-normal, contains negative and positive values.
% ini= how determine the first centroid - 1 random, 2 - mda, 3 - fixed bins
%        r = how many random runs

%   Output:
%           Clu     =   Cluster of observation 
%           v       =   Wave condition of centroids [Hs Tp Dir].
%           P       =   Probability of occurance per representative wave
%                       condition [k x 1]
%           M07 = structure where:     
%                       Result = matrix [cond x 4] with selected wave
%                       conditions and probability [Hs Tp Dir P]
%                       Clu =  Cluster of observation 


function [inds_f,v,v_iter] = k_means(data,k,ita,Del_eps_min,o,type,ini,ndir,nhs,m,info_dir,type_of_k_means)

%% Stage 1: Normalization and selection
% Pre-Selection of observation has to be added to the script
% Normalization: so that values are between [0 1]

X = Norma_3D(data,type,data);

N = size(data,1);

%% stage 2: Initialization
% Select first centroids
% Using K-means++ algorithm
if ini==1
% Step 1: Random draw
[y,idx] = datasample(X(:,1),1);
v_0 = X(idx,:);
X_0 = X;
X_0(idx,:) = [];

% Step 2, draw with probability
D = Dist_3D(X_0,v_0);
D_2 = D.^2;
W_2 = D_2./sum(D_2);
[y,idx] = datasample(X_0(:,1),1,'Weights',W_2);
v_0(2,:) = X_0(idx,:);
X_0(idx,:) = [];

% Step 3, Draw with probability conditinional on dist of nearest centroid
for q = 1:k-2

    D = Dist_3D(X_0,v_0);
    [Min_D_0,Clu_0] = min(D,[],2);
     W_q = (Min_D_0.^2)/sum(Min_D_0.^2);
    [y,idx] = datasample(X_0(:,1),1,'Weights',W_q);
    v_0(q+2,:) = X_0(idx,:);
    X_0(idx,:) = [];
    
end  
v = v_0;
name_ini='k++';
elseif ini==2
    [v,~] = MDA(data,k,type);
    v=v(:,1:3);
    v=Norma_3D(v,type,data);
    name_ini='MDA';
elseif ini==3
    k=ndir.*nhs;
    [~,v,~] = fixed_bins(data,ndir,nhs,0,info_dir);
    v=v(:,1:3);
    v=Norma_3D(v,type,data);
    name_ini='fixed_bins';
end

D_0 = Dist_3D(X,v);
Min_D_0 = min(D_0,[],2);
%% Stage 3: Iteration

% Initialization
if strcmp(type_of_k_means,'Crisp')
    eps = sum(Min_D_0)/N;
elseif strcmp(type_of_k_means,'Fuzzy')
    D_0=Dist_3D(X,v);
    D_0_2=D_0.^2;
    W_u_0=(1./D_0_2).^(1/(o-1));
    W_l_0 = sum(W_u_0,2)*ones(1,k);
    W_0=W_u_0./W_l_0;
    eps = nansum(nansum(W_0.^o .* D_0,2)) / nansum(nansum(W_0.^o,2));
elseif strcmp(type_of_k_means,'Harmonic')
    eps_low_0 = nansum(1./(D_0.^o),2);
    eps = sum(k./eps_low_0);
end

Del_eps = Inf;
for i = 1:ita
    
    % We stop when the distribution of observations over the centroids does
    % not change anymore or max of iterations is reached
    if Del_eps < Del_eps_min
%         disp('k-means converted because error has not improved ')
%         disp(sprintf('Number of iterations: %d',i));
        break
    end
    if i == ita
%         warning('k-means reached maximum number of iterations without converting')
    end
    
    % Determine distances
    D = Dist_3D(X,v(:,:,i));
    
    % Membership function
    
    if strcmp(type_of_k_means,'Harmonic')
        c_u = D.^(-o-2);
        c_l = sum(c_u,2);
        c = c_u ./ (c_l*ones(1,k));
        w_l = sum(D.^(-o),2);     %w_l = sum(D.^(o),2);
        w = c_l./(w_l.^2);
        c = repmat(w,1,k).*c;
    elseif strcmp(type_of_k_means,'Fuzzy')
        % Determine fuzzy weights

        D2=D.^2;
        W_u=(1./D2).^(1/(o-1));
        W_l = sum(W_u,2)*ones(1,k);
        c=W_u./W_l;
        c=c.^o;
    elseif strcmp(type_of_k_means,'Crisp')
        c = ones(N,k);
    end

    % Determine weights
    
     % Determine the internal error
    
     
     % Cluster assignment of observations
    [Min_D_i,Clu_i] = min(D,[],2);
    Clu(:,i) = Clu_i; 
    if i>1 
    
        if strcmp(type_of_k_means,'Crisp')
            eps_1 = eps;
            eps = sum(Min_D_i)/N;
            Del_eps = eps_1 - eps;
        elseif strcmp(type_of_k_means,'Fuzzy')
            eps_1 = eps;
            eps = nansum(nansum(c.^o .* D,2)) / nansum(nansum(c.^o,2));
            Del_eps = eps_1 - eps;
        elseif strcmp(type_of_k_means,'Harmonic')
            eps_1 = eps;
            eps_low_0 = nansum(1./(D.^o),2);
            eps = sum(k./eps_low_0);    
            Del_eps = eps_1 - eps;
        end
    
    end
    
    if strcmp(type_of_k_means,'Crisp')
        for j = 1:k
            X_v = X(Clu(:,i)==j,:);
            ctype = 2;
            %       type=   Type of procedure that has to be performed
            %               Type 1: Takes the mean of all variables
            %               Type 2: Uses a non-linear function to determine the wave
            %                       height
            v(j,:,i+1) = fcent(X_v,ctype,m,info_dir);
        end
    else
        for j = 1:k
            v(j,1,i+1) =   nansum((c(:,j)).*X(:,1))./nansum(c(:,j));
            v(j,2,i+1) =   nansum((c(:,j)).*X(:,2))./nansum(c(:,j));
            v(j,3,i+1) =   weighted_mean_angle(X(:,3),(c(:,j)));
        end
    end
       
end

D = Dista(X,v(:,:,end),type,[]);
[D_min ind_min] = min(D,[],2);
Clu = ind_min; 

if strcmp(type_of_k_means,'Fuzzy')
    P = nansum((c.^(1/o)).^2) / nansum(nansum((c.^(1/o)).^2,2));
elseif strcmp(type_of_k_means,'Harmonic')
    P = nansum((c./repmat(w,1,k)).^2) / nansum(nansum((c./repmat(w,1,k)).^2,2));
elseif strcmp(type_of_k_means,'Crisp')
    bound = find(isnan(Clu(1,:))==1,1);
    if isempty(bound) == 1
        bound = size(Clu,2)+1;
    end

    P = NaN(1,k);
    for bb = 1:k
        P(1,bb) = sum(Clu(:,bound-1)==bb)/N;
    end
end
P=P';

% Denormalize results
for a = 1:size(v,3)
    v(:,:,a) = DeNorma_3D(data,v(:,:,a),type);
end

if info_dir == 1
    for c=1:size(v,3)
    v(find(v(:,3,c)<0),2,c)=v(find(v(:,3,c)<0),2,c)+360;
    end
end

inds_f = Clu;
v_iter = v;
v=[v(:,:,end) P];

end
