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
%$Id: substrate_update_R2016b.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/substrate_update_R2016b.m $
%
%function_name does this and that

%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160701
%   -V. Hoey and Ferguson
%
%170327
%   -V. If no cell change do not update all
%

function [msk_new,Ls_new,fIk,detaLa]=substrate_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='2';
% if kt==1; fprintf(fid_log,'substrate_update version: %s\n',version); end 

%%
%% RENAME
%%

nef=input.mdv.nef;
nsl=input.mdv.nsl;
nx=input.mdv.nx; %number of cells
ThUnLyr=input.mor.ThUnLyr;
if input.mor.interfacetype==2
    fIk_alpha=input.mor.fIk_alpha;
    Fbk=qbk(1:nef,:)./repmat(sum(qbk,1),nef,1); %effective volume fraction of sediment in transport
    Fbk(isnan(Fbk))=0; %if there is no sediment transport we use the same as Hirano (otherwise we divide by 0)
end

%%
%% CALC
%%

%PREALLOCATE
% Ls_new=NaN(1,nx,nsl); %preallocate new thickness matrix
% msk_new=zeros(nef,nx,nsl); %preallocate new substrate mass (not with NaN because NaN+1=NaN)
Ls_new=Ls; %preallocate new thickness matrix
msk_new=msk; %preallocate new substrate mass (not with NaN because NaN+1=NaN)

fIk=NaN(nef,nx); %preallocate volume fractions at the interface [-]; [nef x nx double]
cj=NaN(1,nx); %cell jumps (how many subtrate layer interfaces does the top substrate cross from the old to the new position) [-]; (positive both up and down); it is not necessar a vector but may be good for debbuging purposes and future improvements.
Fak=Mak./repmat(La_old,nef,1); %volume fractions at the active layer [-]; [nef x nx double]

%IDENTIFY END CELL
%the end cell is the last substrate layer at each node with a thickness
%different than 0.
ec=nsl*ones(1,nx); %initially the end cell is the last one
[aux_pos,aux_val]=min(Ls,[],3); %search for the minimum (0 or positive)
ec(aux_pos==0)=aux_val(aux_pos==0)-1; %those points whose minimum is 0 the last layer is one before

%TEMPORAL NEW THICKNESS OF THE FIRST (TOP) LAYER
%may be larger than the prescribed maximum
%it is not used when aggrading with only 1 substrate layer
detaLa=(etab-La)-(etab_old-La_old);
Ls1_temp_new=Ls(:,:,1)+detaLa; %temporary new thickness of the top layer

%IDENTIFY AGGRADING AND DEGRADING NODES
agr_idx=detaLa>=0; %agrading nodes
% deg_idx=~agr_idx; %degrading indices



%LOOP ON X
%yes, this is a loop with an if inside. V has been unable to avoid it. I am a loser... :( 
%the problem is in ec and acj, which depend on x. 
for kx=1:nx
    if agr_idx(kx) %aggrading nodes
        %volume fraction content at the interface between active layer and substrate
        switch input.mor.interfacetype
            case 1 %Hirano 
                fIk(:,kx)=Fak(:,kx);
            case 2 %Hoey and Ferguson
                fIk(:,kx)=(1-fIk_alpha).*Fak(:,kx)+fIk_alpha.*Fbk(:,kx);
            otherwise
                error('ELV does not like stupid input!')
        end

        if ec(kx)~=1 %more than 1 substrate layer
            
            %cell jumps 
            cj(kx)=floor(Ls1_temp_new(1,kx,1)/ThUnLyr); %here it can only be positive
            
            if cj(kx)~=0 %there is at least a cell jump
                
                %make it NaN
                Ls_new(1,kx,:)=NaN;
                msk_new(:,kx,:)=0;
                
                %substrate thicknesses of all layers but the last one
                Ls_new(1,kx,1)=Ls1_temp_new(1,kx,1)-cj(kx)*ThUnLyr; %top layer
                Ls_new(1,kx,2:cj(kx)+1)=ThUnLyr;
                Ls_new(1,kx,cj(kx)+2:nsl-1)=Ls(1,kx,2:nsl-1-cj(kx));

                %mass of all layers but the last one
                msk_new(:,kx,1)                =fIk(:,kx).*repmat(Ls_new(1,kx,1),nef,1,1);
                msk_new(:,kx,1+cj(kx))         =msk_new(:,kx,1+cj(kx))-fIk(:,kx).*repmat(Ls(1,kx,1),nef,1);
                msk_new(:,kx,2:cj(kx)+1)       =msk_new(:,kx,2:cj(kx)+1)+repmat(fIk(:,kx)*ThUnLyr,1,1,numel(2:cj(kx)+1));
                msk_new(:,kx,cj(kx)+1:nsl-1)   =msk_new(:,kx,cj(kx)+1:nsl-1)+msk(:,kx,1:nsl-1-cj(kx));

                %end cell thickness and mass
                if ec(kx)+cj(kx)<=nsl %the end cell has thickness 0; add one layer
                    Ls_new (1,kx,nsl)=Ls (:,kx,nsl-cj(kx)); %actually the same as before
                    msk_new(:,kx,nsl)=msk(:,kx,nsl-cj(kx)); %actually the same as before
                else %the end thickness is already in use; join layers
                    Ls_new (1,kx,nsl)=sum(Ls (1,kx,nsl-cj(kx):nsl),3);
                    msk_new(:,kx,nsl)=sum(msk(:,kx,nsl-cj(kx):nsl),3);                
                end

            else %there is no cell jump

                Ls_new(1,kx,1)=Ls1_temp_new(1,kx,1)-cj(kx)*ThUnLyr; %top layer
                
                msk_new(:,kx,1)=msk(:,kx,1)+fIk(:,kx).*repmat(Ls_new(1,kx,1)-Ls(1,kx,1),nef,1,1); %top layer
                
            end %if there is at least a cell jump
            
        else %aggradation with only one substrate layer
            
            %cell jumps
            cj(kx)=floor(detaLa(kx)/ThUnLyr)+1;
            
            %top cell thickness and mass
            Ls_new(1,kx,1)=detaLa(kx)-(cj(kx)-1)*ThUnLyr;
            msk_new(:,kx,1)=fIk(:,kx).*repmat(Ls_new(1,kx,1),nef,1,1);
            
            %all the other cells
            if ec(kx)+cj(kx)<=nsl %the end cell has thickness 0; add one layer
                Ls_new (1,kx,2:cj(kx))    =ThUnLyr;
                Ls_new (1,kx,cj(kx)+1:nsl)=Ls(1,kx,1:nsl-cj(kx));
                msk_new(:,kx,2:cj(kx))    =repmat(fIk(:,kx)*ThUnLyr,1,1,numel(2:cj(kx)));
                msk_new(:,kx,cj(kx)+1:nsl)=msk(:,kx,1:nsl-cj(kx));
            else %jump so much that the last layer adds the previous
                Ls_new (1,kx,2:nsl-1)=ThUnLyr;
                Ls_new (1,kx,nsl)    =Ls(1,kx,1)+ThUnLyr*(cj(kx)+ec(kx)-nsl);
                msk_new(:,kx,2:nsl-1)=repmat(fIk(:,kx)*ThUnLyr,1,1,numel(2:nsl-1));
                msk_new(:,kx,nsl)    =msk(:,kx,1)+fIk(:,kx)*ThUnLyr*(cj(kx)+ec(kx)-nsl);              
            end  
            
        end
        
    else %degrading nodes
        
        %cell jump
        if Ls1_temp_new(1,kx,1)>=0 %degradation but less than one cell
            cj(kx)=0;
        else
            try
                cj(kx)=find(-cumsum(Ls(1,kx,2:nsl))-Ls1_temp_new(1,kx,1)<0,1); %position of the first negative point (cj is always >0)
            catch
                error('You are getting close to the centre of the earth since you run out of substrate material. Ask V about input.mor.ThUnLyrEnd to solve this problem. Come with coffee please :)')
            end
        end
        
        if cj(kx)~=0 %there is at least a cell jump
            
            %make it NaN
            Ls_new(1,kx,:)=NaN;
            msk_new(:,kx,:)=0;
            
            %substrate thicknesses
            Ls_new(1,kx,1)=Ls1_temp_new(1,kx,1)+sum(Ls(1,kx,2:cj(kx)+1),3); %top layer
            Ls_new(1,kx,2:ec(kx)-cj(kx))=Ls(1,kx,2+cj(kx):ec(kx));
            Ls_new(1,kx,ec(kx)-cj(kx)+1:nsl)=0;

            %mass
            msk_new(:,kx,1)                  =msk(:,kx,1+cj(kx))-repmat((Ls(1,kx,1+cj(kx))-Ls_new(1,kx,1))/Ls(1,kx,1+cj(kx)),nef,1,1).*msk(:,kx,1+cj(kx));
            msk_new(:,kx,2:ec(kx)-cj(kx))    =msk(:,kx,2+cj(kx):ec(kx));
            msk_new(:,kx,ec(kx)-cj(kx)+1:nsl)=0; %this line can be commented if preallocate with zeros

            %interface
            %the specific case for no cell jump and the other cases are the same
            %mathematically. However, when the bed elevation variation is
            %very small and there is no cell jump the denominator is 0 due to
            %machine precision. This denominator cancels in the specif case of
            %no cell jump so the problem is solved writng the specific form if
            %there is no cell jump.
%             if cj(kx)==0
%                 fIk(:,kx)=msk(:,kx,1)/Ls(1,kx,cj(kx)+1);
%             else
                fIk(:,kx)=(sum(msk(:,kx,1:cj(kx)),3)+msk(:,kx,cj(kx)+1)*((Ls(1,kx,cj(kx)+1)-Ls_new(1,kx,1))/Ls(1,kx,cj(kx)+1)))/(sum(Ls(1,kx,1:cj(kx)+1),3)-Ls_new(1,kx,1));
%             end
            
        else %there is no cell jump
            
            Ls_new(1,kx,1)=Ls1_temp_new(1,kx,1)+sum(Ls(1,kx,2:cj(kx)+1),3); %top layer
            
            msk_new(:,kx,1)=msk(:,kx,1)-repmat((Ls(1,kx,1)-Ls_new(1,kx,1))/Ls(1,kx,1),nef,1,1).*msk(:,kx,1);
            
            fIk(:,kx)=msk(:,kx,1)/Ls(1,kx,cj(kx)+1);
            
        end %there is at least a cell jump
    end
end
        

 




end %function
