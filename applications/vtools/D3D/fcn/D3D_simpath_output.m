%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17790 $
%$Date: 2022-02-24 19:09:51 +0800 (Thu, 24 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_simpath_output.m 17790 2022-02-24 11:09:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath_output.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -path_results = path to the folder containg the output
%
%TODO:
%   -change to dirwalk

function [file,err]=D3D_simpath_output(path_results)

err=0;
partitions=0;
dire_res=dir(path_results);
nfr=numel(dire_res)-2;
for kflr=1:nfr
    kf=kflr+2; %. and ..
    if dire_res(kf).isdir==0 %it is not a directory
    [~,~,ext]=fileparts(dire_res(kf).name); %file extension
    switch ext
        case '.nc'
            if strcmp(dire_res(kf).name(end-5:end-3),'map')
                if ~contains(dire_res(kf).name,'merge')
                    file.map=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    partitions=partitions+1;
                    
                    %check we are not missing
                    num_part=str2double(file.map(end-10:end-10+3));
                    if ~isnan(num_part) && num_part~=partitions-1
                        err=1;
                    end
                end
            end
            if strcmp(dire_res(kf).name(end-5:end-3),'his')
                file.his=fullfile(dire_res(kf).folder,dire_res(kf).name);
            end
        case '.dia'
            file.dia=fullfile(dire_res(kf).folder,dire_res(kf).name);
%                 case '.shp'
%                     tok=regexp(dire_res(kf).name,'_','split');
%                     file.shp.(tok{1,1}{end})=fullfile(dire_res(kf).folder,dire_res(kf).name);
    end
    else %directory in results directory
        dire_res2=dir(fullfile(dire_res(kf).folder,dire_res(kf).name));
        nfr2=numel(dire_res2)-2;
        for kflr2=1:nfr2
            kf=kflr2+2; %. and ..
            if dire_res2(kf).isdir==0 %it is not a directory
                [~,~,ext]=fileparts(dire_res2(kf).name); %file extension
                switch ext
                    case '.shp'
                        tok=regexp(dire_res2(kf).name,'_','split');
                        str_name=strrep(tok{1,end},'.shp','');
                        file.shp.(str_name)=fullfile(dire_res2(kf).folder,dire_res2(kf).name);
                end
            end %if no dir 2
        end %kflr2
    end %if no dir
end %kflr

if err==1
    messageOut(NaN,sprintf('Missing map files here: %s',path_results));    
end

file.partitions=partitions;

end %function