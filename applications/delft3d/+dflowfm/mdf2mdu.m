function varargout = mdf2mdu(varargin)
%MDF2MDU   convert Delft3D-flow model input to D-Flow FM model input
%
%   dflowfm.mdf2mdu(<keyword,value>)
%
% Example:
%
%  OPT.mdf      = 'dcsm98a.mdf';
%  OPT.pli_test = 'dcsm98_tst.pli';
%  OPT.bnd      = 'dcsm98_dflowfm.bnd'; % adapted *.bnd that overrides *.bnd without pli information in *.mdf
%                                       % 2 extra columns: 
%                                       % 1) name of *.pli, 
%                                       % 2) sequence number within segment: make sure ends meets
%  
%  dflowfm.mdf2mdu(OPT)
%
%See also: dflowfm, delft3d

% TO DO: allow for both bca (astro) and bct (setup), FLOW can already handle that, dflowfm not yet
% TO DO: rewrite grd as netCDF
% TO DO: write mdu too

%% specify

  OPT.mdf      = ''; % *.mdf
  OPT.bnd      = ''; % *.bnd, overrides *.bnd without pli information in *.mdf
  OPT.ext      = 'tst.ext';
  OPT.pli_test = ''; % *.pli
  OPT.ncfile   = '';
  OPT.debug    = 1;
  OPT.extend   = 0.01; % extend pli end-points a bit by fraction of cell size to ensure a crossing with boundary sticks
  
   OPT = setproperty(OPT,varargin{:});
   
   if nargin==0
      varargout = {OPT};
      return
   end
  
%% read delft3d-flow input

   MDF      = delft3d_io_mdf('read',OPT.mdf);
   GRD      = delft3d_io_grd('read',MDF.keywords.filcco);
   DEP      = delft3d_io_dep('read',MDF.keywords.fildep,GRD,'dpsopt',MDF.keywords.dpsopt);
   BND      = delft3d_io_bnd('read',MDF.keywords.filbnd,GRD);

   if     isempty(MDF.keywords.filbca)
   if    ~isempty(MDF.keywords.filana)
      MDF.keywords.filbca = MDF.keywords.filana;
   end
   end

   if     ~isempty(MDF.keywords.filbca)
  [BCA,BND] = delft3d_io_bca('read',MDF.keywords.filbca,BND);
   OPT.typ  = 'cmp'; % 'tim' for time series or 'cmp' for bca
   elseif ~isempty(MDF.keywords.filbct)
    if exist([filename(MDF.keywords.filbct),'.mat'])
    BCT      = load          (filename(MDF.keywords.filbct));
    else
    BCT      = bct_io        ('read',         MDF.keywords.filbct);
    end
   OPT.typ  = 'tim'; % 'tim' for time series or 'cmp' for bca
   end
   BND      = delft3d_io_bnd('read',OPT.bnd,GRD); % added reading optional, undocumented pli_name and pli_nr
   
   if OPT.debug
      grid_plot(GRD.cor.x ,GRD.cor.y ,'k','linewidth',2)
      hold on
      grid_plot(GRD.cen.x ,GRD.cen.y ,'b-','linewidth',1)
      grid_plot(GRD.cend.x,GRD.cend.y,'g:')
      plot(BND.x',BND.y','r-*','linewidth',2)
      for i=1:BND.NTables
      text(mean(BND.x(i,:)),mean(BND.y(i,:)),[BND.DATA(i).name])
      end
      axis equal
   end
   
   P.x = reshape(BND.x',[1 prod(size(BND.x))]);
   P.y = reshape(BND.y',[1 prod(size(BND.y))]);
   landboundary('write',OPT.pli_test,P.x,P.y)
   
%% rewrite dep
   
   if ~isempty(OPT.ncfile)
      N.x = nc_varget (OPT.ncfile,'NetNode_x');
      N.y = nc_varget (OPT.ncfile,'NetNode_y');
  %   N.z = nc_varget (OPT.ncfile,'NetNode_z');
      N.z = zeros(size(N.x)) + -999;
      
      % fill holes with nearest sample (best if original grid was also at corners and this simply unstructured version of the structure grid)
      
      mask = N.z==-999;
      N.z(mask)=nan;
      if OPT.debug;scatter(N.x,N.y,5,N.z,'.');end
      DEP.cor.mask = ~isnan(DEP.cor.dep);
      N.z = griddata(DEP.cor.x(DEP.cor.mask),DEP.cor.y(DEP.cor.mask),-DEP.cor.dep(DEP.cor.mask),N.x,N.y,'nearest');
      hold on
      if OPT.debug;scatter(N.x,N.y,5,N.z,'o');end
      copyfile(OPT.ncfile,[filename(OPT.ncfile),'_filled.nc'])
      nc_varput([filename(OPT.ncfile),'_filled.nc'],'NetNode_z',N.z);
   end

%% save dflowfm-pli
%  make lots of separate polygons and link all polygons

   if OPT.debug
      fid = fopen([filename(OPT.mdf),'_debug.pli'],'w');
      fprintf(fid,'BLOCK\n');
      fprintf(fid,'%d %d\n',2*5,2);%BND.NTables,2);
      if     ~isempty(MDF.keywords.filbca)
         for i=1:BND.NTables
            fprintf(fid,'%10.3f %10.3f ''%s''\n',BND.x(i,1),BND.y(i,1),BND.DATA(i).labelA);
            fprintf(fid,'%10.3f %10.3f ''%s''\n',BND.x(i,2),BND.y(i,2),BND.DATA(i).labelB);
         end
      elseif ~isempty(MDF.keywords.filbct)
      % find all unique(BND.DATA(1).labelA) and loop them
      % find all unique(BND.DATA(1).labelB) within unique(BND.DATA(1).labelA) and loop them
         for i=1:BND.NTables
            fprintf(fid,'%10.3f %10.3f ''%s''\n',BND.x(i,1),BND.y(i,1),['''',BCT.Table(i).Name,'''',', ''',BCT.Table(i).Location,''', ''',BCT.Table(i).Location,',''A''']);
            fprintf(fid,'%10.3f %10.3f ''%s''\n',BND.x(i,2),BND.y(i,2),['''',BCT.Table(i).Name,'''',', ''',BCT.Table(i).Location,''', ''',BCT.Table(i).Location,',''B''']);
            % write BCT to *.tim
         end
      end
      fclose(fid);
   end

%% make polygon files pli as unsupportedly defined BND
%  find all items per element

pli.names = unique({BND.DATA(:).pli_name});

for ipli = 1:length(pli.names)
   
   pli_name = pli.names{ipli};
   
   i = 0;
   pli.ind{ipli} = [];
   pli.nrs{ipli} = [];
   pli.txt{ipli} = {};
   
   for i=1:length(BND.DATA)
   
      if strcmpi(BND.DATA(i).pli_name,pli_name)
      
      pli.ind{ipli}(end+1) = i;
      pli.nrs{ipli}(end+1) = BND.DATA(i).pli_nr;
      pli.txt{ipli}{end+1} = BND.DATA(i).name;

      end
   
   end
   
  [pli.nrs{ipli},shuffle]=sort(pli.nrs{ipli});
   pli.ind{ipli} = pli.ind{ipli}(shuffle);
   pli.txt{ipli} = {pli.txt{ipli}{shuffle}};
   
   % allow for reversing each segment
   pli.x{ipli} = BND.x(pli.ind{ipli},:);
   pli.y{ipli} = BND.y(pli.ind{ipli},:);
   
   dx = pli.x{ipli}(end) - pli.x{ipli}(end-1);pli.x{ipli}(end) = pli.x{ipli}(end) + dx.*OPT.extend;
   dy = pli.y{ipli}(end) - pli.y{ipli}(end-1);pli.y{ipli}(end) = pli.y{ipli}(end) + dy.*OPT.extend;

   dx = pli.x{ipli}(  1) - pli.x{ipli}(    2);pli.x{ipli}(  1) = pli.x{ipli}(  1) + dx.*OPT.extend;
   dy = pli.y{ipli}(  1) - pli.y{ipli}(    2);pli.y{ipli}(  1) = pli.y{ipli}(  1) + dy.*OPT.extend;
   
   fid = fopen(pli.names{ipli},'w');
   fprintf(fid,'%s\n',mkvar(pli.names{ipli}));
   n = length(pli.x{ipli});
   fprintf(fid,'%d %d\n',n*2,2);
   for i=1:n
      for j=1:2
      c   = (i-1)*2+j;
      fil = [filename(pli.names{ipli}),'_',num2str(c,'%0.4d'),'.',OPT.typ];
      
      if strmatch(OPT.typ,'tim')
      
         for itab=1:length(BCT.Table)
           if strcmpi(BCT.Table(itab).Location,BND.DATA(pli.ind{ipli}(i)).name)
              ind = itab;
              break
           end
         end
         disp([fil ' - ' num2str(ind),' - ',BCT.Table(ind).Name])
         
         dat =  BCT.Table(ind).Data(:,[1 (j+1)]);
        %dat(:,1) = dat(:,1);% minutes
         
         % The *.tim files contain two koloms: minutes <whitespace> waterlevel.
         % E.g.:
         % 0.     7.0
         % 60.    5.0
         % 120.   3.0
         % 9999.  3.0   
         
         txt = ['''tim',filesep,fil,''''];
         mkdir('tim')
         fprintf(fid,'%f %f %s\n',pli.x{ipli}(i,j),pli.y{ipli}(i,j),txt); % x,y, <yet unused name of associated data file>
         save(['tim' filesep fil],'-ascii','dat')
         
      elseif strmatch(OPT.typ,'cmp')
      
         txt = ['''cmp',filesep,fil,''''];
         mkdir('cmp')
         fprintf(fid,'%f %f %s\n',pli.x{ipli}(i,j),pli.y{ipli}(i,j),txt); % x,y, <yet unused name of associated data file>
         fid(end+1) = fopen(['cmp' filesep fil],'w');
         
         fprintf(fid(end),'* Delft3D-FLOW boundary segment name: %s\n' ,BND.DATA(i).name);
         if j==1
         fprintf(fid(end),'* Delft3D-FLOW boundary segment label: %s\n',BND.DATA(i).labelA);
         else
         fprintf(fid(end),'* %s\n',BND.DATA(i).labelB);
         end
         
         fprintf(fid(end),'%s\n','* COLUMNN=3');
         fprintf(fid(end),'%s\n','* COLUMN1=Period (min) or Astronomical Componentname');
         fprintf(fid(end),'%s\n','* COLUMN2=Amplitude (m)');
         fprintf(fid(end),'%s\n','* COLUMN3=Phase (deg)');
        %fprintf(fid,'%s\n','0.0           0.000         0.0');
         for icomp=1:length(BCA.DATA(i).names)
         fprintf(fid(end),'%12s %10.3g %10.3g\n',...
                            BCA.DATA(i).names{icomp},...
                            BCA.DATA(i).amp(icomp),...
                            BCA.DATA(i).phi(icomp));
         end % icomp
         fclose(fid(end));
         fid(end) = [];
      
      end % typ
      
      end % j
      
   end % i
   
   fclose(fid);

end % ipli

%% save test dflowfm *.ext

fid = fopen([OPT.ext],'w');

   fprintf(fid,'%s\n','* QUANTITY    : waterlevelbnd, velocitybnd, dischargebnd, tangentialvelocitybnd, normalvelocitybnd  filetype=9         method=2,3');
   fprintf(fid,'%s\n','*             : salinitybnd                                                                         filetype=9         method=2,3');
   fprintf(fid,'%s\n','*             : lowergatelevel, damlevel                                                            filetype=9         method=2,3');
   fprintf(fid,'%s\n','*             : frictioncoefficient, horizontaleddyviscositycoefficient, advectiontype              filetype=4,10      method=4');
   fprintf(fid,'%s\n','*             : initialwaterlevel, initialsalinity                                                  filetype=4,10      method=4');
   fprintf(fid,'%s\n','*             : windx, windy, windxy, rain, atmosphericpressure                                     filetype=1,2,4,7,8 method=1,2,3');
   fprintf(fid,'%s\n','*');
   fprintf(fid,'%s\n','* kx = Vectormax = Nr of variables specified on the same time/space frame. Eg. Wind magnitude,direction: kx = 2');
   fprintf(fid,'%s\n','* FILETYPE=1  : uniform              kx = 1 value               1 dim array      uni');
   fprintf(fid,'%s\n','* FILETYPE=2  : unimagdir            kx = 2 values              1 dim array,     uni mag/dir transf to u,v, in index 1,2');
   fprintf(fid,'%s\n','* FILETYPE=3  : svwp                 kx = 3 fields  u,v,p       3 dim array      nointerpolation');
   fprintf(fid,'%s\n','* FILETYPE=4  : arcinfo              kx = 1 field               2 dim array      bilin/direct');
   fprintf(fid,'%s\n','* FILETYPE=5  : spiderweb            kx = 3 fields              3 dim array      bilin/spw');
   fprintf(fid,'%s\n','* FILETYPE=6  : curvi                kx = ?                                      bilin/findnm');
   fprintf(fid,'%s\n','* FILETYPE=7  : triangulation        kx = 1 field               1 dim array      triangulation');
   fprintf(fid,'%s\n','* FILETYPE=8  : triangulation_magdir kx = 2 fields consisting of Filetype=2      triangulation in (wind) stations');
   fprintf(fid,'%s\n','* FILETYPE=9  : poly_tim             kx = 1 field  consisting of Filetype=1      line interpolation in (boundary) stations');
   fprintf(fid,'%s\n','* FILETYPE=10 : inside_polygon       kx = 1 field                                uniform value inside polygon for INITIAL fields');

   fprintf(fid,'%s\n','*');
   fprintf(fid,'%s\n','* METHOD  =0  : provider just updates, another provider that pointers to this one does the actual interpolation');
   fprintf(fid,'%s\n','*         =1  : intp space and time (getval) keep  2 meteofields in memory');
   fprintf(fid,'%s\n','*         =2  : first intp space (update), next intp. time (getval) keep 2 flowfields in memory');
   fprintf(fid,'%s\n','*         =3  : save weightfactors, intp space and time (getval),   keep 2 pointer- and weight sets in memory');
   fprintf(fid,'%s\n','*         =4  : only spatial interpolation');
   fprintf(fid,'%s\n','*');
   fprintf(fid,'%s\n','* OPERAND =+  : Add');
   fprintf(fid,'%s\n','*         =O  : Override');
   fprintf(fid,'%s\n','*');
   fprintf(fid,'%s\n','* VALUE   =   : Offset value for this provider');
   fprintf(fid,'%s\n','*');
   fprintf(fid,'%s\n','* FACTOR  =   : Conversion factor for this provider');
   fprintf(fid,'%s\n','*');
   fprintf(fid,'%s\n','**************************************************************************************************************');

   for ipli=1:length(pli.names)
   
      fprintf(fid,'%s\n'  ,'QUANTITY=waterlevelbnd');
      fprintf(fid,'%s%s\n','FILENAME=',pli.names{ipli});
      fprintf(fid,'%s\n'  ,'FILETYPE=9');
      fprintf(fid,'%s\n'  ,'METHOD=2');
      fprintf(fid,'%s\n'  ,'OPERAND=O');
      fprintf(fid,'\n');
   
   end
   
fclose(fid)
