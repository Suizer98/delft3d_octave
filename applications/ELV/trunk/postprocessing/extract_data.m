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
%$Id: extract_data.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/postprocessing/extract_data.m $
%
%function_name does this and that
%
%
%INPUT:
%fig_input.mdv.plot_type = plot type
    %1=variable at x constant: xp=time, yp=variable
    %2=variable at x-t: xp=space, yp=variable, zp=time
    %3=patch
%fig_input.xcn.varp  = variable to plot
    %1=Fak;
    %2=qb;
    %3=qbk;
    %4=pmm;
    %5=etab;
    %6=dm (geometric (2^...));
    %7=Gammak;
    %8=dm (arithmetic (Fak*dk))
    %9=Fak+fsk
    %10=h
    %11=approximate eigenvalues
    %12=sum(qbk) (selected fractions)
    %13=sum(Fak) (selected fractions)
    %14=sum(Mak+Gammak) (selected fractions)
    %15=sum(Gammak) (selected fractions)
    %16=sum(Mak+Gammak)/(La+sum(Gammak)) (selected fractions) 
    %17=Mak
    %18=(Mak+Gammak)/(La+sum(Gammak))
    %19=detrended etab (based on the slope of each profile)
%fig_input.xcn.varp2 = subvariable to plot: 
    %if fig_input.xtv.varp=1 then kf; 
    %if fig_input.xtv.varp=4 then 1=alpha, 2=beta; 3=M_etab; 4=M_Mak
    %if fig_input.xtv.varp=7 then kf;
    %if fig_input.xtv.varp=9 then kf; 
%
%OUTPUT:
%   -
%
%HISTORY:
%170719
%   -V. Created for the first time.
%

function [xp,yp,zp]=extract_data(path_fold_main,fig_input)

%%
%% READ
%%

%paths
path_file_input=fullfile(path_fold_main,'input.mat');
% path_file_output=fullfile(path_fold_main,'output.mat');

%input (input)
input=NaN;
load(path_file_input); 
v2struct(input.mdv,{'fieldnames','nx','nf','nsl','xedg','xcen'});
v2struct(input.sed,{'fieldnames','dk'});

%in case dk is reversed...
dk=reshape(dk,nf,1);

%the result times is in the output mat file.
% if input.mdv.dt_type==2
if isfield(input.mdv,'time_results') && ~any(isnan(input.mdv.time_results))
    time_results=input.mdv.time_results;
else
    fig_input.mdv.output_var={'time_l'};
    output_m=extract_output(path_fold_main,fig_input);
    time_results=output_m.time_l;
end
nT=numel(time_results);
% end

%fig_input
switch fig_input.mdv.plot_type
    case 1 %x_cnt
%         v2struct(fig_input.xcn,{'fieldnames','x','varp','varp2','unitt','unity'});
        v2struct(fig_input.xcn);
        [~,kxp]=min(abs(xcen-x)); %xnode to plot
        if exist('ntp','var')
            if isnan(ntp)
                ktp=nT;
            elseif ntp==0
                ktp=1:1:nT;
            else
                ktp=ntp;
            end
        else
            ktp=1:1:nT;
        end
        xp=time_results*unitt;
        zp=NaN;
        kslp=[];
        if varp==9
        kslp=1:1:nsl;
        end
    case 2 %xt
        v2struct(fig_input.xtv,{'fieldnames','varp','varp2','unitx','unity','unitt'});
        kxp=1:1:nx;
        ktp=1:1:nT;
        kslp=[];
        xp=xcen*unitx;
        zp=time_results*unitt;
        nfp=numel(varp2);
    case 3 %pat
        v2struct(fig_input.pat,{'fieldnames','varp','varp2','tp','unitx','unity'});
        kxp=1:1:nx;
        ktp=fig_input.pat.tp;
        kslp=1:1:nsl;
        xp=NaN;
        zp=NaN;
    otherwise 
        error('undefined')
end

nslp=numel(kslp);
nxp=numel(kxp);
nnT=numel(ktp);

%%
%% CALC
%%

switch varp
    case {1,6,8,9,13,14,16,17,18} %the ones requiring mean grain size or fractions
        %output
        fig_input.mdv.output_var={'Mak','msk','La','Ls'};
        output_m=extract_output(path_fold_main,fig_input);

        %put active layer and substrate in one matrix
        M_all=NaN(nf,nxp,1+nslp,nnT); %active layer and substrate in one matrix
        M_all(1:nf-1,:,1    ,:)=output_m.Mak(:,kxp,1,ktp);
        if ~isempty(kslp)
        M_all(1:nf-1,:,2:end,:)=output_m.msk(:,kxp,kslp,ktp);
        end

        L_all=NaN(nf,nxp,1+nslp,nnT);
        L_all(:,:,1      ,:)=repmat(output_m.La(:,kxp,1,ktp),nf,1,1,1);
        if ~isempty(kslp)
        L_all(:,:,2:nsl+1,:)=repmat(output_m.Ls(:,kxp,kslp,ktp),nf,1,1,1); %size(repmat(output_m.Ls(:,:,:,:),nf,1,1,1)) size(L_all(:,:,2:nsl+1,nT))
        end
        
        F_all=M_all./L_all;
        F_all(end,:,:,:)=ones(1,nxp,nslp+1,nnT)-sum(F_all(1:nf-1,:,:,:),1);
        
        M_all(end,:,:,:)=L_all(end,:,:,:)-sum(M_all(1:nf-1,:,:,:),1);
        
        switch fig_input.mdv.plot_type
            case 3 %patch type
        %         zp=squeeze(cumsum(L_all(1,:,:,:),3)); %relative bed elevation
                if ~isempty(kslp)
                    zp=[output_m.etab(:,kxp,:,ktp);output_m.etab(:,kxp,:,ktp)-output_m.La(:,kxp,:,ktp);repmat(output_m.etab(:,kxp,:,ktp),nslp,1)-repmat(output_m.La(:,kxp,:,ktp),nslp,1)-reshape(cumsum(output_m.Ls(:,kxp,:,ktp),3),nxp,nslp,1,1)']*unity;
                else
                    zp=output_m.etab(:,kxp,:,ktp);
                end
                in.nx=nx+2; 
                in.nl=nsl+1; 
                in.XCOR=xedg*unitx;
                in.sub=[output_m.etab(:,:,:,ktp);output_m.etab(:,:,:,ktp)-output_m.La(:,:,:,ktp);repmat(output_m.etab(:,:,:,ktp),input.mdv.nsl,1)-repmat(output_m.La(:,:,:,ktp),input.mdv.nsl,1)-reshape(cumsum(output_m.Ls(:,:,:,ktp),3),input.mdv.nx,input.mdv.nsl,1,1)']*unity;
                switch varp
                    case 1 %volume fraction kf
                        in.cvar=reshape(F_all(varp2,:,:,:),nxp,nsl+1)';
                    case 6 %Dm        
                        in.cvar=reshape(2.^(sum(F_all.*log2(repmat(dk,1,nxp,nsl+1)/0.001),1)),nxp,nsl+1)';
                end 
                [f,v,col]=rework4patch(in);
                yp.f=f;
                yp.v=v;
                yp.col=col;
            otherwise %not patch
                %get the one we want
                switch varp
                    case {1,9}
%                         yp=squeeze(F_all(varp2,nxp,nslp+1,ktp));
                        yp=squeeze(F_all(varp2,:,:,:));
                    case 6
                        yp=squeeze(2.^(sum(F_all.*log2(repmat(dk,1,nxp,nslp+1)/0.001),1)));
                    case 8
                        yp=squeeze(sum(F_all.*repmat(dk,1,nxp,nslp+1),1));
                    case 13
                        yp=squeeze(sum(F_all(varp2,:,:,:),1));
                    case 14
                        %Mak
                        yp1=squeeze(sum(M_all(varp2,:,:,:),1));
                        
                        %Gammak
                        fig_input.mdv.output_var={'Gammak'};
                        output_m=extract_output(path_fold_main,fig_input);
                        yp2=squeeze(sum(output_m.Gammak(varp2,kxp,:,ktp),1));
                        
                        %Mak+Gammak
                        yp=yp1+yp2;
                    case 16
                        %Mak
                        yp1=sum(M_all(varp2,:,:,:),1);
                        
                        %Gammak
                        fig_input.mdv.output_var={'Gammak'};
                        output_m=extract_output(path_fold_main,fig_input);
                        yp2=sum(output_m.Gammak(varp2,kxp,:,ktp),1);
                        yp2T=sum(output_m.Gammak(:,kxp,:,ktp),1);
                        
                        %Mak+Gammak
                        yp=(yp1+yp2)./(L_all(1,:,:,:)+yp2T);
                        yp=squeeze(yp);
                    case 17 %Mak
                        yp=squeeze(M_all(varp2,:,:,:));
                    case 18 %(Mak+Gammak)/(La+sum(Gammak))
                        %Mak
                        yp1=M_all(varp2,:,:,:);
                        
                        %Gammak
                        fig_input.mdv.output_var={'Gammak'};
                        output_m=extract_output(path_fold_main,fig_input);
                        yp2=output_m.Gammak(varp2,kxp,:,ktp);
                        yp2T=sum(output_m.Gammak(:,kxp,:,ktp),1);
                        
                        %Mak+Gammak
                        yp=squeeze((yp1+yp2)./(L_all(varp2,:,:,:)+repmat(yp2T,nfp,1,1)));
                end
        end
    case 2
        %output
        fig_input.mdv.output_var={'qbk'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(sum(output_m.qbk(:,kxp,:,ktp),1)).*unity;
        
    case 3
        fig_input.mdv.output_var={'qbk'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(output_m.qbk(varp2,kxp,:,ktp)).*unity;
    case 4
        %output
        fig_input.mdv.output_var={'pmm'};
        output_m=extract_output(path_fold_main,fig_input);
        switch varp2
            case {1,2}
                yp=squeeze(output_m.pmm(varp2,kxp,:,ktp));
            case 3
                yp=squeeze(1./(output_m.pmm(2,kxp,:,ktp))); %M_{etab}
            case 4
                yp=squeeze(1./(output_m.pmm(1,kxp,:,ktp).*output_m.pmm(2,kxp,:,ktp)));
        end
    case 5
        %output
        fig_input.mdv.output_var={'etab'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(output_m.etab(:,kxp,:,ktp)).*unity;
    case 7
        fig_input.mdv.output_var={'Gammak'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(output_m.Gammak(varp2,kxp,:,ktp)).*unity;
    case 10
        fig_input.mdv.output_var={'h'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(output_m.h(:,kxp,:,ktp)).*unity;
    case 11 %approximate eigenvalues
        fig_input.mdv.output_var={'u','h','Cf','La','qbk','Mak','msk'};
        output_m=extract_output(path_fold_main,fig_input);
        
        error('eig_from_output needs to be finished')
        yp=eig_from_output(output_m);
    case 12
        fig_input.mdv.output_var={'qbk'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(sum(output_m.qbk(varp2,kxp,:,ktp),1)).*unity;
    case 15
        fig_input.mdv.output_var={'Gammak'};
        output_m=extract_output(path_fold_main,fig_input);

        yp=squeeze(sum(output_m.Gammak(varp2,kxp,:,ktp),1)).*unity;
    case 19 %detrended bed elevation
        %output
        fig_input.mdv.output_var={'etab'};
        output_m=extract_output(path_fold_main,fig_input);
        
        etab=squeeze(output_m.etab(:,kxp,:,ktp)); %[xp,xT]
        coef=NaN(nnT,2);
        for kT=1:nnT
            coef(kT,:)=polyfit(xp',etab(:,kT),1);
        end
        etab_d=etab-(coef(:,1)'.*xp'+coef(:,2)'); %etab-slope*x
        yp=etab_d.*unity;
end

   
end




