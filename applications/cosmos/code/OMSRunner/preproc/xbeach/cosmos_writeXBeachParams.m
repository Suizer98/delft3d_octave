function cosmos_writeXBeachParams(hm,m)

tmpdir=hm.tempDir;

model=hm.models(m);

% make param.txt file to run Xbeach
fid = fopen([tmpdir 'params.txt'],'w');
fprintf(fid,'%s\n\n','----------------------------------------------------');
fprintf(fid,'%s\n\n','Grid input');

if strcmpi(model.gridform,'xbeach')
    fprintf(fid,'%s\n',['nx       = ' num2str(model.nX)]);
    fprintf(fid,'%s\n',['ny       = ' num2str(model.nY)]);
    fprintf(fid,'%s\n','xfile    = x.grd');
    fprintf(fid,'%s\n','yfile    = y.grd');
    fprintf(fid,'%s\n',['xori     = ' num2str(model.xOri)]);
    fprintf(fid,'%s\n',['yori     = ' num2str(model.yOri)]);
    fprintf(fid,'%s\n',['alfa     = ' num2str(model.alpha)]);
else
    fprintf(fid,'%s\n',['xyfile    = ' model.name '.grd']);
end
fprintf(fid,'%s\n',['depfile  = ' model.name '.dep']);
fprintf(fid,'%s\n','posdwn    = -1');
fprintf(fid,'%s\n','thetanaut = 0');
fprintf(fid,'%s\n','thetamin  = -40');
fprintf(fid,'%s\n','thetamax  = 40');
fprintf(fid,'%s\n','dtheta    = 10');
fprintf(fid,'%s\n','vardx     = 1');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Numerics input');
fprintf(fid,'%s\n','CFL      = 0.8');
fprintf(fid,'%s\n','eps      = 0.01');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Time input');
fprintf(fid,'%s\n','tstart   = 0.');
fprintf(fid,'%s\n',['tstop    = ' num2str(model.runTime*60)]);
fprintf(fid,'%s\n','taper	 = 100');
fprintf(fid,'%s\n',['tintg    = ' num2str(model.mapTimeStep*60)]);
fprintf(fid,'%s\n',['tintm    = ' num2str(model.mapTimeStep*60)]);
fprintf(fid,'%s\n','tintp    = 60');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','General constants');
fprintf(fid,'%s\n','rho      = 1025');
fprintf(fid,'%s\n','g        = 9.81');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Boundary condition options');
fprintf(fid,'%s\n','zs0file  = tide.txt');
fprintf(fid,'%s\n','tideloc  = 1');
fprintf(fid,'%s\n','zs0      = 0');
fprintf(fid,'%s\n','paulrevere = 0');
fprintf(fid,'%s\n','instat   = 5');
fprintf(fid,'%s\n','leftwave = 1');
fprintf(fid,'%s\n','rightwave = 1');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Wave calculation options');
fprintf(fid,'%s\n','break    = 1');
fprintf(fid,'%s\n','roller   = 1');
fprintf(fid,'%s\n','beta     = 0.1');
fprintf(fid,'%s\n','refl 	 = 0');
fprintf(fid,'%s\n','gamma    = 0.45');
fprintf(fid,'%s\n','delta    = 0.0 ');
fprintf(fid,'%s\n','n        = 10.');
fprintf(fid,'%s\n','bcfile   = waves.txt');
fprintf(fid,'%s\n','front    = 0');
fprintf(fid,'%s\n','snel     = 1');
fprintf(fid,'%s\n','oldwbc   = 0');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Flow calculation options');
fprintf(fid,'%s\n','nuh      = 0.1');
fprintf(fid,'%s\n','nuhfac   = 1.0');
fprintf(fid,'%s\n','C        = 55.');
fprintf(fid,'%s\n','umin     = 0.01');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Sediment transport calculation options');
fprintf(fid,'%s\n','facua    = 0.10');
fprintf(fid,'%s\n','D50      = 0.0002');
fprintf(fid,'%s\n','D90      = 0.0003');
fprintf(fid,'%s\n','ngd      = 1');
fprintf(fid,'%s\n','nd       = 30');
fprintf(fid,'%s\n','struct   = 0');
fprintf(fid,'%s\n','sedtrans = 1');
fprintf(fid,'%s\n','sourcesink = 0');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Morphological calculation options');
fprintf(fid,'%s\n',['morfac   = ' num2str(model.morFac)]);
fprintf(fid,'%s\n','morstart = 3600');
fprintf(fid,'%s\n','wetslp   = 0.15');
fprintf(fid,'%s\n','morphology = 1');
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n','Output options');
fprintf(fid,'%s\n','nglobalvar = 3');
fprintf(fid,'%s\n','zs');
fprintf(fid,'%s\n','zb');
fprintf(fid,'%s\n','wetz');
fprintf(fid,'%s\n','nmeanvar = 6');
fprintf(fid,'%s\n','H');
fprintf(fid,'%s\n','thetamean');
fprintf(fid,'%s\n','uu');
fprintf(fid,'%s\n','vv');
fprintf(fid,'%s\n','DR');
fprintf(fid,'%s\n','zs');
fclose(fid);

