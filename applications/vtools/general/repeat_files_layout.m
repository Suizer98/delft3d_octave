
%% INPUT

path_in='p:\11203223-tki-rivers\02_rijntakken_2020\05_postprocessing\sedtrans\main_sedtrans.m ';

%% CALC

%rad
raw=read_ascii(path_in);

%modify
for kl=2:10
raw{35,1}=sprintf('dire_sim_v{kf}=fullfile(path_runs,''/str_%03d/dflowfm/'');',kl);
path_out=sprintf('p:\\11203223-tki-rivers\\02_rijntakken_2020\\05_postprocessing\\sedtrans\\main_sedtrans%d.m',kl);
writetxt(path_out,raw);
end
