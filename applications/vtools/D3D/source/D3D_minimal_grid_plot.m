
%% INPUT

simdef.D3D.dire_sim='C:\Users\chavarri\checkouts\riverlab\real_world\Rijntakken_1D\models\f_007\dflowfm';

%% CALC

simdef.flg.print=NaN; %do not print
simdef.flg.which_p='grid';
simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,NaN);
D3D_figure_domain(simdef,out_read);