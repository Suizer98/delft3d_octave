%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: read_xyz.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/read_xyz.m $
%
%writes reference in tex file

function [xyz_all,err]=read_xyz(fname)

err=0;
fid=fopen(fname,'r');
kl=0;
npreall=1000;
while ~feof(fid)
    kl=kl+1;
    lin=fgetl(fid);
    tok=regexp(lin,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens');
    if isempty(tok)
        messageOut(NaN,'Cannot read the file, sorry.')
        err=1;
        break 
    end
    xyz=cellfun(@(X)str2double(X),tok);
    if kl==1
        nc=numel(xyz);
        xyz_all=NaN(npreall,nc);
        nr=size(xyz_all,1);
    elseif kl==nr
        xyz_all=cat(1,xyz_all,NaN(npreall,nc));
        nr=size(xyz_all,1);
    end
    xyz_all(kl,:)=xyz;
end
xyz_all=xyz_all(1:kl,:);

end