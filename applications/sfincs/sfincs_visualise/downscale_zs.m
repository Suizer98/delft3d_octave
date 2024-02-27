function [high_zs] = downscale_zs(xg, yg, model_zs, model_zmin, high_x, high_y, hh_criteria,outfile)
% Function that downscales maximum water level to high level terrain
% thanks to Maarten

% Write indices file (this need to be done only once!)
if isfile(outfile)
    [indices,ndem,mdem]=sfincs_read_indices_for_dem(outfile);
else
    sfincs_write_indices_for_dem_providegrid(xg,yg,outfile,high_x,high_y)
    [indices,ndem,mdem]=sfincs_read_indices_for_dem(outfile);
end

% Load sfincs output
VAL                 = squeeze(model_zs);
VAL(isnan(VAL))     = model_zmin(isnan(VAL));
id_dry              = (VAL - model_zmin) < hh_criteria;
VAL(id_dry)         = NaN;
model_zs            = VAL;

% Use indices
high_zs             = sfincs_get_values_for_dem(model_zs,indices,ndem,mdem);
high_hh             = [];

end

