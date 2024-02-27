function mdu = d3d2dflowfm_cleanup(mdu)

%% Clean up mdu structure (if passed on) and set name of the external forcing file in the mdu structure

mdu = rmfield(mdu,'pathmdu');
if isfield(mdu,'Filbnd'    ) mdu = rmfield(mdu,'Filbnd'    ) ;end
if isfield(mdu,'Filini_wl' ) mdu = rmfield(mdu,'Filini_wl' ) ;end
if isfield(mdu,'Filini_sal') mdu = rmfield(mdu,'Filini_sal') ;end
if isfield(mdu,'Filini_tem') mdu = rmfield(mdu,'Filini_tem') ;end
if isfield(mdu,'Filrgh'    ) mdu = rmfield(mdu,'Filrgh'    ) ;end
if isfield(mdu,'Filvico'   ) mdu = rmfield(mdu,'Filvico'   ) ;end
if isfield(mdu,'Fildico'   ) mdu = rmfield(mdu,'Fildico'   ) ;end
if isfield(mdu,'Filwnd'    ) mdu = rmfield(mdu,'Filwnd'    ) ;end
if isfield(mdu,'Filwsvp'   ) mdu = rmfield(mdu,'Filwsvp'   ) ;end
if isfield(mdu,'Filtem'    ) mdu = rmfield(mdu,'Filtem'    ) ;end
if isfield(mdu,'Fileva'    ) mdu = rmfield(mdu,'Fileva'    ) ;end
if isfield(mdu,'Filbc0'    ) mdu = rmfield(mdu,'Filbc0'    ) ;end
if isfield(mdu,'Filsrc'    ) mdu = rmfield(mdu,'Filsrc'    ) ;end
