%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: write_references.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/references/write_references.m $
%
%writes reference in tex file

function write_references(paths_tex,paths_bib)

str_find_1='@'; %@Article{Cordier2019,
str_find_2='\w+([.-]?\w+)*'; %@Article{Cordier2019,
    
%read bib file
rawbib=read_ascii(paths_bib);

%begin of tex file
kl=1;
tex{kl,1}='\documentclass[10pt]{article} '; kl=kl+1;
tex{kl,1}='\usepackage[margin=2cm,landscape,a3paper]{geometry}'; kl=kl+1;
tex{kl,1}='\usepackage{natbib}'; kl=kl+1;
tex{kl,1}='\DeclareRobustCommand{\van}[3]{#2}'; kl=kl+1;
tex{kl,1}='\begin{document}'; kl=kl+1;
tex{kl,1}='\section{Useless}'; kl=kl+1;


nlb=numel(rawbib);
for knlb=1:nlb
    
    [str_match_1,str_idx]=regexp(rawbib{knlb,1},str_find_1,'match');
    if isempty(str_match_1)==0
        str_match_2=regexp(rawbib{knlb,1},str_find_2,'match');
        if numel(str_match_2)==1
            error('It seems that there is an empty reference in line %d, please remove is',knlb)
        end
        tex{kl,1}=sprintf('\\citet{%s} ',str_match_2{1,2}); 
        kl=kl+1;
    end

    %display
    fprintf('percentage done = %5.2f%% \n',knlb/nlb*100)
    
end

%end of tex file
tex{kl,1}='\DeclareRobustCommand{\van}[3]{#3}'; kl=kl+1;
tex{kl,1}='\bibliographystyle{agufull08_mod}'; kl=kl+1;
tex{kl,1}='\texttt{\bibliography{references}}'; kl=kl+1;
tex{kl,1}='\end{document}'; kl=kl+1;

%write
writetxt(paths_tex,tex,'check_existing',false);
