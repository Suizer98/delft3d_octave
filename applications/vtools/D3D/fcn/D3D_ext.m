%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17855 $
%$Date: 2022-03-25 14:31:33 +0800 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_ext.m 17855 2022-03-25 06:31:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_ext.m $
%
%

function D3D_ext(simdef)

file_name=simdef.file.ext;

% ************************************************************************************************************** 
% * QUANTITY    : waterlevelbnd, velocitybnd, dischargebnd, tangentialvelocitybnd, normalvelocitybnd  filetype=9         method=2,3
% *             : outflowbnd, neumannbnd, qhbnd                                                       filetype=9         method=2,3
% *             : salinitybnd                                                                         filetype=9         method=2,3
% *             : gateloweredgelevel, damlevel, pump                                                  filetype=9         method=2,3
% *             : frictioncoefficient, horizontaleddyviscositycoefficient, advectiontype, ibotlevtype filetype=4,7,10    method=4
% *             : initialwaterlevel                                                                   filetype=4,7,10,12 method=4,5
% *             : initialtemperature                                                                  filetype=4,7,10,12 method=4,5
% *             : initialsalinity, initialsalinitytop: use initialsalinity for depth-uniform, or
% *             : as bed level value in combination with initialsalinitytop                           filetype=4,7,10    method=4
% *             : initialverticaltemperatureprofile                                                   filetype=9,10      method=
% *             : initialverticalsalinityprofile                                                      filetype=9,10      method=
% *             : windx, windy, windxy, rainfall_mmperday, atmosphericpressure                        filetype=1,2,4,7,8 method=1,2,3
% *             : shiptxy, movingstationtxy                                                           filetype=1         method=1
% *             : discharge_salinity_temperature_sorsin                                               filetype=9         method=1
% *
% * kx = Vectormax = Nr of variables specified on the same time/space frame. Eg. Wind magnitude,direction: kx = 2
% * FILETYPE=1  : uniform              kx = 1 value               1 dim array      uni
% * FILETYPE=2  : unimagdir            kx = 2 values              1 dim array,     uni mag/dir transf to u,v, in index 1,2
% * FILETYPE=3  : svwp                 kx = 3 fields  u,v,p       3 dim array      nointerpolation
% * FILETYPE=4  : arcinfo              kx = 1 field               2 dim array      bilin/direct
% * FILETYPE=5  : spiderweb            kx = 3 fields              3 dim array      bilin/spw
% * FILETYPE=6  : curvi                kx = ?                                      bilin/findnm
% * FILETYPE=7  : triangulation        kx = 1 field               1 dim array      triangulation
% * FILETYPE=8  : triangulation_magdir kx = 2 fields consisting of Filetype=2      triangulation in (wind) stations
% *
% * FILETYPE=9  : polyline             kx = 1 For polyline points i= 1 through N specify boundary signals, either as
% *                                           timeseries or Fourier components or tidal constituents
% *                                           Timeseries are in files *_000i.tim, two columns: time (min)  values
% *                                           Fourier components and or tidal constituents are in files *_000i.cmp, three columns
% *                                           period (min) or constituent name (e.g. M2), amplitude and phase (deg)
% *                                           If no file is specified for a node, its value will be interpolated from surrounding nodes
% *                                           If only one signal file is specified, the boundary gets a uniform signal
% *                                           For a dischargebnd, only one signal file must be specified
% *
% * FILETYPE=10 : inside_polygon       kx = 1 field                                uniform value inside polygon for INITIAL fields
% * FILETYPE=11 : ncgrid               currently not in use
% * FILETYPE=12 : ncflow               kx = 1 field               1 dim array      triangulation
% *
% * METHOD  =0  : provider just updates, another provider that pointers to this one does the actual interpolation
% *         =1  : intp space and time (getval) keep  2 meteofields in memory
% *         =2  : first intp space (update), next intp. time (getval) keep 2 flowfields in memory
% *         =3  : save weightfactors, intp space and time (getval),   keep 2 pointer- and weight sets in memory.
% *         =4  : only spatial, inside polygon
% *         =5  : only spatial, triangulation
% *         =6  : only spatial, averaging
% *         =7  : only spatial, index triangulation
% *         =8  : only spatial, smoothing
% *         =9  : only spatial, internal diffusion
% *         =10 : only initial vertical profiles
% *
% * OPERAND =O  : Override at all points
% *         =+  : Add to previously specified value
% *         =*  : Multiply with previously specified value
% *         =A  : Apply only if no value specified previously (For Initial fields, similar to Quickin preserving best data specified first)
% *         =X  : MAX with prev. spec.
% *         =N  : MIN with prev. spec.
% *
% * AVERAGINGTYPE = 1 : Simple averaging
% *               = 2 : Closest Point
% *               = 3 : Max
% *               = 4 : Min
% *               = 5 : Inverse weight distance
% *               = 6 : Min Abs
% *               = 7 : Kdtree
% *
% * VALUE   =   : Offset value for this provider
% *
% * FACTOR  =   : Conversion factor for this provider
% *
% **************************************************************************************************************


%ext
fid=fopen(file_name,'w');
fprintf(fid,'QUANTITY        =initialvelocityx\n');
fprintf(fid,'FILENAME        =ini_vx.xyz      \n');
fprintf(fid,'FILETYPE        =7               \n');
fprintf(fid,'METHOD          =6               \n');
fprintf(fid,'AVERAGINGTYPE   =2               \n');
fprintf(fid,'OPERAND         =O               \n');
fprintf(fid,'                          \n');
fprintf(fid,'QUANTITY        =initialvelocityy\n');
fprintf(fid,'FILENAME        =ini_vy.xyz      \n');
fprintf(fid,'FILETYPE        =7               \n');
fprintf(fid,'METHOD          =6               \n');
fprintf(fid,'AVERAGINGTYPE   =2               \n');
fprintf(fid,'OPERAND         =O               \n');
fprintf(fid,'                          \n');
fprintf(fid,'QUANTITY        =initialwaterlevel\n');
fprintf(fid,'FILENAME        =%s      \n',simdef.ini.etaw_file);
fprintf(fid,'FILETYPE        =7               \n');
fprintf(fid,'METHOD          =6               \n');
fprintf(fid,'AVERAGINGTYPE   =2               \n');
fprintf(fid,'OPERAND         =O               \n');
fprintf(fid,'                          \n');
fprintf(fid,'QUANTITY        =bedlevel\n');
fprintf(fid,'FILENAME        =%s      \n',simdef.mdf.dep);
fprintf(fid,'FILETYPE        =7               \n');
fprintf(fid,'METHOD          =6               \n');
fprintf(fid,'AVERAGINGTYPE   =2               \n');
fprintf(fid,'OPERAND         =O               \n');

fclose(fid);

end %function