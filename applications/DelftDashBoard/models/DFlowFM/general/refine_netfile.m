function refine_netfile(fnamein,fnameout,xyzfile,nrref,hmin,dtmax,directional,outsidecell,connect,maxlevel,drypointsfile,exedir)
% Refines FM grid based on Courant numbers
%
% e.g.
%
% fnamein='2d_net.nc';             % input netcdf file
% fnameout='2d_net_refined.nc';    % output netcdf file
% xyzfile='manila.xyz';            % sample file
% nrref=3;                         % number of refinement steps
% 
% hmin=0.001;
% dtmax=120;
% directional=0;
% outsidecell=0;
% connect=0;
% maxlevel=1;
% 
% refine_netfile(fnamein,fnameout,xyzfile,nrref,hmin,dtmax,directional,outsidecell,connect,maxlevel);
%exedir='d:\programs\dflowfm\2.05.04_60632\x64\dflowfm\bin\';


copyfile(fnamein,'TMP_net.nc');
for iref=1:nrref

    str=[exedir filesep 'dflowfm\bin\dflowfm-cli.exe '];
    str=[str '--refine:hmin=' num2str(hmin) ':'];
    str=[str 'dtmax=' num2str(dtmax) ':'];
    str=[str 'directional=' num2str(directional) ':'];
    str=[str 'outsidecell=' num2str(outsidecell) ':'];
    str=[str 'connect=' num2str(connect) ':'];
    str=[str 'maxlevel=' num2str(maxlevel)];
    if ~isempty(drypointsfile)
        str=[str ':drypointsfile=' drypointsfile ' '];
    else
        str=[str ' '];
    end
    str=[str 'TMP_net.nc' ' '];
    str=[str xyzfile];
    
    fid=fopen('refine.bat','wt');
    fprintf(fid,'%s\n',['set fmdir=' exedir 'share\bin\']);
    fprintf(fid,'%s\n','set PATH=%fmdir%;%PATH%');
    fprintf(fid,'%s\n',str);
    fclose(fid);
    
    system('call refine.bat');
%    system(str);
    movefile('out_net.nc','TMP_net.nc');
end
movefile('TMP_net.nc',fnameout);
