%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17471 $
%$Date: 2021-09-01 04:34:21 +0800 (Wed, 01 Sep 2021) $
%$Author: chavarri $
%$Id: read_web_buienradar.m 17471 2021-08-31 20:34:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/weather/read_web_buienradar.m $
%

function [out,errstatus,errmessage]=read_web_buienradar(fpath_html,varargin)

%use <div>Versie: 1.7.6892.0</div> if changes?

out=struct();
errstatus=0;
errmessage='';

fid=fopen(fpath_html,'r');

lin=fgetl(fid);
while ~errstatus && ~contains(lin,'class="forecast"')
    lin=fgetl(fid);
    [errstatus,errmessage]=feof_check(fid);
    if errstatus
        return
    end
end %feof

kb=0;
rain=[];
while ~errstatus && ~contains(lin,'class="date"') && ~contains(lin,'class="model-date"')
    lin=fgetl(fid);
    [errstatus,errmessage]=feof_check(fid);
    if errstatus
        return
    end 
    if contains(lin,'class="model-date"')
        continue
    end
    if contains(lin,'class="date"')    
    %<div class="date">07-08</div>
    %     tok_date=regexp(lin,'>(\d*)-(\d*))<','tokens'); %not really necessary, first is the current date
        tok_rain={};
        while ~errstatus && isempty(tok_rain)
            lin=fgetl(fid);
            [errstatus,errmessage]=feof_check(fid);
            if errstatus
                return
            end
            %2,8<br>mm
            tok_rain=regexp(lin,'([+-]?(\d+(\,\d+)?)|(\,\d+))<br>mm','tokens');
        end
        kb=kb+1;
        rain=cat(1,rain,undutchify(tok_rain{1,1}{1,1}));
    end
end %feof

year_now=year(datetime('now'));
tok=regexp(lin,'(\d*) (\w*) (\d{2}):(\d{2})','tokens');
month_dutch=tok{1,1}{1,2};
month_num=month_dutch2num(month_dutch);
tim_model=datetime(year_now,month_num,str2double(tok{1,1}{1,1}),str2double(tok{1,1}{1,3}),str2double(tok{1,1}{1,4}),0);

if numel(rain)~=14
    errstatus=1;
    errmessage='I could not find 14 blocks of rain';
end

%save
out=v2struct(tim_model,rain);
fclose(fid);

end %function

%%
%% FUNCTIONS
%%

function [errstatus,errmessage]=feof_check(fid)

errstatus=0;
errmessage='';

if feof(fid)
    fclose(fid);
    errstatus=1;
    errmessage='I reached the end and could not find the block';
end
    
end