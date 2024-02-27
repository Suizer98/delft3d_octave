function hurrywave_write_binary_inputs(z0,msk,bindepfile,binmskfile)

% Writes binary input files for HurryWave

% Depth file
if ~isempty(bindepfile)
    % Depth file
    fid=fopen(bindepfile,'w');
    fwrite(fid,z0,'real*4');
    fclose(fid);
end

% Mask file
fid=fopen(binmskfile,'w');
fwrite(fid,msk,'integer*1');
fclose(fid);
