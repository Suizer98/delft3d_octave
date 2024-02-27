%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18457 $
%$Date: 2022-10-17 20:32:45 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: mkdir_check.m 18457 2022-10-17 12:32:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/mkdir_check.m $
%
%mkdir_check(path_dir,NaN,1,0);  %break and no display

function sta=mkdir_check(path_dir,varargin)

switch numel(varargin)
    case 0
        fid_log=NaN;
        do_break=false;
        do_disp=true;
    case 1
        fid_log=varargin{1,1};
        do_break=false;
        do_disp=true;
    case 2
        fid_log=varargin{1,1};
        do_break=varargin{1,2};
        do_disp=true;
    case 3
        fid_log=varargin{1,1};
        do_break=varargin{1,2};
        do_disp=varargin{1,3};
end

if exist(path_dir,'dir')~=7
    [status,msg]=mkdir(path_dir);
    if status==1
        sta=1; %new folder
        if do_disp
            messageOut(fid_log,sprintf('Folder created: %s',path_dir));
        end
    else
        sta=0; %not created
        if do_break
            error('Could not create folder %s because %s \n',path_dir,msg)
        else
            if do_disp
                messageOut(fid_log,sprintf('Could not create folder %s because %s \n',path_dir,msg));
            end
        end
    end
else
    sta=2; %already exists
    if do_disp
        messageOut(fid_log,sprintf('Folder already exists: %s',path_dir));
    end
end

end