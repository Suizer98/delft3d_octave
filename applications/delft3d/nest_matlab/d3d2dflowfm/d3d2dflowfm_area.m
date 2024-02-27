function mdu = d3d2dflowfm_area(mdf,mdu,~)

% d3d2dflowfm_area : Writes AREA information (ANGLAT, ANGLON) to unstruc input files
%                    writes kmax and vertical layer information to unstruc input
%                    files

if simona2mdf_fieldandvalue(mdf,'anglat')
   mdu.geometry.AngLat     = mdf.anglat;
else
   mdu.geometry.AngLat     = -999.999;
end

if simona2mdf_fieldandvalue(mdf,'anglon')
    mdu.geometry.AngLon     = mdf.anglon;
else
    mdu.geometry.AngLon     = 0.;
end

mdu.geometry.BedlevType = 3;

%% Vertical
if mdf.mnkmax(3) > 1
    mdu.geometry.Kmx       = mdf.mnkmax(3);
    mdu.geometry.Layertype = 1;
    if simona2mdf_fieldandvalue(mdf,'zmodel')
        if strcmp(lower(mdf.zmodel),'y')
            mdu.geometry.Layertype      = 2;
        end
    end
end
