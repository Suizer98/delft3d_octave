function delft3d_part_trk_3d(varargin)
%DELFT3D_PART_TRK_3D   visualize delft3d particle tracks in 3D
%
%   Example 1: launche GUI
%
%      delft3d_io_part_trk_3d
%
%   Example 2: command line
%
%      delft3d_io_part_trk_3d('trk-cont-release03.dat','axis',[80e3 150e3 460e3 500e3 -5 0])
%
%See also: vs_use

OPT.axis = [80e3 150e3 460e3 500e3 -5 0];
OPT.axis = [];

%% filename

   if ~odd(nargin)
   
     [trkname, trkpath, trkfilter] = uigetfile( ...
        {'trk*.dat', 'Delft3D-PART particle tracks (trk*.dat)'; ...
         '*.*'     , 'All Files                    (*.*)'}, ...
         'Delft3D-PART tracks file');
         
         trkfile = [trkpath,trkname];
         
         nextarg = 1;
   else
         trkfile = varargin{1};
         
         nextarg = 2;
   
   end

   OPT = setproperty(OPT,varargin{nextarg:end});

%% open tracks

   H = vs_use(trkfile);

%% inquire tracks

   %vs_disp(H)

%% process tracks

   T = vs_time(H);

for it= 1:(T.nt_storage)

   disp(['plotting timestep ',num2str(it),' / ',num2str(T.nt_storage)])

%% load

   D.x  = vs_get(H,'trk-series',{it},'XYZTRK',{1 0},'quiet');
   D.y  = vs_get(H,'trk-series',{it},'XYZTRK',{2 0},'quiet');
   D.z  = vs_get(H,'trk-series',{it},'XYZTRK',{3 0},'quiet');

%% plot

   axes(gca)% bring fiufure to foreground
   
   plot3  (D.x,D.y,D.z,'.')
   daspect([1 1 .0001])
   title  (datestr(T.datenum(it),31))
   grid    on
   hold    off
   tickmap('xy')
   axis tight
 % make plot area grow with spreading of particles
 % best would be to get maximum extent before time loop
   if ~isempty(OPT.axis)
      axis([OPT.axis])
   else
   if  it > 1
      axis([min([ax(1) xlim1(1)]) ...
            max([ax(2) xlim1(2)]) ...
            min([ax(3) ylim1(1)]) ...
            max([ax(4) ylim1(2)])])
   end
   end
   ax = axis;
   view   (40,40)
   pause(0.1)
 
end   