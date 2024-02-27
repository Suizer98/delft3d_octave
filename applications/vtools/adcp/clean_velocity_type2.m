function vmag=clean_velocity_type2(vmag)
dummy_v=999.999;
conv=1;
vmag(vmag==dummy_v)=NaN;
vmag=vmag*conv;
end