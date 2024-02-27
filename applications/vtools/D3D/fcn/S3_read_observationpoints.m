%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: S3_read_observationpoints.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_read_observationpoints.m $
%

function [obs_in,obs]=S3_read_observationpoints(path_obs)

obs_in=read_ascii(path_obs);

nlobsin=numel(obs_in);
obs=struct();
kobs=1;
for kl=1:nlobsin
    str_loc=obs_in{kl,1};
    if contains(str_loc,'[ObservationPoint]')
        
        %it would be better to identify the positions of the tags (e.g. id,
        %branch, ... rather than assuming the order)
        
        %id
        str_aux=obs_in{kl+1,1};
        expr='\w+([.-]?\w+)*';
        str_aux_r=regexp(str_aux,expr,'match');
        obs(kobs).id=str_aux_r{1,2}; %get rid of 'id'
        
        %branchid
        str_aux=obs_in{kl+2,1};
        expr='\w+([.-]?\w+)*';
        str_aux_r=regexp(str_aux,expr,'match');
        obs(kobs).branchid=str_aux_r{1,2}; %get rid of 'id'
        
        %chainage
        str_aux=obs_in{kl+3,1};
        expr='\d+.\d+';
        str_aux_r=regexp(str_aux,expr,'match');
        obs(kobs).chainage=str2double(str_aux_r{1,1}); 
        
        %name
        str_aux=obs_in{kl+4,1};
        expr='\w+([.-]?\w+)*';
        str_aux_r=regexp(str_aux,expr,'match');
        obs(kobs).name=str_aux_r{1,2}; %first is 'name'
        
        %update
        kobs=kobs+1;
    end
end

end %function