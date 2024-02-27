%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17936 $
%$Date: 2022-04-05 19:43:17 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_simpath_output_s.m 17936 2022-04-05 11:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath_output_s.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -path_results = path to the folder containg the output
%
%TODO:
%   -change to dirwalk

function file=D3D_simpath_output_s(path_results)

partitions=0;
dire_res=dir(path_results);
nfr=numel(dire_res)-2;
for kflr=1:nfr
    kf=kflr+2; %. and ..
    if dire_res(kf).isdir==0 %it is not a directory
    [~,fname,ext]=fileparts(dire_res(kf).name); %file extension
    switch ext
        case '.dat'
            if strcmp(dire_res(kf).name(1:4),'trim')
                file.map=fullfile(dire_res(kf).folder,dire_res(kf).name);
                partitions=partitions+1;
            end
            if strcmp(dire_res(kf).name(1:4),'trih')
                file.his=fullfile(dire_res(kf).folder,dire_res(kf).name);
            end
%         case '.dia'
%             file.dia=fullfile(dire_res(kf).folder,dire_res(kf).name);
    end
    if strcmp(fname,'tri-diag')
        file.dia=fullfile(dire_res(kf).folder,dire_res(kf).name);
    end
%     else %directory in results directory
%         dire_res2=dir(fullfile(dire_res(kf).folder,dire_res(kf).name));
%         nfr2=numel(dire_res2)-2;
%         for kflr2=1:nfr2
%             kf=kflr2+2; %. and ..
%             if dire_res2(kf).isdir==0 %it is not a directory
%                 [~,~,ext]=fileparts(dire_res2(kf).name); %file extension
%                 switch ext
%                     case '.shp'
%                         tok=regexp(dire_res2(kf).name,'_','split');
%                         str_name=strrep(tok{1,end},'.shp','');
%                         file.shp.(str_name)=fullfile(dire_res2(kf).folder,dire_res2(kf).name);
%                 end
%             end %if no dir 2
%         end %kflr2
    end %if no dir
end %kflr

file.partitions=partitions;

end %function