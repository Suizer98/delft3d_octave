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
%$Id: add_nourishment.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/add_nourishment.m $
%
%add_nourishment modifies the bed adding nourished sediment
%
%\texttt{[Mak_new,msk_new,Ls_new,La_new,etab_new,h_new]=add_nourishment(Mak_old,msk_old,Ls_old,La_old,etab_old,h_old,input,fid_log,kt)}
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%161010
%   V. Created it for the first time
%
%170126
%   L. Extended the possibilities

function [Mak_new,msk_new,Ls_new,La_new,etab_new,h_new]=add_nourishment(Mak_old,msk_old,Ls_old,La_old,etab_old,h_old,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='2';

% fprintf(fid_log,'function_name version: %s\n',version); %only called when there is actual nourishment
fprintf(fid_log,'Nourishment added at time step: %d\n',kt); %only called when there is actual nourishment

%% 
%% RENAME
%%

dk_opt=input.nour.dk_opt;
th=input.nour.th;
nf=input.mdv.nf;
nef=input.mdv.nef;
nsl=input.mdv.nsl;
nx=input.mdv.nx;
ThUnLyr=input.mor.ThUnLyr;

x0_idx = round(input.nour.x0/input.grd.dx)+1; %cell number begin
xend_idx = round(input.nour.xend/input.grd.dx)+1; %cell number end

%ncn=xend_idx-x0_idx+1; %number of cells nourished

Ln=zeros(1,nx);
Ln(1,x0_idx:xend_idx)=th; %thickness of the nourishment (vector)

%%
%% h
%%

h_new=h_old-Ln;

%%
%% etab
%%

etab_new=etab_old+Ln;

%%
%% Ffk
%%

%feed volume fractions (Ffk)
switch dk_opt
    case 1 %feed
        %ATT!! CRAP! we are taking the substrate sediment!!
        Fnk=msk_old(:,:,end)./repmat(Ls_old(:,:,end),nef,1);
        
    case 2 %active layer
        Fnk=Mak_old./repmat(La_old,nef,1);
        
    case 3 %only coarse
        Fnk=zeros(nef,nx);
        
    otherwise %captures NaN (unisize)

end
 
%%
%% Mak & Msk
%%

%PREALLOCATE
%copy old values so it is valid for unisize
Mak_new=Mak_old;
msk_new=msk_old;
Ls_new=Ls_old;
La_new=La_old;
        
if nf~=1 %mixed-size sediment

cj=NaN(1,nx); %cell jumps (how many subtrate layer interfaces does the top substrate cross from the old to the new position) [-]; (positive both up and down); it is not necessar a vector but may be good for debbuging purposes and future improvements.
Fak=Mak_old./repmat(La_old,nef,1); %volume fractions at the active layer [-]; [nef x nx double]

%IDENTIFY END CELL
%the end cell is the last substrate layer at each node with a thickness
%different than 0.
ec=nsl*ones(1,nx); %initially the end cell is the last one
[aux_pos,aux_val]=min(Ls_old,[],3); %search for the minimum (0 or positive)
ec(aux_pos==0)=aux_val(aux_pos==0)-1; %those points whose minimum is 0 the last layer is one before

%TEMPORAL NEW THICKNESS OF THE FIRST (TOP) LAYER
%may be larger than the prescribed maximum or negative
Ls1_temp_new=Ln-La_old; %temporary new thickness of the top layer

%yes, this is a loop with an if inside. V has been unable to avoid it. I am a loser... :( 
%the problem is in ec and acj, which depend on x. 
for kx=x0_idx:xend_idx
    if ec(kx)~=1 %more than 1 substrate layer

        %cell jumps 
        cj(kx)=floor(Ls1_temp_new(1,kx,1)/ThUnLyr)+2; %here it can only be positive
        if cj(kx)<0; cj(kx)=1; end %negative means one substrate cell created

        %active layer mass (cj>1)
        Mak_new(:,kx)=Fnk(:,kx).*repmat(La_old(1,kx),nef,1);
        
        %specific case of weighted average of nourishment and active layer
        %(this may be done in a better way)
        if cj(kx)==1; %here Ls1_temp_new(1,kx,1)<0; I pressume that this can be improved
            Mak_new(:,kx)=Fnk(:,kx).*repmat(Ln(1,kx),nef,1)-Fak(:,kx).*repmat(Ls1_temp_new(1,kx,1),nef,1); 
            Ls_new(1,kx,1)=La_old(1,kx)+Ls1_temp_new(1,kx);
            msk_new(:,kx,1)=Fak(:,kx).*repmat(La_old(1,kx)+Ls1_temp_new(1,kx),nef,1);
        else
            %this in paricular has a problem with subscript indices for cj==1
            Ls_new(1,kx,cj(kx)-1)       =Ls1_temp_new(1,kx,1)-(cj(kx)-2)*ThUnLyr; 
            Ls_new(1,kx,cj(kx))         =La_old(1,kx);
            msk_new(:,kx,cj(kx)-1)      =Fnk(:,kx).*repmat(Ls1_temp_new(1,kx,1)-(cj(kx)-2)*ThUnLyr,nef,1);
            msk_new(:,kx,cj(kx))        =Fak(:,kx).*repmat(La_old(1,kx),nef,1);
        end

        %substrate thicknesses of all layers but the last one
        Ls_new(1,kx,1:cj(kx)-2)     =ThUnLyr;
        Ls_new(1,kx,cj(kx)+1:nsl-1) =Ls_old(1,kx,1:nsl-1-cj(kx));

        %mass of all layers but the last one
        msk_new(:,kx,1:cj(kx)-2)    =Fnk(:,kx).*repmat(ThUnLyr,nef,1);        
        msk_new(:,kx,cj(kx)+1:nsl-1)=msk_old(:,kx,1:nsl-1-cj(kx));

        %end cell thickness and mass
        if ec(kx)+cj(kx)<=nsl %the end cell has thickness 0; add one layer
            Ls_new (1,kx,nsl)=Ls_old (:,kx,nsl-cj(kx)); %actually the same as before
            msk_new(:,kx,nsl)=msk_old(:,kx,nsl-cj(kx)); %actually the same as before
        else %the end thickness is already in use; join layers
            Ls_new (1,kx,nsl)=sum(Ls_old (1,kx,nsl-cj(kx):nsl),3);
            msk_new(:,kx,nsl)=sum(msk_old(:,kx,nsl-cj(kx):nsl),3);                
        end



    else %only one substrate layer
        error('this needs to be done but we are in a hurry!')
        %cell jumps
        cj(kx)=floor(detaLa(kx)/ThUnLyr)+1;

        %top cell thickness and mass
        Ls_new(1,kx,1)=detaLa(kx)-(cj(kx)-1)*ThUnLyr;
        msk_new(:,kx,1)=Fak(:,kx).*repmat(Ls_new(1,kx,1),nef,1,1);

        %all the other cells
        if ec(kx)+cj(kx)<=nsl %the end cell has thickness 0; add one layer
            Ls_new (1,kx,2:cj(kx))    =ThUnLyr;
            Ls_new (1,kx,cj(kx)+1:nsl)=Ls_old(1,kx,1:nsl-cj(kx));
            msk_new(:,kx,2:cj(kx))    =repmat(Fak(:,kx)*ThUnLyr,1,1,numel(2:cj(kx)));
            msk_new(:,kx,cj(kx)+1:nsl)=msk_old(:,kx,1:nsl-cj(kx));
        else %jump so much that the last layer adds the previous
            Ls_new (1,kx,2:nsl-1)=ThUnLyr;
            Ls_new (1,kx,nsl)    =Ls_old(1,kx,1)+ThUnLyr*(cj(kx)+ec(kx)-nsl);
            msk_new(:,kx,2:nsl-1)=repmat(Fak(:,kx)*ThUnLyr,1,1,numel(2:nsl-1));
            msk_new(:,kx,nsl)    =msk_old(:,kx,1)+Fak(:,kx)*ThUnLyr*(cj(kx)+ec(kx)-nsl);              
        end  

    end %more than one substrate layer
end


end %mixed-size sediment
end %function
