function [stat] = model_skill2(measured, computed, initial)

%% compute skills
zmt     = measured;
zct     = computed;
zit     = initial;

% Adjust size
if size(zmt,1) > 1 &  size(zct,1) == 1
    zct = zct';
elseif size(zmt,2) > 1 &  size(zct,2) == 1
    zct = zct';
end

%% Check NaNs;
id1 = isnan(zmt); 
id2 = isnan(zct);
id3 = isnan(zit);

zmt(id1 | id2 | id3) = [];
zct(id1 | id2 | id3) = [];
zit(id1 | id2 | id3) = [];

% Determine active zone
dz  = max(abs(zmt-zit),abs(zct-zit));
rmsm    = sqrt(mean(zmt.^2));

% Bias
relbias = mean(zct-zmt)/max(rmsm,abs(mean(zmt)));
bias    = mean(zct-zmt);        % computed - measured

% Correlation
r2      = (mean((zct-mean(zct)).*(zmt-mean(zmt)))/(std(zmt)*std(zct))).^2;
rmse    = sqrt(mean((zct-zmt).^2));
urmse   = sqrt(mean((zct-zmt-bias).^2));
mae     = norm(zmt-zct,1) / length(zmt);
sci     = rmse/max(rmsm,abs(mean(zmt)));
umae    = norm( (zmt-zct+bias) ,1) / length(zmt);
urmses  = urmse*(std(zct) - std(zmt)) / abs((std(zct) - std(zmt)));

urmsesn  = urmses /std(zmt);
biasn    = bias/std(zmt);

% mse_p = sum(    (zct-zmt).^2);
% mse_0 = sum(    (zit-zmt).^2);
% bss = 1 - (mse_p/mse_0);

% Bias
mse_p = sum( (zct - zmt).^2 .* 1 );
mse_0 = sum( (zit - zmt).^2 .* 1 );
bss = 1. - (mse_p/mse_0);

% Place in structure
stat = struct;
stat.r2             = r2;
stat.rmse           = rmse;
stat.urmse          = urmse;
stat.mae            = mae;
stat.sci            = sci;
stat.bias           = bias;
stat.relbias     	= relbias;
stat.bss            = bss;
stat.umae           = umae;
stat.urmses         = urmses;
stat.urmsesn        = urmsesn;
stat.biasn          = biasn;
stat.count          = length(zmt);