function vdem=sfincs_get_values_for_dem(vsfincs,indices,ndem,mdem)
% Get values from sfincs on dem
vdem=zeros(size(indices));
vdem(vdem==0)=NaN;
vok=find(indices>0);
indices(indices==0)=1;
vtmp=vsfincs(indices);
vdem(vok)=vtmp(vok);
vdem=reshape(vdem,[ndem mdem]);
