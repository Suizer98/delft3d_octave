function sfincs_write_ascii_inputs(z,msk,ascdepfile,ascmskfile)

% Writes ascii input files for SFINCS
    
% Depth file
z(isnan(z))=-999;
dlmwrite(ascdepfile,z,'delimiter',' ','precision','%8.2f');

% Mask file
dlmwrite(ascmskfile,msk,'delimiter',' ','precision','%i');
