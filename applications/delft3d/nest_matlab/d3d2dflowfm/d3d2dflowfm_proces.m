function mdu = d3d2dflowfm_proces(mdf,mdu, name_mdu)

% d3d2dflowfm_proces : Detremine whether salinity = active or not

if strcmpi(mdf.sub1(1),'s') mdu.physics.Salinity = 1; end
end
