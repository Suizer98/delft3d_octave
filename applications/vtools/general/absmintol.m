%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18279 $
%$Date: 2022-08-02 22:45:02 +0800 (Tue, 02 Aug 2022) $
%$Author: chavarri $
%$Id: absmintol.m 18279 2022-08-02 14:45:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absmintol.m $
%
%Find index <idx> of vector <v> with value closer to <o>.
%
%OUTPUT:
%   -idx: index
%   -min_v: difference with objective
%   -flg_found: 0=not found; 1=found

function [idx,min_v,flg_found]=absmintol(v,o,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tol',1e-1);
addOptional(parin,'fid_log',NaN);
addOptional(parin,'do_break',1);
addOptional(parin,'do_disp_list',1);
addOptional(parin,'dnum',0);

parse(parin,varargin{:});

tol=parin.Results.tol;
fid_log=parin.Results.fid_log;
do_break=parin.Results.do_break;
is_dnum=parin.Results.dnum;
do_disp_list=parin.Results.do_disp_list;

%% CALC

if isdatetime(v)
    is_dtime=1;
    if isnumeric(tol)
        tol=seconds(tol);
    end
    if is_dnum==1
        messageOut(fid_log,'You are setting it to datenum, but it datetime. I am changing it.');
        is_dnum=0;
    end
else
    is_dtime=0;
end

[min_v,idx]=min(abs(v-o));
if min_v>tol
    flg_found=0;
    if is_dnum
        messageOut(fid_log,sprintf('Desired value %s is beyond tolerance %f days',datestr(o,'yyyy-mm-dd HH:MM:SS'),tol));
        if do_disp_list==1
            messageOut(fid_log,'Possible values, difference with objective [days]:');
        elseif do_disp_list==2
            messageOut(fid_log,'Closest value, difference with objective [days]:');    
        end
    elseif is_dtime
        messageOut(fid_log,sprintf('Desired value %s is beyond tolerance %f s',o,seconds(tol)));
        if do_disp_list==1
            messageOut(fid_log,'Possible values, difference with objective:');        
        elseif do_disp_list==2
            messageOut(fid_log,'Closest value, difference with objective:');    
        end
    else
        messageOut(fid_log,sprintf('Desired value %f is beyond tolerance %f',o,tol));
        if do_disp_list==1
            messageOut(fid_log,'Possible values, difference with objective:');
        elseif do_disp_list==2
            messageOut(fid_log,'Closest value, difference with objective:');    
        end
    end
    
    if do_disp_list==1
        n=numel(v);
        for k=1:n
            if is_dnum
                messageOut(fid_log,sprintf('%s %f \n',datestr(v(k),'yyyy-mm-dd HH:MM:SS'),v(k)-o));
            elseif is_dtime
                messageOut(fid_log,sprintf('%s %f s\n',datestr(v(k),'yyyy-mm-dd HH:MM:SS'),seconds(v(k)-o)));
            else
                messageOut(fid_log,sprintf('%f %f \n',v(k),v(k)-o));
            end
        end
    elseif do_disp_list==2
        if is_dnum
            messageOut(fid_log,sprintf('%s %f \n',datestr(v(idx),'yyyy-mm-dd HH:MM:SS'),min_v));
        elseif is_dtime
            messageOut(fid_log,sprintf('%s %f s \n',datestr(v(idx),'yyyy-mm-dd HH:MM:SS'),seconds(min_v)));
        else
            messageOut(fid_log,sprintf('%f %f \n',v(idx),min_v));
        end
    end
    
    if do_break
        error('See above')
    end
else
    flg_found=1;
end
