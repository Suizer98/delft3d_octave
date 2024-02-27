function D = jarkus_raaien(varargin)
%JARKUS_RAAIEN   returns data of all Rijkswaterstaat Jarkus transects
%
%   R = jarkus_raaien()
%
%See also: jarkus_kustvak

%% Keywords

   OPT.plot = 0;
   OPT.vc   = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland.nc'; % vector coastline
   
   OPT = setproperty(OPT,varargin{:});

%% load

    fid  = fopen([fileparts(mfilename('fullpath')),filesep,'JARKUS_raaien.txt'], 'r');
    data = textscan(fid, '%n %n %n %n %n', 'headerlines', 1);
    fclose(fid);
    
    %Kustvak	Metrering	X-coordinaat	Y-coordinaat	Raaihoek, in .01 graden

    D.kustvak       = data{1};      % see rws_kustvak
    D.metrering     = data{2};      % in decameter
    D.x             = data{3}./100; % in cm, make m 
    D.y             = data{4}./100; % in cm, make m
    D.angle         = data{5}./100; % in .01 graden, make degrees
   [D.lon,D.lat]    = convertCoordinates(D.x,D.y,'CS1.code',28992,'CS2.code',4326);
    
%% plot

   if OPT.plot
      colormap(jet(17))
      caxis   ([0 17])
      plotc   (D.lon,D.lat,D.kustvak)
      [ax, h] = colorbarwithtitle('vak',[.5:16.5]);
      set    (ax,'YTickLabel',rws_kustvak(1:17))
      axis equal
      try
      L.lon = nc_varget(OPT.vc,'lon');
      L.lat = nc_varget(OPT.vc,'lat');
      hold on
      plot(L.lon,L.lat,'k-')
      end
      axislat
      tickmap('ll')
   end