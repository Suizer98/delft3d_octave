function varargout = Unibest_CLp_read_prn(varargin)
% PRN = Unibest_CLp_read_prn() loads the contents of a  
% UNIBEST *.prn file into struct PRN.
% When no input dialog is given, a pop up window to select  
% a file is called, otherwise the given file is loaded, e.g.:
% PRN = Unibest_CLp_read_prn('c:\UB\results.prn');
%
% [PRN, iostat] = Unibest_CLp_read_prn returns
%  -1   in iostat when reading fails
%   0   when nothing  occured (i.e. when cancel was pressed
%       in pop up window)
%   1   when reading is sucessfull
% Note: the field iostat is also present in the PRN struct.
% 
% PRN struct description:
% -----------------------
%      iostat: 
%     pathstr: 
%        name: 
%         ext: 
%       versn: 
%    fullfile: 
%         CEL.timestep
%         CEL.year
%         CEL.cel:    cel sequence number
%         CEL.Xcoast: global co-ordinate
%         CEL.Ycoast: global co-ordinate
%         CEL.S:      local alongcoast co-ordinate
%         CEL.N:      local crosscoast co-ordinate
%         CEL.N_N0
%         CEL.alfa
%         CEL.source
%         CEL.stored
%         CEL.units

%
%         RAY.timestep
%         RAY.year
%         RAY.ray:    ray sequence number
%         RAY.Xcoast: global co-ordinate
%         RAY.Ycoast: global co-ordinate
%         RAY.S:      local alongcoast co-ordinate
%         RAY.N:      local crosscoast co-ordinate
%         RAY.alfa
%         RAY.transport
%         RAY.vol
%         RAY.units

% This function is part of the WL UCIT toolbox.
% (c) WL | Delft Hydrauylics
% G.J. de Boer, 2004 
         
%% Check number and type of arguments
%% ------------------------------------

   fullprnfilename = [];
   PRN.iostat      = 0; % becomes 1 when succesfull and -1 when fails, stays 0 if open dial;og is cancelled
   
   
   
   if nargin < 1
%           [filename, pathname, filterindex] = uigetfile( ...
%           [filename, pathname] = uigetfile( ...
%           {'*.prn','Unibest CL+ Report (*.prn)'; ...
%            '*.*'  ,'All Files'}, ...
%            'Unibest CL + report file');  
%            fullprnfilename  = [pathname, filename];

           % Het is handig dat niet de hele tijd naar een bepaalde directory hoeft te worden gewandeld
           WorkDir = getINIValue('UCIT.ini','UnibestDir');  
           
           % Selecteer de resultaat file die moet worden getoond
           [name,pat]=uigetfile([WorkDir '*.prn'],'Select file');
           
           % Set de huidige directory als werkdirectory
           if ~isempty(pat) & pat~=0
               setINIValue('UCIT.ini','UnibestDir',pat);
               fullprnfilename  = [pat name];
           end
           
           if name==0
               return
           end
           
           
   else
   
      fullprnfilename = varargin{1};
   
   end


      if ~isstr(fullprnfilename)
         %error('Input must be a string representing a filename');
         %errordlg({'Input must be a string representing a filename'});
         PRN.iostat = 0;
      else
         PRN.iostat = 1;
      end
   
   %% Open the file.
   %% If this returns a -1, we did not open the file 
   %% successfully.
   %% ------------------------------------
   
if PRN.iostat==1

   try

      [PRN.pathstr,...
       PRN.name   ,...
       PRN.ext    ,...
       PRN.versn]   = fileparts(fullprnfilename);
      
      %% File name
      %% ------------------------------------
      
      PRN.fullfile = fullfile (PRN.pathstr,...
                              [PRN.name PRN.ext PRN.versn]);
   
      fid = fopen(PRN.fullfile);
      
      if fid==-1
      
         errordlg({'Unibest CL + *.prn file not found or permission denied: ',...
                   PRN.fullfile},...
                   'Error reading file');
         PRN.iostat = -1;
      
      else
      
         %% Read UNIBEST CL + *.PRN file
         %% ------------------------------------
         
         header    = [];
         dummyline = fgetl(fid);
         header    = strvcat(header, dummyline);
         dummyline = fgetl(fid);
         header    = strvcat(header, dummyline);
         
         nblocks = 0;  
      
         while ~feof(fid)
      
            %% Read one time step
            %% ------------------------------------
            
            cel  = readnextprnblock(fid);
            ray  = readnextprnblock(fid);
            
            cel.cel               = cel.data(1,:);
            cel.Xcoast            = cel.data(2,:); % world co-ordinates
            cel.Ycoast            = cel.data(3,:); % world co-ordinates
            cel.N                 = cel.data(4,:); % normal to coast, wrt base line
            cel.N_N0              = cel.data(5,:); % normal to coast, wrt N0
            cel.source            = cel.data(6,:);
            cel.source            = cel.data(7,:);
            cel.stored            = cel.data(8,:);
            cel                   = rmfield(cel,'data');

            cel.units.timestep    = '[?]';
            cel.units.year        = '[?]';
            cel.units.cel         = '[#]';
            cel.units.Xcoast      = '[m] world co-ordinates';
            cel.units.Ycoast      = '[m] world co-ordinates';
            cel.units.N           = '[m] normal to coast, wrt base line';
            cel.units.N_N0        = '[m] normal to coast, wrt N0';
            cel.units.source      = '[k(m3/y)]';
            cel.units.source      = '[Mm3]';
            cel.units.stored      = '[Mm3]';
            
            ray.ray               = ray.data(1,:);
            ray.S                 = ray.data(2,:); % [m] along coast on baseline
            ray.alfa              = ray.data(3,:); % [deg] co-ordinates (0 = North)
            ray.transport         = ray.data(4,:);
            ray.vol.passed        = ray.data(5,:); % !!! not officially present in header of data block
            ray                   = rmfield(ray,'data');

            ray.units.timestep    = '[?]';
            ray.units.year        = '[?]';
            ray.units.ray         = '[#]';
            ray.units.S           = '[m] along coast on baseline';
            ray.units.alfa        = '[deg] co-ordinates (0 = North)';
            ray.units.transport   = '[k(m3/y)]';
            ray.units.vol.passed  = '[Mm3]'; % !!! not officially present in header of data block
            
            % interpolate cell properties to rays (except 1st and last ray)
            % ------------------------------------
            ray.Xcoast           =  repmat(nan,size(ray.S));
            ray.Xcoast(2:end-1)  = (cel.Xcoast(1:end-1) + cel.Xcoast(2:end))/2; 
            ray.Ycoast           =  repmat(nan,size(ray.S));
            ray.Ycoast(2:end-1)  = (cel.Ycoast(1:end-1) + cel.Ycoast(2:end))/2;
            ray.N                =  repmat(nan,size(ray.S));
            ray.N(2:end-1)       = (cel.N(1:end-1) + cel.N(2:end))/2;
   
            % interpolate ray properties to cells (cell array 1 smaller)
            % ------------------------------------
            cel.alfa             = (ray.alfa(1:end-1) + ray.alfa(2:end))/2;
            cel.S                = (ray.S   (1:end-1) + ray.S   (2:end))/2;
            
            nblocks       = nblocks + 1;
      
            %% Add results one time step to struct for all timesteps
            %% ------------------------------------
      
            PRN.CEL(nblocks) = cel;
            PRN.RAY(nblocks) = ray;
         
         end
   
      end
      
   catch
   
      errordlg({'Unibest CL + *.prn file not found/permission denied/wrong type: ',...
                PRN.fullfile},...
                'Error reading file');
      PRN.iostat = -1;
   
   end
   
end % if PRN.iostat==1

%% Return arguments
%% ------------------------------------

if nargout==1
   varargout = {PRN};
elseif nargout==2
   varargout = {PRN, PRN.iostat};
end


   %% ------------------------------------
   %% ------------------------------------
   %% ---------------EOF------------------
   %% ------------------------------------
   %% ------------------------------------


   %% FUNCTION readnextprnblock
   %% ------------------------------------

   function PRN = readnextprnblock(fid)
   
  %PRN.header   = [];
   dummyline    = fgetl(fid);
  %PRN.header   = strvcat(PRN.header, dummyline);
   
   dataline     = fgetl(fid);
   data         = sscanf(dataline,'%f');
   PRN.timestep = data(1);
   PRN.year     = data(2);

   dummyline    = fgetl(fid);
  %PRN.header   = strvcat(PRN.header, dummyline);
   dummyline    = fgetl(fid);
  %PRN.header   = strvcat(PRN.header, dummyline);
   dummyline    = fgetl(fid);
  %PRN.header   = strvcat(PRN.header, dummyline);

   dataline     = fgetl(fid);
   data         = sscanf(dataline,'%i');
   d.nrow       = data(1);
   d.ncol       = data(2);

   % The beautiful fscanf() option below cannot be used directly 
   % as some dumm programmer decided to put some more dummy
   % columns in the *.prn file than in the header
    
   PRN.data      = fscanf(fid,'%f',Inf);
   d.ncolpresent = prod(size(PRN.data))/d.nrow;
   PRN.data      = reshape(PRN.data,d.ncolpresent,d.nrow);

   %% FUNCTION degN2degunitcirle
   %% ------------------------------------

   function degUC = degN2degunitcirle(degN)
   
   degUC = - degN + 90;