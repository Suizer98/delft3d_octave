%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17798 $
%$Date: 2022-02-28 19:05:51 +0800 (Mon, 28 Feb 2022) $
%$Author: chavarri $
%$Id: get_rain_prediction.m 17798 2022-02-28 11:05:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/weather/get_rain_prediction.m $
%

function get_rain_prediction(fdir_rain,url_br,T_data)

t_last=datetime(2000,01,01);

fname_rain=fullfile(fdir_rain,'rain.mat');
errstatus_dw=1;
errstatus_rd=1;
rain_one=struct();
while 1
    t_now=datetime('now');
    if seconds(t_now-t_last)>T_data
        while errstatus_rd
            while errstatus_dw
                pause(15)
                messageOut(NaN,'Trying to download.')
                t_now=datetime('now');
                fpath_html=fullfile(fdir_rain,sprintf('file_%f.html',datenum(t_now)));
                errstatus_dw=download_web(url_br,fpath_html);
            end
            errstatus_dw=1; %if you don't manage to read, try to download again
            messageOut(NaN,'Trying to read.')
            [rain_one,errstatus_rd,errmessage]=read_web_buienradar(fpath_html);
        end
        errstatus_rd=1; %set to error, such that it reads in the next loop
        
%         fclose all; %this should not be necessary, but for some reason sometimes the file cannot be deleted
%         pause(5); %maybe this helps
        delete(fpath_html);
        rain_one.tim_anl=datetime('now');
        if exist(fname_rain,'file')==2
            load(fname_rain,'rain');
            nr=numel(rain);
            rain(nr+1)=rain_one;
        else
            rain=rain_one;
        end
        save(fname_rain,'rain')
        t_last=t_now;
        messageOut(NaN,'Data read.')
    else
        messageOut(NaN,'In pause.')
        pause(T_data/6);
    end
    
end