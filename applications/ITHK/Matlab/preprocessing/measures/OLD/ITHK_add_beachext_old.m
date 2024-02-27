%function ITHK_add_beachext(lat,lon,measureMag,timeSpan,inputDir,outputDir,variantName)
function S = ITHK_add_beachext(S,ii)

%% get relevant info from struct
lat = S.beachextension(ii).lat;
lon = S.beachextension(ii).lon;

%% convert coordinates
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
[MDAdata_ORIG]=ITHK_readMDA('BASIS_ORIG.MDA');

%% calculate coastline extension & put into MDAfile
% Obtain new Y1 values and write to MDAfile (be sure that BASIS.MDA and BASIS_ORIG.MDA have same number of gridcells)
XYref = [MDAdata.Xcoast MDAdata.Ycoast];
XYcoast = [x' y'];
[Y1,idY1,Xcoast_new,Ycoast_new,Xcoast_old,Ycoast_old] = ITHK_fitCoastlineOnReferenceline(XYref,XYcoast);
Y1_new = MDAdata.Y1i;
Y1_new(idY1) = MDAdata.Y1i(idY1)+Y1;
MDAdata.nrgridcells=MDAdata.Xi.*0+1;MDAdata.nrgridcells(1)=0;
ITHK_writeMDA2('BASIS.MDA',[MDAdata.Xi MDAdata.Yi],Y1_new,[],MDAdata.nrgridcells);
ITHK_writeMDA2('BASIS_ORIG.MDA',[MDAdata_ORIG.Xi MDAdata_ORIG.Yi],MDAdata_ORIG.Y1i,[],MDAdata.nrgridcells);

% % Put info in struct
% S.beachextension(ii).idY1 = idY1;
% S.beachextension(ii).Xcoast_new = Xcoast_new;
% S.beachextension(ii).Ycoast_new = Ycoast_new;
% S.beachextension(ii).Xcoast_old = Xcoast_old;
% S.beachextension(ii).Ycoast_old = Ycoast_old;