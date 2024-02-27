%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: check_bra.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_bra.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170720
%   -V & Pepijn. Created for the first time.

function input_out=check_bra(input,fid_log)
nb=input(1,1).mdv.nb;


%% CHECK ON BRANCHES
%here, input is a structure array but the input for each branch is still the same.

%L
if nb~=numel(input(1,1).grd.L)
    error('The number of branches is inconsistent with the lengths you provided.')
end

%B
if nb~=numel(input(1,1).grd.B)
    error('The number of branches is inconsistent with the witdh you provided. Pepijn, does not like stupid input!')
end

if nb>1
%Fak
    if nb~=size(input(1,1).ini.Fak,1)
        error('The number of branches is inconsistent with the effective fractions at the active layer you provided.')
    end
%fsk
    if nb~=size(input(1,1).ini.fsk,1)
        error('The number of branches is inconsistent with effective fractions at the substrate you provided.')
    end
end

%initype_bra
if isfield(input(1,1).ini,'initype_bra')==0
    error('You have to specify the kind of initial conditions for the branches')
end

% bcm.timeQbk0 and bcm.Qbk0
if size(input(1,1).bcm.timeQbk0,1)~=size(input(1,1).bcm.Qbk0,1)
    error('The sediment boundary time is not the same size as the value')
end
if size(input(1,1).bcm.timeQbk0,2)~=1
    error('The sediment boundary time should be the same for each boundary condition')
end
if size(input(1,1).bcm.Qbk0,2)~=numel(input(1,1).sed.dk) %nf is added in the check of the input per branch
    error('The sediment supply is not defined for each sediment class')
end

%input.mor.nodparam
switch input(1,1).mor.nodal
    case 1
        if size(input(1,1).mor.nodparam,2)~=numel(input(1,1).sed.dk) %nf is added in the check of the input per branch
            error('Insufficient k values for Wang')
        end
    case 2
        if size(input(1,1).mor.nodparam,2)~=2 %nf is added in the check of the input per branch
            error('Needs both the r and alpha value for Bolla')
        end
    otherwise
        error('Other nodal point relations not yet implemented')
end

if size(input(1,1).mor.nodparam,1)~=1&&size(input(1,1).mor.nodparam,1)~=numel(unique(input(1,1).grd.br))
    if size(input(1,1).mor.nodparam,2)~=numel(input(1,1).sed.dk) %nf is added in the check of the input per branch
        error('The params of the nodalpoint relation should be constant over all nodes or it should be defined for each node including confluences and boundaries')
    end
end

%% CREATE SOLVING MATRIX [number of braches x A to H]
% A: Upstream node                                      nnode
% B: Downstream node                                    nnode
% C: Upstream BC number:                                nnode:      0 if not an upstream boundary condition else gives location of boundary condition
% D: Downstream BC number:                              nnode:      0 if not a downstream boundary condition else gives location of boundary condition
% E: Solving order from upstream to downstream                      from 1 to number of branches
% F: Type of node at the upstream end of the branch     logical:    bifurcation, false: confluence or boundary condition
% G: Connected branches                                 nbranch:    If bifurcation Upstream branch,         elseif confluence upstream branch 1 else NAN
% H: Connected branches                                 nbranch:    If bifurcation fellow downstream branch,elseif confluence upstream branch 2 else NAN
% I: Bifurcation number (only the first occurence)      nnode       0 if not bifurcation or a bifurcation of which is buddy is counted. Counting upwards
br_mat=zeros(nb,8);                                     % allocate
nodeloc_solv=zeros(nb,1);

br_mat(:,1:2)=input(1,1).grd.br;                        % transfer input node numbers

%
% C and D: find upstream and downstream nodes
%
[C]=unique(input(1,1).grd.br);
aux_1=histc(input(1,1).grd.br(:),C);                    % count total occurence each node
up_bcnodeL=ismember(input(1,1).grd.br(:,1),C(aux_1==1));% make logical array which selects upstream bc
do_bcnodeL=ismember(input(1,1).grd.br(:,2),C(aux_1==1));% make logical array which selects downstream bc
[~,upbcI]=sort(input(1,1).grd.br(up_bcnodeL,1));        % up: sort the bc nodes, on first colum then second
[~,dobcI]=sort(input(1,1).grd.br(do_bcnodeL,2));        % do: sort the bc nodes, on first colum then second
up_bcnode=int8(up_bcnodeL);                             % convert logical to integer
do_bcnode=int8(do_bcnodeL);
up_bcnode(up_bcnodeL)=upbcI;                            % assign the order values
do_bcnode(do_bcnodeL)=dobcI;

br_mat(:,3:4)       =[up_bcnode,do_bcnode];             % transfer boundaries to solving matrix
br_mat(:,5)         =up_bcnode;                         % first flow order
nodeloc(upbcI,1)    =find(up_bcnodeL);


%
% F: check if bifurcation
%
aux_2=histc(input(1,1).grd.br(:,1),C);                  % count number or occurence
br_mat(ismember(br_mat(:,1),C(aux_2==2)),6)=1;          % if two then bifurcation 

%
% G and H: Find buddies for bifurcations and concfluences
%
[C,~,ic]=unique(br_mat(logical(br_mat(:,6)),1));
nnode=zeros(numel(C),1);
for nbif=1:numel(C)
    nnode(nbif)=find(br_mat(:,2)==C(nbif));
end
br_mat(logical(br_mat(:,6)),7)=nnode(ic);

for nbranch=1:nb % loop through all branches to assign confluence and bifurcation 
    if br_mat(nbranch,6)==1
    	Ibranch=find(br_mat(nbranch,1)==br_mat(:,1));
        br_mat(nbranch,8)=Ibranch(Ibranch~=nbranch);
    elseif br_mat(nbranch,6)==0&&(br_mat(nbranch,3)==0)
        Ibranch=find(br_mat(nbranch,1)==br_mat(:,2));
        br_mat(nbranch,7:8)=Ibranch';
    else
        br_mat(nbranch,7:8)=NaN;
    end
end

%
% E: solving order from upstream to downstream
%
% Starting with upstream boundary, already assigned
% Idea: walk from upstream to downstream

flowcount=max(br_mat(:,5))+1;                          % flow order counter
locval=sum(nodeloc~=0)+1;                              % first free location in the nodeloc
for kb=1:nb                                            % run through all banches and set flow order of downstream branch
    Iflow=find(br_mat(nodeloc(kb),2)==br_mat(:,1));
    if numel(Iflow)==2&&all(br_mat(Iflow,5)==0)         % if bifurcation then assign flow order to both branches
        br_mat(Iflow,5)=[flowcount flowcount+1];
        nodeloc(locval:(locval+1),1)=Iflow;
        flowcount=flowcount+2;
        locval   =locval   +2;
    elseif numel(Iflow)==1&&br_mat(Iflow,5)==0          % if confluence then if both upstream branches are assigned then assign downstream, else do nothing
        confltest=br_mat(Iflow,(7:8))~=nodeloc(kb);     % check which upstream branch you loop over and retrieve the other
        if br_mat(br_mat(Iflow,find([zeros(1,6) confltest])),5)~=0 % not very nice... % check if the flow order is assigned for the other branch
            br_mat(Iflow,5)=flowcount;
            nodeloc(locval,1)=Iflow;
            flowcount=flowcount+1;
            locval   =locval   +1;
        end
    end 
end

%
% Number of bifurcations
%
nbif=zeros(sum(br_mat(nodeloc(kb,1),6))/2,1);
for kb=1:nb
    locval=sum(nbif~=0)+1; 
    if br_mat(nodeloc(kb,1),6)==1&&all(br_mat(nodeloc(kb,1),8)~=nbif)
        nbif(locval,1)=nodeloc(kb,1);
    end
end




%% ASSIGN DATA TO EACH BRANCH

for kb=1:nb
    %from vector to single value
    input(kb,1).grd.L=input(kb,1).grd.L(kb,1); 
    input(kb,1).grd.B=input(kb,1).grd.B(kb,1);
    input(kb,1).ini.Fak=input(kb,1).ini.Fak(kb,:)';
    input(kb,1).ini.fsk=input(kb,1).ini.fsk(kb,:);
    
    input(kb,1).grd.br_mat=br_mat;
    input(kb,1).grd.br_ord=nodeloc; % maybe not necessary because easily found with sort...
    input(kb,1).grd.nbif  =nbif; % maybe not necessary because easily found with sort...
end

input=initial_condition_branches_preparation(input);

%% OUTPUT

input_out=input;

