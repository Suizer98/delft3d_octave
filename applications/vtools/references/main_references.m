
%% PREAMBLE

clear

%% INPUT

% paths_ref='../../../../references/'; %folder with references and tex file
paths_ref='c:\Users\chavarri\checkouts\riv\references\';

paths_name='print_references';
paths_bib=fullfile(paths_ref,'references.bib');

%% CALC

paths_tex=fullfile(paths_ref,sprintf('%s.tex',paths_name));
paths_aux=fullfile(paths_ref,sprintf('%s.aux',paths_name));
paths_bbl=fullfile(paths_ref,sprintf('%s.bbl',paths_name));
paths_blg=fullfile(paths_ref,sprintf('%s.blg',paths_name));

write_references(paths_tex,paths_bib)
cd(paths_ref)
dos(sprintf('del %s',paths_aux))
dos(sprintf('del %s',paths_bbl))
dos(sprintf('del %s',paths_blg))
dos(sprintf('pdflatex %s',paths_tex))
dos(sprintf('bibtex %s',paths_name))
modify_bbl(paths_ref)
dos(sprintf('pdflatex %s',paths_tex))


