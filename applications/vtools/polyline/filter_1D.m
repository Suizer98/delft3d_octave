%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18336 $
%$Date: 2022-08-26 17:21:36 +0800 (Fri, 26 Aug 2022) $
%$Author: chavarri $
%$Id: filter_1D.m 18336 2022-08-26 09:21:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/filter_1D.m $
%
%

function [tim_f,data_f]=filter_1D(time_dtime,data,varargin)
            
%% PARSE

parin=inputParser;

addOptional(parin,'method','mean');
addOptional(parin,'window',25*3600);
addOptional(parin,'time',NaN);
addOptional(parin,'x',NaN);
addOptional(parin,'x_thres',NaN);

parse(parin,varargin{:});

method=parin.Results.method;
window=parin.Results.window;
tim_f=parin.Results.time;
x=parin.Results.x;
x_thres=parin.Results.x_thres;

%% CALC

switch method
    case 'mean'
        if ~isdatetime(tim_f)
            tim_f=dateshift(time_dtime(1),'start','day'):seconds(window):dateshift(time_dtime(end),'start','day');
        end
        data_f=interpolate_timetable({time_dtime},{data},tim_f,'disp',0); %make the input to work if several stations?
    case 'movmean'
        [data_f,tim_f]=movmean_tim(time_dtime,data,window);
    case 'godin'
        if isvector(data)
            data=reshape(data,[],1);
        end
        ks=1;
        [time_dtime,data_u]=uniform_data(time_dtime,data(:,ks));
        time_dnum_00=datenum(time_dtime);
        [data_f0,tim_f_dnum]=godin(time_dnum_00,data_u); %deal with several stations
        tim_f=datetime(tim_f_dnum,'convertFrom','datenum','TimeZone',time_dtime.TimeZone);
        
        ns=size(data,2);
        np=numel(data_f0);
        data_f=NaN(np,ns);
        data_f(:,1)=data_f0;
        for ks=1:ns
            [time_dtime,data_u]=uniform_data(time_dtime,data(:,ks));
            [data_f(:,ks),~]=godin(time_dnum_00,data_u); %deal with several stations
        end
    case 'tidal_max'
        if isvector(data)
            data=reshape(data,[],1);
        end
        ns=size(data,2);
        tim_c=cell(ns,1);
        data_c=cell(ns,1);
        for ks=1:ns
            [tim_c{ks,1},data_c{ks,1}]=tidal_values(time_dtime,data(:,ks),'T',seconds(window));
        end
        if ns==1
            tim_f=tim_c{1,1};
            data_f=data_c{1,1};
        else
            if ~isdatetime(tim_f)
                tim_f=dateshift(time_dtime(1),'start','day'):seconds(window)/10:dateshift(time_dtime(end),'start','day');
            end
            [~,~,val_m]=interpolate_xy(x,tim_c,data_c,x,tim_f,x_thres);
            data_f=val_m'; %later it is transposed
        end        
end

end %function