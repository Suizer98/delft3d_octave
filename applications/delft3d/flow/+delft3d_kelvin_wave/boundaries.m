function varargout = boundaries(G,varargin)
%delft3d_kelvin_wave.boundaries  specificy open boundary segments for delft3d_kelvin_wave_grids
%
% delft3d_kelvin_wave_boundaries(G)
% delft3d_kelvin_wave_boundaries(G,IN)
% delft3d_kelvin_wave_boundaries(G,IN,INskip)
% delft3d_kelvin_wave_boundaries(G,IN,INskip,vert_profile)
%
% [BND]     = delft3d_kelvin_wave_boundaries(...)
% [BND,bnd] = delft3d_kelvin_wave_boundaries(...)
%
%
% where 
% - BND is the struct that can be written to file directly using
%   delft3d_io_bnd 
% - bnd is a help struct containing only m and n positions
%
% where IN and INskip look like this:
%
%   IN.names              = {'north'  ,'west'   ,'south'  };
%   IN.positions          = {'nmax'   ,'mmin'   ,'nmin'   }; 
%   IN.bndtype            = {L.bnd(1) ,L.bnd(3) ,L.bnd(5) }; % water level, riemann, current, neumann, dischagre
%   IN.datatype           = {'T'      ,'T'      ,'T'      }; % time serries, harmonic, astronomic
%   
%   INskip.names          = {'north'       ,'west','south'       };
%   INskip.positions      = {'nmax'        ,'mmin','nmin'        };
%   INskip.bndtype        = {[L.bnd(2),'X'],'XX'  ,[L.bnd(4),'X']};
%   INskip.datatype       = {'TT'          ,'TT'  ,'TT'          };
%   INskip.skip           = {[4 3]         ,[0 0] ,[4 3]         }; % make at least 1 to avoid boundary segment with lenght 0
%
%   
% and means this:
%                                            
%                     skip{isides}(1)
%                         skip{isides}(2)
%                     +-----------------+           
%     skip{isides}(2) |     N north     | skip{isides}(2)
%                     |                 |           
%                     |                 |           
%                     |                 |           
%                     |W               E|           
%                     |                 |           
%                     |west         east|           
%                     |                 |           
%                     |                 |           
%                     |                 |           
%                     |                 |           
%     skip{isides}(1) |     S south     | skip{isides}(1)      
%                     +-----------------+           
%                     skip{isides}(1)
%                         skip{isides}(2)
%                                                
%
%
% !!!!!!!!!! THERE CAN BE ONLY 200 BOUNDARIES IN DELFT3D !!!!!!!!!!
%
%See also: delft3d_kelvin_wave

% G.J. de Boer, Nov 2005
  
   bndlayout     = 1;
   
   datatype      = 'T';

   vert_profile  = 'uniform'; % 'Uniform' '3d-profile' 'Logarithmic'

   dbnd          = 2;
   dbnds         = [dbnd   ,dbnd   ,dbnd  ,dbnd  ];

   %% physical open boundary type
   %  Z water level
   %  R riemann
   %  C normal velocity
   %  N neumann
   %  X closed (no boundary)

   %% time specification of open boundary data
   %  T timeseries
   %  A astronomical
   %  H harmonic

   names          = {'north','south','west','east'};
   positions      = {'nmax' ,'nmin' ,'mmin','mmax'};
   bndtype        = {'R' ,'R' ,'Z' ,'X' };
   datatype       = {'T','T','T','T'};
		  
   names_skip     = {'north','south','west','east'};
   positions_skip = {'nmax' ,'nmin' ,'mmin','mmax'};
   bndtype_skip   = {'ZX','ZX','XX','XX'};
   datatype_skip  = {'TT','TT','TT','TT'};
   		  
   skip           = {[0 0],[0 0],[0 0],[0 0]};

   if nargin>1
      IN     = varargin{1};
   end
   if nargin>2
      INskip = varargin{2};
   end
   if nargin>3
      vert_profile = varargin{3};
   end

   if isfield(IN,'bndtype'  ) & ...
      isfield(IN,'names'    ) & ...
      isfield(IN,'positions') & ...
      isfield(IN,'datatype' )
      bndtype   = IN.bndtype;
      names     = IN.names;
      positions = IN.positions;
      datatype  = IN.datatype;
   end
   
   if isfield(INskip,'bndtype'  ) & ...
      isfield(INskip,'names'    ) & ...
      isfield(INskip,'positions')  & ...
      isfield(INskip,'skip'     )  & ...
      isfield(INskip,'datatype' )
      skip           = INskip.skip;
      bndtype_skip   = INskip.bndtype;
      names_skip     = INskip.names;
      positions_skip = INskip.positions;
      datatype_skip  = INskip.datatype;
   end   
   
   nsides        = length(names);

   switch bndlayout
   
     case 1
     
       i    = 0;
       iend = 0;

       for isides=1:nsides

         dbnd     = dbnds(isides);
         bndname  = [names{isides},''];
         bndnameA = [names{isides},'A'];
         bndnameB = [names{isides},'B'];
         
      %% first draw the 'skip' boundaries located at the start and end of each side

         if ~strcmp(bndtype_skip{isides}(1),'X')

           %% West (m=constant)
         
           if strcmp(positions_skip{isides},'mmin');disp('mmin')
               
                bnd.n.(bndnameA) = 1;
                bnd.n.(bndnameB) = 1 + skip{isides};%n_westA_skip;
                                           
                bnd.m.(bndnameA) = 1;
                bnd.m.(bndnameB) = 1;
                
           %% East (m=constant)
           
           elseif strcmp(positions_skip{isides},'mmax');%disp('mmax')
           
                bnd.n.(bndnameA) = 1;
                bnd.n.(bndnameB) = 1 + skip{isides};%n_eastA_skip;
                                           
                bnd.m.(bndnameA) = G.mmax; % dummy row/column already accounted for in G.mmax
                bnd.m.(bndnameB) = G.mmax; % dummy row/column already accounted for in G.mmax

           %% South (n=constant)
           
           elseif strcmp(positions_skip{isides},'nmin');%disp('nmin')
           
              bnd.m.(bndnameA) = 2;
              bnd.m.(bndnameB) = 1 + skip{isides};%m_southA_skip;
                                         
              bnd.n.(bndnameA) = 1;
              bnd.n.(bndnameB) = 1;
	   
           %% North (n=constant)
           
           elseif strcmp(positions_skip{isides},'nmax');%disp('nmax')
           
              bnd.m.(bndnameA) = 2;
              bnd.m.(bndnameB) = 1 + skip{isides};%m_northA_skip;
                                         
              bnd.n.(bndnameA) = G.nmax; % dummy row/column already accounted for in G.mmax
              bnd.n.(bndnameB) = G.nmax; % dummy row/column already accounted for in G.mmax

           end
           
           iend = iend + i;

           for i = 1;
	   
              % disp([bndname,'_',num2str(i,'%0.3d')])
              BND.DATA(i+iend).name              = [bndname,'_',num2str(0,'%0.3d')]; 
              BND.DATA(i+iend).bndtype           = bndtype_skip{isides}(1);
              BND.DATA(i+iend).datatype          = datatype_skip{isides}(1);
              BND.DATA(i+iend).mn                = horzcat(bnd.m.(bndnameA)(i),...
                                                           bnd.n.(bndnameA)(i),...
                                                           bnd.m.(bndnameB)(i),...
                                                           bnd.n.(bndnameB)(i)); % use horzcat as Matlab R13 cannot interpret dynamic fieldnames enclosed within [] brackets
              BND.DATA(i+iend).alfa              = 0.;
              BND.DATA(i+iend).threeD            = 1;
              BND.DATA(i+iend).vert_profile      = vert_profile;
             %BND.DATA(i+iend).origin            = 'skipped_side_segment';
           end   

         end
         
      %% Second draw sides of each boundary, minus the start and end that were skipped.
      %  if the last segment has lenght one, add it to the previous segment

         if ~strcmp(bndtype{isides},'X')
            
           %% West (m=constant)
         
           if strcmp(positions{isides},'mmin')
               
                bnd.n.(bndnameA) = (         skip{isides}(1) + 2:dbnd+1:...
                                    G.nmax-1-skip{isides}(2));
                bnd.n.(bndnameB) = horzcat(bnd.n.(bndnameA)(2:end) - 1,...
                                    G.nmax-1-skip{isides}(2)); % use strcat as Matlab R13 cannot interpret dynamic fieldnames enclosed within [] brackets
                                           
                bnd.m.(bndnameA) = [zeros(size(bnd.n.(bndnameA))) + 1];
                bnd.m.(bndnameB) = [zeros(size(bnd.n.(bndnameA))) + 1];
                
           %% East (m=constant)
           
           elseif strcmp(positions{isides},'mmax')
           
              bnd.n.(bndnameA) = (         skip{isides}(1) + 2:dbnd+1:...
                                  G.nmax-1-skip{isides}(2));
              bnd.n.(bndnameB) = horzcat(bnd.n.(bndnameA)(2:end) - 1,...
                                  G.nmax-1-skip{isides}(2)); % use strcat as Matlab R13 cannot interpret dynamic fieldnames enclosed within [] brackets
                                         
              bnd.m.(bndnameA) = [zeros(size(bnd.n.(bndnameA))) + G.mmax]; % dummy row/column already accounted for in G.mmax
              bnd.m.(bndnameB) = [zeros(size(bnd.n.(bndnameA))) + G.mmax]; % dummy row/column already accounted for in G.mmax
	   
           %% South (n=constant)
           
           elseif strcmp(positions{isides},'nmin')
           
              bnd.m.(bndnameA) = (         skip{isides}(1) + 2:dbnd+1:...
                                  G.mmax-1-skip{isides}(2));
              bnd.m.(bndnameB) = horzcat(bnd.m.(bndnameA)(2:end) - 1,...
                                  G.mmax-1-skip{isides}(2)); % use strcat as Matlab R13 cannot interpret dynamic fieldnames enclosed within [] brackets
                                         
              bnd.n.(bndnameA) = [zeros(size(bnd.m.(bndnameA))) + 1];
              bnd.n.(bndnameB) = [zeros(size(bnd.m.(bndnameA))) + 1];
	   
           %% North (n=constant)
           
           elseif strcmp(positions{isides},'nmax')
           
              bnd.m.(bndnameA) = (         skip{isides}(1) + 2:dbnd+1:...
                                  G.mmax-1-skip{isides}(2));
              bnd.m.(bndnameB) = horzcat(bnd.m.(bndnameA)(2:end) - 1,...
                                  G.mmax-1-skip{isides}(2)); % use strcat as Matlab R13 cannot interpret dynamic fieldnames enclosed within [] brackets
                                         
              bnd.n.(bndnameA) = [zeros(size(bnd.m.(bndnameA))) + G.nmax]; % dummy row/column already accounted for in G.mmax
              bnd.n.(bndnameB) = [zeros(size(bnd.m.(bndnameA))) + G.nmax]; % dummy row/column already accounted for in G.mmax
           end
	     
           iend = iend + i;
           
           for i = 1:prod(size(bnd.m.(bndnameA)));
	   
              % disp([bndname,'_',num2str(i,'%0.3d')])
              BND.DATA(i+iend).name              = [bndname,'_',num2str(i,'%0.3d')]; 
              BND.DATA(i+iend).bndtype           =  bndtype{isides};
              BND.DATA(i+iend).datatype          = datatype{isides};
              BND.DATA(i+iend).mn                = horzcat(bnd.m.(bndnameA)(i),...
                                                           bnd.n.(bndnameA)(i),...
                                                           bnd.m.(bndnameB)(i),...
                                                           bnd.n.(bndnameB)(i)); % use horzcat as Matlab R13 cannot interpret dynamic fieldnames enclosed within [] brackets
              BND.DATA(i+iend).alfa              = 0.;
              BND.DATA(i+iend).threeD            = 1;
              BND.DATA(i+iend).vert_profile      = vert_profile;
             %BND.DATA(i+iend).origin            = 'main_side_segment';
           end
          
        end % if ~strcmp(bndtype{isides},'X')

       end % for isides=1:nsides

     otherwise
           
   end % switch
   
if nargout <2
    varargout = {BND};
elseif nargout==2
    varargout = {BND,bnd};
end

%% EOF