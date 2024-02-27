%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: latex_compile.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/latex/latex_compile.m $
%
%Compile LaTeX file

function latex_compile(fpath_tex)

fdir_o=pwd;

[fdir,fname,fext]=fileparts(fpath_tex);

cd(fdir);
delete(sprintf('%s.aux',fname));
delete(sprintf('%s.log',fname));
system(sprintf('pdflatex %s',fpath_tex));
system(sprintf('bibtex  %s',fname));
system(sprintf('pdflatex %s',fpath_tex));
system(sprintf('pdflatex %s',fpath_tex));
cd(fdir_o);

end %function
