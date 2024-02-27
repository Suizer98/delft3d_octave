function mdu = d3d2dflowfm_times(mdf,mdu,~)

% d3d2dflowfm_times : Writes TIMES information to the mdu structure

mdu.time.RefDate      = [mdf.itdate(1:4) mdf.itdate(6:7) mdf.itdate(9:10)];
mdu.time.Tzone        = mdf.tzone;
mdu.time.Tunit        = 'S';
mdu.time.DtUser       = mdf.dt*60.;
mdu.time.DtMax        = mdf.dt*60.;
mdu.time.DtInit       = mdu.time.DtMax/10.;
mdu.time.TStart       = mdf.tstart*60.;
mdu.time.TStop        = mdf.tstop*60.;

%% Overwrite automatic time step, stay as close to Delft3D-Flow as possible
%  mdu.time.AutoTimestep = 0;
