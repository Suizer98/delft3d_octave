function mdu = d3d2dflowfm_numerical(mdf,mdu,~)

% d3d2dflowfm_numerical : Set numerical defaults to the mdu struct (when not corresponding to defaults in csv file)

mdu.numerics.Limtypsa     = 4;
if mdu.physics.Salinity  mdu.numerics.Limtypsa     = 4; end
mdu.numerics.Tlfsmo       = mdf.tlfsmo*60.0;
mdu.numerics.Slopedrop2D  = 0.;
