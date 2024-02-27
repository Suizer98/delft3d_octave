%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18082 $
%$Date: 2022-05-27 22:38:11 +0800 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: grain_size_dX_mat.m 18082 2022-05-27 14:38:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/grain_size_dX_mat.m $
%
%

function val=grain_size_dX_mat(Fa,dchar,perc)

frac_nonan=Fa;
[nt,nF,nl,nf]=size(frac_nonan);
frac_nonan(isnan(frac_nonan))=0;

val=NaN(nt,nF,nl);
for kF=1:nF
    for kl=1:nl
        Fa=squeeze(frac_nonan(:,kF,kl,:));
        if sum(Fa)<1-1e-3 || sum(Fa)>1+1e-3 %take out values in which all are 0
            val(:,kF,kl)=NaN; 
        else
            dX=grain_size_dX(dchar,Fa,perc);
            val(:,kF,kl)=permute(dX,[3,4,2,1]); 
        end
    end %kl
end %kF

end %function