%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17464 $
%$Date: 2021-08-25 19:15:39 +0800 (Wed, 25 Aug 2021) $
%$Author: chavarri $
%$Id: read_conversion_labels.m 17464 2021-08-25 11:15:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/read_conversion_labels.m $
%

function [loclabels,loclabels_rtc]=read_conversion_labels(path_loclabels)

%% READ

run(path_loclabels);

%% CALC

%check same number of input
nl=numel(labels_data);
nl_t=numel(labels_s3);

if nl~=nl_t
    error('different number of labels!')
end

%construct structure
loclabels=struct();
for kl=1:nl    
    loclabels(kl).var=val{kl,1}; %problem calling it <var>
    loclabels(kl).data=labels_data{kl,1};
    
    loclabels(kl).s3=labels_s3{kl,1};
    loclabels(kl).function_s3=function_s3(kl,1);
    loclabels(kl).function_param_s3=function_param_s3(kl,1);
    
    loclabels(kl).sre=labels_sre{kl,1};
    loclabels(kl).function_sre=function_sre(kl,1);
    loclabels(kl).function_param_sre=function_param_sre(kl,1);
end %kl

    %% RTC
%check same number of input
nlr=numel(labels_data_rtc);
nlr_t=numel(labels_s3_rtc);

if nlr~=nlr_t
    error('different number of labels!')
end
%construct structure RTC
loclabels_rtc=struct();
for klr=1:nlr
    loclabels_rtc(klr).data=labels_data_rtc{klr,1};
    loclabels_rtc(klr).s3=labels_s3_rtc{klr,1};
    loclabels_rtc(klr).sre=labels_sre_rtc{klr,1};
    if exist('labels_s3_rtc_block','var')
        loclabels_rtc(klr).s3_block=labels_s3_rtc_block{klr,1};  
    else
        loclabels_rtc(klr).s3_block=loclabels_rtc(klr).s3;
    end
    if exist('function_s3_rtc','var')
        loclabels_rtc(klr).s3_function=function_s3_rtc(klr,1);   
    else
        loclabels_rtc(klr).s3_function=0;
    end
    if exist('param_s3_rtc','var')
        loclabels_rtc(klr).s3_param=param_s3_rtc(klr,1);   
    else
        loclabels_rtc(klr).s3_param=0;
    end
end %kl


end %function