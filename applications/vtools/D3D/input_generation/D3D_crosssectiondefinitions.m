%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17737 $
%$Date: 2022-02-07 16:06:58 +0800 (Mon, 07 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_crosssectiondefinitions.m 17737 2022-02-07 08:06:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_crosssectiondefinitions.m $
%
%write cross-section definitions file

%INPUT:
%   -simdef.D3D.dire_sim = path to the folder where to write the file [string]
%   -simdef.csd = structure with cross-sectional info as it must be written (check by reading using S3_read_crosssectiondefinitions)
%
%OUTPUT:
%   -       
%
%NOTES:
%   -'LeveeTransitionHeight is hardcoded'

function D3D_crosssectiondefinitions(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'check_existing',true)
addOptional(parin,'fname','CrossSectionDefinitions.ini')
addOptional(parin,'csd_global',NaN)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;
fname=parin.Results.fname;
csd_global=parin.Results.csd_global;

%% RENAME

dire_sim=simdef.D3D.dire_sim;
csd=simdef.csd;  
if isnan(csd_global)
    csd_global=struct();
    csd_global.leveeTransitionHeight=0.75;
end

ncsd=numel(csd);
fields_csd=fields(csd);
nfields=numel(fields_csd);

%% FILE

kl=1;
%%
data{kl,1}=        '[General]'; kl=kl+1;
data{kl,1}=        '   fileVersion           = 3.00'; kl=kl+1;
data{kl,1}=        '   fileType              = crossDef'; kl=kl+1;
%% 
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Global]'; kl=kl+1;
data{kl,1}=sprintf('   leveeTransitionHeight = %5.2f',csd_global.leveeTransitionHeight); kl=kl+1;
%%
for kcsd=1:ncsd
    nlevels=csd(kcsd).numLevels;
    
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Definition]'; kl=kl+1;
    for kfields=1:nfields
        if ischar(csd(kcsd).(fields_csd{kfields}))
            switch fields_csd{kfields}
                case 'id'
                    data{kl,1}=sprintf('   %s = #%s# ',fields_csd{kfields},csd(kcsd).(fields_csd{kfields})); kl=kl+1;
                otherwise
                    data{kl,1}=sprintf('   %s = %s ',fields_csd{kfields},csd(kcsd).(fields_csd{kfields})); kl=kl+1;
            end
        else %double
            if numel(csd(kcsd).(fields_csd{kfields}))>1
                aux_str=repmat('%f ',1,nlevels);
                aux_str2=sprintf('   %s = %s ',fields_csd{kfields},aux_str);
                data{kl,1}=sprintf(aux_str2,csd(kcsd).(fields_csd{kfields})); kl=kl+1;
            else
                data{kl,1}=sprintf('   %s = %f ',fields_csd{kfields},csd(kcsd).(fields_csd{kfields})); kl=kl+1;
            end
            
        end
    end
end

%% WRITE

file_name=fullfile(dire_sim,fname);
writetxt(file_name,data,'check_existing',check_existing)
