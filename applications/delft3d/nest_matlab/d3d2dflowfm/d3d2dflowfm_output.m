function mdu = d3d2dflowfm_output( mdf,mdu,~)

% d3d2dflowfm_output: sets output times in the mdu structure

mdu.output.HisInterval   = mdf.flhis(2)*60.;
mdu.output.MapInterval   = [num2str(mdf.flmap(2)*60) ' ' num2str(mdf.flmap(1)*60.) ' ' num2str(mdf.flmap(3)*60.)];
mdu.output.RstInterval   = mdf.flrst*60.;
mdu.output.WaqInterval   = mdf.flpp(2)*60.;
mdu.output.StatsInterval = 0.;
