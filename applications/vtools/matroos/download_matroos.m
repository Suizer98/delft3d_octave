%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17443 $
%$Date: 2021-08-03 03:26:28 +0800 (Tue, 03 Aug 2021) $
%$Author: chavarri $
%$Id: download_matroos.m 17443 2021-08-02 19:26:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/matroos/download_matroos.m $
%
%generates a sh-file to download data from matroos based on a script from Jelmer Venstra


% #!/bin/bash
% 
% #matroos source: deltares or rws
% var_matroos=deltares
% 
% #periode1: 20070930 20090101 (niet beschikbaar in deltares matroos hirlam v7.2, periode1+2 niet beschikbaar in rws matroos)
% #periode2: 20101130 20120101
% #periode3: 20121101 20140101
% var_tstart=20180501
% var_tstop=20180601
% 
% var_xn=38
% var_yn=26
% 
% var_tstartlong=$(printf '%s0000' "$var_tstart")
% var_tstoplong=$(printf '%s0000' "$var_tstop")
% 
% #choose matroos hirlam 7.0 or 7.2 source
% if [ "$var_tstart" -gt "20091024" ]; then
%     var_url="http://matroos.$var_matroos.nl/matroos/scripts/matroos.pl?source=knmi_h11_v72&color=air_pressure_fixed_height,eastward_wind,northward_wind&from=$var_tstartlong&to=$var_tstoplong&z=0&xmin=17000&xmax=165000&ymin=405000&ymax=505000&coords=RD&xn=$var_xn&yn=$var_yn&format=nc"
% else
%     var_url="http://matroos.$var_matroos.nl/matroos/scripts/matroos.pl?source=knmi_h11_v70&color=gribvar1_fixed_height,gribvar33,gribvar34&interpolate=count&from=$var_tstartlong&to=$var_tstoplong&z=0&xmin=17000&xmax=165000&ymin=405000&ymax=505000&coords=RD&xn=$var_xn&yn=$var_yn&format=nc&fieldoutput=air_pressure_fixed_height,eastward_wind,northward_wind"
% fi
% 
% echo $var_url
% 
% if [ "$var_matroos" = "deltares" ]; then
%     #Deltares matroos
%     var_filename=$(printf 'data_knmih11v72_deltares_RD_%s_%s_GMT-v2.nc' "$var_tstart" "$var_tstop")
%     wget --proxy=off -O $var_filename $var_url
% elif [ "$var_matroos" = "rws" ]; then
%     #rws matroos
%     var_filename=$(printf 'data_knmih11v72_rws_RD_%s_%s_GMT-v2.nc' "$var_tstart" "$var_tstop")
%     wget --user deltares --password Cae_waiYoh0n --proxy=off -O $var_filename $var_url
% else
%     echo var_matroos not valid
% fi

function download_matroos(path_dir_out,tim_0,tim_f,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'dt',tim_f-tim_0);
addOptional(parin,'var_xn',38)
addOptional(parin,'var_yn',26)
addOptional(parin,'var_matroos','deltares')
addOptional(parin,'x_min',17000)
addOptional(parin,'x_max',165000)
addOptional(parin,'y_min',405000)
addOptional(parin,'y_max',505000)
addOptional(parin,'format','nc')
addOptional(parin,'coords','RD')

parse(parin,varargin{:})

dt=parin.Results.dt;
var_xn=parin.Results.var_xn;
var_yn=parin.Results.var_yn;
var_matroos=parin.Results.var_matroos;
x_min=parin.Results.x_min;
x_max=parin.Results.x_max;
y_min=parin.Results.y_min;
y_max=parin.Results.y_max;
f_format=parin.Results.format;
coords=parin.Results.coords;

%% CALC

tim_v=tim_0:dt:tim_f;
nt=numel(tim_v)-1;
fname_sh='download_matroos_all.sh';
path_all_p=fullfile(path_dir_out,fname_sh);
path_all_c=fullfile(pwd,fname_sh);
fid_all=fopen(path_all_c,'w');

%local file
fprintf(fid_all,'!/bin/bash \n');
fprintf(fid_all,' \n');
fprintf(fid_all,'cd %s \n',linuxify(path_dir_out));

for kt=1:nt
    t0_str=datestr(tim_v(kt  ),'yyyymmddHHMM');
    tf_str=datestr(tim_v(kt+1),'yyyymmddHHMM');
    file_name=sprintf('knmi_h11_v72_%s_%s.nc',t0_str,tf_str);

    if tim_0>datetime(2009,10,24)
        var_url=sprintf('http://matroos.%s.nl/matroos/scripts/matroos.pl?source=knmi_h11_v72&color=air_pressure_fixed_height,eastward_wind,northward_wind&from=%s&to=%s&z=0&xmin=%d&xmax=%d&ymin=%d&ymax=%d&coords=%s&xn=%d&yn=%d&format=%s',var_matroos,t0_str,tf_str,x_min,x_max,y_min,y_max,coords,var_xn,var_yn,f_format);
    else
        var_url=sprintf('http://matroos.%s.nl/matroos/scripts/matroos.pl?source=knmi_h11_v70&color=gribvar1_fixed_height,gribvar33,gribvar34&interpolate=count&from=%s&to=%s&z=0&xmin=%d&xmax=%d&ymin=%d&ymax=%d&coords=%s&xn=%d&yn=%d&format=%s&fieldoutput=air_pressure_fixed_height,eastward_wind,northward_wind',var_matroos,t0_str,tf_str,x_min,x_max,y_min,y_max,coords,var_xn,var_yn,f_format);
    end

    switch var_matroos
        case 'deltares'
            fprintf(fid_all,'wget --proxy=off -O %s "%s" \n',file_name,var_url);
        case 'rws'
            fprintf(fid_all,'wget --user deltares --password Cae_waiYoh0n --proxy=off -O %s "%s" \n',file_name,var_url);
    end

    fprintf('writing file %4.2f %% \n',kt/nt*100);
end %kt

fclose(fid_all);

%copy
copyfile(path_all_c,path_all_p)
delete(path_all_c)
messageOut(NaN,sprintf('file created: %s',path_all_p));
fprintf('In H6: \n')
fprintf('qsub %s &> read.txt \n',linuxify(path_all_p))

end %functions