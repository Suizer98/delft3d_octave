%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: create_m_files_adcp.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/create_m_files_adcp.m $
%

function create_m_files_adcp(dir_data_anl,fdir_mat,varargin)


flg.anl_type1=1;
    flg.anl_type1_re=0; %reanalyze: 0=NO; 1=YES
flg.anl_type2=1;
    flg.anl_type2_re=0; %reanalyze: 0=NO; 1=YES
    
% flg.plot=1;
%     flg.plot_re=1; %replot: 0=NO; 1=YES
%     flg.plot_print=1; %0=NO; 1=png
%     in_p.fig_visible=0;
    
flg.debug=0;

flg=setproperty(flg,varargin);

%% CALC

%type 1
tok1='_ASC.TXT';
tok1_2='t.000';

%type 2
tok2='ype2.txt';

    %% walk directory

[dire1,dire2,dire3]=dirwalk(dir_data_anl);
nd=numel(dire3);

%start from beginning
order_anl=1:1:nd;

%start from the end
% order_anl=nd:-1:1;

%random order
% order_anl=randperm(nd);

    %% loop
    
for kd=order_anl
    fname=dire3{kd,1};
    if ~isempty(fname)
        nf=numel(fname);
        for kf=1:nf
            fnameext=dire3{kd,1}{kf,1};
            ffolder=dire1{kd,1};
            %% DEBUG
%             fdebug='p:\11204644-evaluatie-langsdammen\wp00_data_analyse\01_ADCP\output\mat\2019\flexibele metingen\2019_Week 27_Flexibelemeting WL\01_Stromingsmetingen\01_Meetfiles\Dreumel\Gevalideerde meetgegevens\P-files\20190704_ExtraMeting_Dreumel_0_001_ASC.mat';
%             clc
%             close all
%             [folder_debug,name_debug,ext_debug]=fileparts(fdebug);
%             fnameext=strcat(name_debug,ext_debug);
%             ffolder=folder_debug;   
%             in_p.fig_visible=1;
%             flg.debug=1;
%             % DEBUG END
            ffullname=fullfile(ffolder,fnameext);
            [~,fnameonly,fext]=fileparts(ffullname);

            ffolder_out_mat=strrep(ffolder,dir_data_anl,fdir_mat); %ffolder_out_mat=strrep(ffolder,dir_data,fullfile(dir_out,dir_tag_mat));
            mkdir_check(ffolder_out_mat)
            fsave=fullfile(ffolder_out_mat,sprintf('%s.mat',fnameonly));
            if numel(fnameext)>8
                tok=fnameext(end-7:end);
                %% ascii type 1
                if (strcmp(tok,tok1)||strcmp(tok(4:end),tok1_2)) && flg.anl_type1
%                 if strcmp(tok,tok1) && flg.anl_type1
                    if exist(fsave,'file')==2 && flg.anl_type1_re==0
                        fprintf('File skipped %s \n',ffullname);
                    else
                        create_m_file_from_type1(flg,ffullname,fsave);
                    end %exist

                end
                %% ascii type 2    
                if strcmp(tok,tok2) && flg.anl_type2
                    if exist(fsave,'file')==2 && flg.anl_type2_re==0
                        fprintf('File skipped %s \n',ffullname);
                    else
                        create_m_file_from_type2(flg,ffullname,fsave);
                    end %exist
                end %strcmp
            end %numel
        end %kf
    end %isempty(fname)
end %kd

end %function