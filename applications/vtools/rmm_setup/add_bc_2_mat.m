%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17078 $
%$Date: 2021-02-19 13:31:44 +0800 (Fri, 19 Feb 2021) $
%$Author: chavarri $
%$Id: add_bc_2_mat.m 17078 2021-02-19 05:31:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/add_bc_2_mat.m $
%

function add_bc_2_mat(path_mat,path_dat)

%% CALL

if ~isempty(path_mat)
    load(path_matm,'tsc')
    ke=numel(tsc);
else
    ke=0;
end

dire_data=dir(path_dat);

nf=numel(dire_data)-2;

for kf=1:nf
    path_data_fname=dire_data(kf+2).name;
    path_data_folder=dire_data(kf+2).folder;
    path_data_fullpath=fullfile(path_data_folder,path_data_fname);
    
    [~,fname,ext]=fileparts(path_data_fname);
    
    switch ext
        %% SOB
        case '.sob'
%             "2000/12/01;00:00:00"	360.0
            fid=fopen(path_data_fullpath,'r'); 
            tok=regexp(fname,'-','split');
            location=tok{1,1};  
            
            data_raw=textscan(fid,'%{yyyy/MM/dd;HH:mm:ss}D %f');
            
            daty=data_raw{1,1};
            val=data_raw{1,2};
            
            Locatiecode=fname;
            Gegevensbron='old data';
            
            
            switch location
                case 'SVKH'
                    Locatienaam='Hartelkering';
                    Parametercode='hefhoogte';
                    Parametereenheid='m';
%                     switch tok{1,2}
%                         case 'b'
%                             gate='breed';
%                         case 's'
%                             gate='small';
%                     end
%                     switch tok{1,3}
%                         case 'g'
%                             
%                         case 's'
%                             Parametercode='spill pos';
%                     end
                case 'SVKW'
                    Locatienaam='Maeslantkering';  
                otherwise
                    error('Specify name')
            end
            
            switch tok{1,4}
                case 'h'
                    Parametercode='hefhoogte';
                    Parametereenheid='m';
                case 'w'
                    Parametercode='breede';
                    Parametereenheid='m';
                case 'p'
                    Parametercode='positie';
                    Parametereenheid='m';
            end
            
            %% save
            ke=ke+1;
            tsc(ke).val=val;
            tsc(ke).daty=daty;
            tsc(ke).Gegevensbron=Gegevensbron;
            tsc(ke).Locatiecode=Locatiecode;
            tsc(ke).Locatienaam=Locatienaam;
            tsc(ke).Parametercode=Parametercode;
            tsc(ke).Parametereenheid=Parametereenheid;
            
                    
        %% OTHER            
        otherwise
            error('Unknown file extension: %s',path_data_fullpath)
            
    end %ext
    
    path_mat_out=strrep(path_mat,'.mat','_mod.mat');
    save(path_mat_out,'tsc')
    
end %kf


