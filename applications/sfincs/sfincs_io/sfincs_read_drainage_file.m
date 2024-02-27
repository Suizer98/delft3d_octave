function drain = sfincs_read_drainage_file(filename)

s=load(filename);

drain(1).length = size(s,1);

for ii=1:drain(1).length
    drain(ii).xsnk = s(ii,1);
    drain(ii).ysnk = s(ii,2);
    drain(ii).xsrc = s(ii,3);
    drain(ii).ysrc = s(ii,4);
    drain(ii).type = s(ii,5);
    drain(ii).par1 = s(ii,6);
    drain(ii).par2 = s(ii,7);
    drain(ii).par3 = s(ii,8);
    drain(ii).par4 = s(ii,9);
    drain(ii).par5 = s(ii,10);   
end

