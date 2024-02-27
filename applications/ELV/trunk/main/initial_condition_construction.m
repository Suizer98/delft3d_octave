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
%$Id: initial_condition_construction.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/initial_condition_construction.m $
%
%initial_condition_construction does this and that
%
%[u,h,etab,Mak,La,msk,Ls,Cf]=initial_condition_construction(input,fid_log,bc)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%160429
%   -L. Added addtional cases and introduced extra input argument bc;
%16-829
%   -L. Added mixed grain size space marching
%161104
%   -L. Added option 13
%
%1612??
%   -L. Updated 
%
%170328
%   -V. Modification of 1 to use L's algorithm


function [u,h,etab,Mak,La,msk,Ls,Cf,Gammak]=initial_condition_construction(input,fid_log,bc)
% version='4';
% fprintf(fid_log,'initial_condition_construction: %s\n',version);

%%
%% RENAME
%%


% time=input.mdv.time;
% nt=input.mdv.nt;
% dt=input.mdv.nt;
% nf=input.mdv.nf;

%% 

switch input.ini.initype
    
%%
%% NORMAL FLOW (for a given qbk0 compute the initial condition)
%%
    case 1
        %active layer thickness
        La=ini_La(input,fid_log);
        %friction
        Cf=ini_Cf(input,La,fid_log);
        %bed friction
        Cfb=ini_Cfb(input,Cf,NaN,NaN,La,NaN,fid_log); %there is an implicit problem depending on the kind of model for the bed friction (use of Mak at this point)
        %flow depth, flow velocity, bed elevation, fractions at the active layer
%         [u,h,slopeb,Fak]=ini_normalflow(input,Cf(1),fid_log);
        [u,h,slopeb,Fak]=ini_normalflow_L(input,Cf(1),Cfb(1),fid_log);
        %active layer mass
        Mak=Fak.*repmat(La,input.mdv.nef,1);
        %bed elevation
        slopeb=slopeb.*ones(1,input.mdv.nx);
        etab=slope2elevation(slopeb,-h(end),input,fid_log);
        [etab,h]=initial_noise(etab,h,input);
        %substrate
        [msk,Ls]=ini_msk(La,input,fid_log);
        %particle activity
        Gammak=ini_Gammak(h,u,Cfb,La,Mak,input,fid_log);
            
%%
%% FREE
%%        
    case 2 
        %flow velocity
        u=input.ini.u.*ones(1,input.mdv.nx); 
        %flow depth
        h=input.ini.h.*ones(1,input.mdv.nx); 
        %volume fraction to matrix (needs to be here for active layer thickness related to grain size)
        if size(input.ini.Fak,2)==1 %if no variation in streamwise direction
            input.ini.Fak=repmat(input.ini.Fak,1,input.mdv.nx);
        end
        %active layer thickness
        La=ini_La(input,fid_log);
        %sediment mass
        Mak=input.ini.Fak.*repmat(La,input.mdv.nef,1);
        %bed elevation
        if isfield(input.ini,'etab')
            etab=input.ini.etab;
        elseif isfield(input.ini,'slopeb')
            input.ini.slopeb=input.ini.slopeb.*ones(1,input.mdv.nx);
            etab=slope2elevation(input.ini.slopeb,input.ini.etab0,input,fid_log);
        end
        [etab,h]=initial_noise(etab,h,input);
        %friction
        Cf=ini_Cf(input,La,fid_log);
        %substrate
        [msk,Ls]=ini_msk(La,input,fid_log);
        %particle activity
        if input.mor.particle_activity==1
            Gammak=input.ini.Gammak.*ones(input.mdv.nf,input.mdv.nx); %this will not always work if version<R2016b
        else
            Gammak=NaN(input.mdv.nf,input.mdv.nx);
        end
     
%%
%% FROM FILE
%%         
    case 3 %from file
        load(input.ini.rst_file)
        ktr=input.ini.rst_resultstimestep; 
        if isnan(ktr)==1
            h=h(:,:,:,end); %#ok
        	etab=etab(:,:,:,end); %#ok
            try
                u=u(:,:,:,end); %#ok
            catch
                u=NaN;
            end
            try
                Mak=Mak(:,:,:,end); %#ok
            catch
                Mak=NaN(size(h));
            end
            try
                La=La(:,:,:,end); %#ok
            catch
                La = NaN(size(h));
            end
            try
                if isfield(input.ini,'fsk') 
                    %generate the substarte with new vertical discretization and add the stratigraphy of the restarting file
                    [msk_n,Ls_n]=ini_msk(La,input,fid_log); %new substrate
                    msk_n(:,:,1:size(msk,3))=msk(:,:,:,end); 
                    Ls_n (:,:,1:size(Ls ,3))=Ls (:,:,:,end); 
                    msk=msk_n;
                    Ls=Ls_n;
                else
                    msk=msk(:,:,:,end); %#ok
                    Ls=Ls(:,:,:,end); %#ok
                end
            catch
                msk =NaN(size(h));
                Ls = NaN(size(h));
            end
            try
                Cf=Cf(:,:,:,end); %#ok
            catch
                Cf =NaN(size(h));
            end
			try
				Gammak=Gammak(:,:,:,end); %#ok
			catch
				Gammak=NaN;
			end
        else
            h=h(:,:,:,ktr); %#ok
        	etab=etab(:,:,:,ktr); %#ok
            try
                u=u(:,:,:,ktr); %#ok
            catch
                u=NaN;
            end
        	try
                Mak=Mak(:,:,:,ktr); %#ok
            catch
                Mak=NaN(size(h));
            end
            try
                La=La(:,:,:,ktr); %#ok
            catch
                La = NaN(size(h));
            end
            try
                msk=msk(:,:,:,ktr); %#ok
            catch
                msk =NaN(size(h));
            end
            try
                Ls=Ls(:,:,:,ktr); %#ok
            catch
                Ls = NaN(size(h));
            end
            try
                Cf=Cf(:,:,:,ktr); %#ok
            catch
                Cf =NaN(size(h));
            end
            Gammak=Gammak(:,:,:,ktr); %#ok
        end
%%
%% NORMAL FLOW (for a given initial condition, compute qbk0)
%%        
    case 4 
        %rename
        q0=input.bch.Q0(1)/input.grd.B(1);
%         Cf=input.frc.Cf(1);
        g=input.mdv.g;
        slopeb=input.ini.slopeb(1);
        %active layer thickness
        La=ini_La(input,fid_log);
        %friction
        Cf=ini_Cf(input,La,fid_log);
        %flow depth
        h=(Cf.*q0^2./g./slopeb).^(1/3);
%         h=h*ones(1,input.mdv.nx);
        %flow velocity
        u=q0./h; 
        %bed friction
        Cfb=ini_Cfb(input,Cf,u,h,La,NaN,fid_log); %there is an implicit problem depending on the kind of model for the bed friction (use of Mak at this point)
        %volume fraction to matrix (needs to be here for active layer thickness related to grain size)
        if size(input.ini.Fak,2)==1 %if no variation in streamwise direction
            input.ini.Fak=repmat(input.ini.Fak,1,input.mdv.nx);
        end
        %sediment mass
        Mak=input.ini.Fak.*repmat(La,input.mdv.nef,1);
        %bed elevation
%         if isfield(input.ini,'etab')
%             etab=input.ini.etab;
%         elseif isfield(input.ini,'slopeb')
            input.ini.slopeb=input.ini.slopeb.*ones(1,input.mdv.nx);
%             etab=slope2elevation(input.ini.slopeb,input.ini.etab0,input,fid_log);
            etab=slope2elevation(input.ini.slopeb,input.bch.etaw0(1)-h(end),input,fid_log);
%         end
        [etab,h]=initial_noise(etab,h,input);
        %substrate
        [msk,Ls]=ini_msk(La,input,fid_log);
        %particle activity
        Gammak=ini_Gammak(h,u,Cfb,La,Mak,input,fid_log);

    case {5,12,13,51,52,53} %alternating steady equilibrium state
        %active layer thickness
        La=ini_La(input,fid_log);
        %friction
        Cf=ini_Cf(input,La,fid_log);
        %bed friction
        Cfb=ini_Cfb(input,Cf,NaN,NaN,La,NaN,fid_log);
        %bed elevation
        if input.mdv.nf ~=1 % mixed sediment
            %[u,h,etab,~,Fak] = ini_spacem(input,fid_log,bc);
            [u,h,etab,~,Fak] = ini_equi(input,fid_log,bc);
            Mak=Fak.*repmat(La,input.mdv.nef,1);
        else %unisize
            %[u,h,etab,~,~] = ini_spacem(input,fid_log,bc);
            [u,h,etab,~,~] = ini_equi(input,fid_log,bc);
            Mak=input.ini.Fak.*repmat(La,input.mdv.nef,1);
        end
               
        %substrate
        if strcmp(input.ini.fsk,'Fak')==1
            input.ini.fsk = Fak;
        end
        [msk,Ls]=ini_msk(La,input,fid_log);  
        %particle activity
        Gammak=ini_Gammak(h,u,Cfb,La,Mak,input,fid_log);
    case 14
        error('This case is not supposed to be used in combination with ELV');
    otherwise
        error('oeps');
  
end

end
