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
%$Id: initial_condition_branches_preparation.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/initial_condition_branches_preparation.m $
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

function input_out=initial_condition_branches_preparation(input)
    nb=input(1,1).mdv.nb;
    nf=numel(input(1,1).sed.dk); %nf is added in the check of the input per branch
    br_mat=input(1,1).grd.br_mat;
    br_ord=input(1,1).grd.br_ord;
    %initype_bra
    switch input(1,1).ini.initype_bra
        case 1 %water discharge Q [m^3/s] per branch and bed slope, assuming normal flow
            %
            %% CHECK INPUT
            %
            % input.ini.Q_frac
            if nb~=numel(input(1,1).ini.Q_frac)
                error('The number of branches is inconsistent with the Q_frac you provided.')
            end
            % input.ini.slopeb
            if nb~=numel(input(1,1).ini.slopeb)
                error('The number of branches is inconsistent with the slopeb you provided.')
            end            
            % input.bch.Q0
            if  max(br_mat(:,3))~=size(input(1,1).bch.Q0,2)
                error('The number of upstream BC is inconsistent with the bch.Q0 you provided.')
            end
            %input.bch.etaw0
            if max(br_mat(:,4))~=size(input(1,1).bch.etaw0,2)
                error('The number of downstream BC is inconsistent with the bch.etaw0 you provided.')
            end
            %input.bcm.Qbk0
            if size(input(1,1).bcm.Qbk0,3)~=max(br_mat(:,3))
                error('The sediment supply is not defined for each upstream node')
            end

                       
            %
            %% assign discharge to each branch (up to down)
            %
            Q=zeros(nb,1);
            nt=size(input(1,1).bch.Q0,2);
            
            for kb=1:nb
                if br_mat(br_ord(kb,1),3)>0 % Upstream boundary
                    Q(br_ord(kb,1),1)=input(br_ord(kb,1),1).bch.Q0(1,br_mat(br_ord(kb,1),3));
                    input(br_ord(kb,1),1).bch.Q0=input(br_ord(kb,1),1).bch.Q0(:,br_mat(br_ord(kb,1),3));
                elseif br_mat(br_ord(kb,1),6)==1 % Bifurcation
                    if ~isnan(input(1,1).ini.Q_frac(br_ord(kb,1),1))&& ~isnan(input(1,1).ini.Q_frac(br_mat(br_ord(kb,1),8),1))&&...
                                   sum(input(1,1).ini.Q_frac(br_ord(kb,1),1),input(1,1).ini.Q_frac(br_mat(br_ord(kb,1),8),1))~=1
                        error('Initial discharge division overdefined and does not sum up to 1')
                    elseif ~isnan(input(1,1).ini.Q_frac(br_ord(kb,1),1))
                        Q(br_ord(kb,1),1)=input(1,1).ini.Q_frac(br_ord(kb,1),1)*Q(br_mat(br_ord(kb,1),7),1);
                    elseif ~isnan(input(1,1).ini.Q_frac(br_mat(br_ord(kb,1),8),1))
                        Q(br_ord(kb,1),1)=input(1,1).ini.Q_frac(br_mat(br_ord(kb,1),8),1)*Q(br_mat(br_ord(kb,1),7),1);
                    else
                        error('Initial discharge division undefined')
                    end
                    input(br_ord(kb,1),1).bch.Q0=zeros(nt,1)+Q(br_ord(kb,1),1);
                elseif br_mat(br_ord(kb,1),6)==0 % Confluence
                    Q(br_ord(kb,1),1)=sum(Q(br_mat(br_ord(kb,1),7:8)',1));
                    input(br_ord(kb,1),1).bch.Q0=zeros(nt,1)+Q(br_ord(kb,1),1);
                else
                    error('this is never supposed to happen... help?') 
                end
            end
            
            %
            %% assign sediment discharge to each branch (up to down)
            %
            nt=size(input(1,1).bcm.timeQbk0,1);
            
            for kb=1:nb
                if br_mat(br_ord(kb,1),3)>0 % Upstream boundary
                    input(br_ord(kb,1),1).bcm.Qbk0=input(br_ord(kb,1),1).bcm.Qbk0(:,:,br_mat(br_ord(kb,1),3));
                else  % all other cases
                    input(br_ord(kb,1),1).bcm.Qbk0=NaN(nt,nf);
                end
            end  
            
            %
            %% compute downstream water level of each branch
            %
            nt=size(input(1,1).bch.etaw0,2);
            h0=zeros(nb,1); %water LEVEL at downstream end of each branch)
            h0(logical(br_mat(:,4)),1)=input(1,1).bch.etaw0(1,br_mat(logical(br_mat(:,4)),4));
            for kb=nb:-1:1
                if ~isnan(input(1,1).ini.slopeb(kb,1))
                    if br_mat(br_ord(kb,1),6)==1
                        h0(br_mat(br_ord(kb,1),7))=h0(br_ord(kb,1))+input(br_ord(kb,1),1).grd.L*input(1,1).ini.slopeb(kb,1);
                    elseif ~isnan(br_mat(br_ord(kb,1),7))
                        h0(br_mat(br_ord(kb,1),7:8))=h0(br_ord(kb,1))+input(br_ord(kb,1),1).grd.L*input(1,1).ini.slopeb(kb,1);
                    end
                end
            end
            for kb=1:nb
                input(kb,1).bch.etaw0=zeros(nt,1)+h0(kb,1);
            end
            
            %
            %% Compute slope, water depth, flow velocity and inital downstream bed level
            %
            for kb=nb:-1:1
                if ~isnan(br_mat(br_ord(kb,1),7))
                    input(br_ord(kb,1),1).ini.slopeb=(h0(br_mat(br_ord(kb,1),7))-h0(br_ord(kb,1),1))/input(br_ord(kb,1),1).grd.L;
                else
                    input(br_ord(kb,1),1).ini.slopeb=input(br_ord(kb,1),1).ini.slopeb(br_ord(kb,1),1);
                end
                % water depth and flow velocity for each branch
                input(br_ord(kb,1),1).ini.h=(input(br_ord(kb,1),1).mdv.Cf*(Q(br_ord(kb,1),1)/input(kb,1).grd.B)^2/(input(1,1).mdv.g*input(br_ord(kb,1),1).ini.slopeb)).^(1/3);
                input(br_ord(kb,1),1).ini.u=(Q(br_ord(kb,1),1)/input(kb,1).grd.B)/input(br_ord(kb,1),1).ini.h;
                input(br_ord(kb,1),1).ini.etab0=h0(br_ord(kb,1),1)-input(br_ord(kb,1),1).ini.h;
                input(br_ord(kb,1),1).ini.Q=Q(br_ord(kb,1),1);
                
                input(kb,1).ini.initype=2; %set this value to use free initial condition per branch
            end

        otherwise
            error('Unknown initype_bra, please make it known')
    end
    %% OUTPUT
    input_out=input;
        
end


