function varargout = run(data, time, mask, varargin)
%RUN wrapper to use DINEOF via memory (without explicit file IO)
%
%    dataf = dineof.run(data, time, mask, <keyword,value>)
%
% where dataf is the filled + smoothed data. The dimensions 
% should be time(t), data(x,<y>,t), mask(x,<y>). Any missing 
% y dimension is permuted before calling dineof.exe. time
% should be in Matlab datenum epoch.
%
%    [dataf,D] = dineof.run(data, time, mask, <keyword,value>)
%
% where optionally struct D with the mean, the spatial & temporal
% EOF modes, the singular values and the exlained variance can be 
% returned. All temporary DINEOF files are deleted afterwards and 
% saved into 1 netCDF file, unless keyword 'cleanup' is set to 0. Note
% that the upcoming DINEOF release will save the EOFs to netCDF itself. 
%
% Note: Use keyword 'sgn' to consistently swap the signs of the most 
% important spatial & temporal modes to be consistent with your hypotheses.
%
% Note: you can appand wgs84-coordinates with keywords 'lon' & 'lat' and
% data units with 'units'.
%
% Example 2D matrices:
%
%   nt      = 14;time    = [1:nt];
%   ny      = 20;
%   nx      = 21;
%  [y,x]    = meshgrid(linspace(-3,3,ny),linspace(-3,3,nx));
%   z       = peaks(x,y);
%   mask    = rand(size(z)) < 1;
%   mask(1:5,1:5) = 0; % land
%
%   for it=1:nt
%     noise  = rand(size(z)).*z./100;
%     clouds = double(rand(size(z)) < 0.95);
%     clouds(clouds==0)=nan;
%     data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
%                   abs(z).*cos(pi.*it./nt) + ...
%                           noise;
%   end
%   
%   [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',1);
%
%See also: dineof, harmanal, netcdf

%   --------------------------------------------------------------------
%   Copyright (C) 2011-2012 Deltares 4 Rijkswaterstaat: Resmon project
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: run.m 12593 2016-03-17 08:37:37Z gerben.deboer.x $
% $Date: 2016-03-17 16:37:37 +0800 (Thu, 17 Mar 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12593 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/+dineof/run.m $
% $Keywords: $

% DINEOF suggestions
% - use ? instead of #, then the syntax is OPeNDAP
% - also use [] for time string
% - make keyword 'output' fully small case

% dineof keywords: order here is important as
% it determines order in init file

   OPT         = dineof.init();
   fldnames    = fieldnames(OPT);
   
   OPT.sgn     = 1;
   OPT.cleanup = 1;
   OPT.debug   = 0;
   OPT.plot    = 1;
   OPT.export  = 1;
   OPT.version = 3; % set > 3 for rev 81 of self-compiled source
   
% user-configurable variable names for EOF netCDF file, default same as suggestions in DINEOF 4.0

   OPT.varname.P      = 'P'     ;
   OPT.varname.mean   = 'mean'  ;
   OPT.varname.lftvec = 'U'; %'lftvec';
   OPT.varname.rghvec = 'V'; %'rghvec';
   OPT.varname.vlsng  = 'vlsng' ;
   OPT.varname.mean   = 'mean' ;
   OPT.varname.varEx  = 'varEx' ;   
   OPT.varname.valc   = 'valc' ;   

% other keywords

   OPT.dataname        = 'data';
   OPT.maskname        = 'mask';
   OPT.timename        = 'time';
   OPT.lonname         = 'lon';
   OPT.latname         = 'lat';

   OPT.ncfile          = ['dummy.nc'];
   OPT.resfile         = ['dummy_filled.nc'];
   OPT.eoffile         = ['dummy_eof.nc'];
   OPT.initfile        = []; % will have same name as eoffile
   OPT.logfile         = []; % will have same name as eoffile
   OPT.units           = '';
   OPT.standard_name   = '';
   OPT.transformFun    = @(x) x;
   OPT.transformFunInv = @(x) x;
   OPT.lon             = [];
   OPT.lat             = [];
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);
    
   if ~(OPT.transformFun(OPT.transformFunInv(1))==1)
      error('transformFunInv(x) is not the inverse of transformFun(x) for x=1')
   end

   OPT.data     = ['[''',OPT.ncfile ,'#',OPT.dataname,''']'];
   OPT.mask     = ['[''',OPT.ncfile ,'#',OPT.maskname,''']'];
   OPT.time     = [ '''',OPT.ncfile ,'#',OPT.timename,'''']; % no brackets !!
   OPT.results  = ['[''',OPT.resfile,'#',OPT.dataname,''']'];
   
   if OPT.version > 3 % DINEOF now writes mode to netCDF
   OPT.EOF_U    = ['[''./DINEOF_diagnostics.nc#U'']'];
   OPT.EOF_V    =  ['''./DINEOF_diagnostics.nc#V'''];
   OPT.EOF_Sigma=  ['''./DINEOF_diagnostics.nc#sigma'''];
   end
   
% NetCDF-3 Classic dummy_eof.nc {
% 
%   dimensions:
%     dim001 = 11 ; // time
%     dim002 = 5 ;  // p
%     dim003 = 13 ; // space1
%     dim004 = 1 ;  // space2
% 
%   variables:
%     // Preference 'PRESERVE_FVD':  false,
%     // dimensions consistent with ncBrowse, not with native MATLAB netcdf package.
%     double V(dim002,dim001), shape = [5 11]
%       :missing_value = 9999 
%     double U(dim002,dim004,dim003), shape = [5 1 13]
%       :missing_value = 9999 
   
   if sum(mask) < OPT.ncv
       error(['Krylov subspace ncv (',num2str(OPT.ncv),') needs to be les than or equal to # active spatial cells (',num2str(sum(mask)),').'])
   end
   
   if isempty(OPT.initfile)
   OPT.initfile = [filepathstrname(OPT.eoffile),'.init'];
   end
   if isempty(OPT.logfile)
   OPT.logfile  = [filepathstrname(OPT.eoffile),'.log'];
   end
   
   dineof.initwrite(OPT,OPT.initfile);

%% make data matrix [M x N] that DINEOF swallows, where M or 
%  N can be 1, but DINEOF will swap dimensions internally in one case

   sz0 = size(data);
   sz  = size(data);
   permuteback = [1 2 3];
   
   if length(sz0)==2
   
     data = permute(data,[1 3 2]);
     mask = mask(:);
     sz   = size(data);
     dim  = 1;
     permuteback = [1 3 2];
     
   elseif length(sz0)==3 & sz0(1)==1

     data = permute(data,[2 1 3]);
     mask = mask(:);
     sz   = size(data);
     dim  = 1;
     permuteback = [2 1 3];

   elseif length(sz0)==3 & sz0(2)==1

     % data already OK
     mask = mask(:);
     sz   = size(data);
     dim  = 1;

   elseif length(sz0)>3
   
      error('only 1D vector and 2D matrix data implemented, no 3D cubes or higher yet.')
      
   else
     dim = 2;
   end
  
   data = OPT.transformFun(data);
   
%% check DINEOF requirements: time(t), data(x,y,t), mask(x,y)

   if ~(sz(3)==length(time))
      whos
      error('data(x,y,:) should have length as time')
   end

   if ~(isequal(sz(1:2),size(mask)))
      whos
      error('data(:,:,t) should have size as mask')
   end

%% Apply mask to data to avoid confusion later on

   mask2 = double(mask);
   mask2(~mask)=nan;
   for it=1:length(time)
       data(:,:,it) = data(:,:,it).*mask2;
   end
   clear mask2

%% write input data

   mode     = netcdf.getConstant('CLOBBER'); % do overwrite existing files
   NCid     = netcdf.create(OPT.ncfile,mode);
   globalID = netcdf.getConstant('NC_GLOBAL');
   
   dimid.time     = netcdf.defDim(NCid,'time' ,sz(end));
   for i=1:length(sz)-1
   dimname = ['space',num2str(i)];
   dimid.space(i) = netcdf.defDim(NCid,dimname,sz(i));
   end
   
   varid.data = netcdf.defVar(NCid,OPT.dataname,'double',[dimid.space dimid.time]); 
   varid.time = netcdf.defVar(NCid,OPT.timename,'float' ,dimid.time); 
   varid.mask = netcdf.defVar(NCid,OPT.maskname,'short' ,dimid.space); 

   netcdf.putAtt(NCid,varid.time,'standard_name','time');
   netcdf.putAtt(NCid,varid.time,'units'        ,'days since 1970-01-01');
   
   netcdf.putAtt(NCid,varid.data,'long_name'    ,'data');
   netcdf.putAtt(NCid,varid.data,'missing_value',9999); % clouds
   netcdf.putAtt(NCid,varid.data,'_FillValue'   ,9999); % clouds
   if ~isempty(OPT.units)
   netcdf.putAtt(NCid,varid.data,'units'        ,OPT.units);
   end
   if ~isempty(OPT.standard_name)
   netcdf.putAtt(NCid,varid.data,'standard_name',OPT.standard_name);
   end
   netcdf.putAtt(NCid,varid.data,'transform_fun','CHECK');

   netcdf.putAtt(NCid,varid.mask,'long_name'    ,'mask');
   netcdf.putAtt(NCid,varid.mask,'flag_values'  ,[0 1]);
   netcdf.putAtt(NCid,varid.mask,'flag_meanings','land ocean');
   
   if ~isempty(OPT.lon) & ~isempty(OPT.lat)
   varid.lon = netcdf.defVar(NCid,OPT.lonname,'double' ,dimid.space); 
   varid.lat = netcdf.defVar(NCid,OPT.latname,'double' ,dimid.space); 

   netcdf.putAtt(NCid,varid.lon,'long_name'    ,'longitude');
   netcdf.putAtt(NCid,varid.lon,'standard_name','longitude');
   netcdf.putAtt(NCid,varid.lon,'units'        ,'degrees_east');

   netcdf.putAtt(NCid,varid.lat,'long_name'    ,'latitude');
   netcdf.putAtt(NCid,varid.lat,'standard_name','latitude');
   netcdf.putAtt(NCid,varid.lat,'units'        ,'degrees_north');
   end   

   netcdf.endDef(NCid,20e3,4,0,4); 

   netcdf.putVar(NCid,varid.data,data);
   netcdf.putVar(NCid,varid.time,time - datenum(1970,1,1));
   netcdf.putVar(NCid,varid.mask,int8(mask));
   
   if ~isempty(OPT.lon) & ~isempty(OPT.lat)
   netcdf.putVar(NCid,varid.lon,OPT.lon);
   netcdf.putVar(NCid,varid.lat,OPT.lat);
   end   
   
   netcdf.close(NCid)
   
   nc_dump(OPT.ncfile,'',[filepathstrname(OPT.ncfile),'.cdl']);

%% call dineof

   copyfile(OPT.ncfile,OPT.resfile)
   ddir = filepathstr(mfilename('fullpath')); 

   if ~exist([ddir, filesep,'dineof.exe'])
   fprintf(2,'%s\n',['To use dineof first download dineof-3.0.zip from'])
   fprintf(2,'%s\n',['http://modb.oce.ulg.ac.be/mediawiki/index.php/DINEOF'])
   fprintf(2,'%s\n',['and extract dineof.exe into'])
   fprintf(2,'%s\n',ddir)
   error('DINEOF')
   end
   
   %% clean up any previous runs
   if exist('meandata.val'    )==2;delete('meandata.val'    );end
   if exist('neofretained.val')==2;delete('neofretained.val');end
   if exist('outputEof.lftvec')==2;delete('outputEof.lftvec');end
   if exist('outputEof.rghvec')==2;delete('outputEof.rghvec');end
   if exist('outputEof.varEx' )==2;delete('outputEof.varEx' );end
   if exist('outputEof.vlsng' )==2;delete('outputEof.vlsng' );end
   if exist('valc.dat'        )==2;delete('valc.dat'        );end
   if exist('valosclast.dat'  )==2;delete('valosclast.dat'  );end
   
   %% run
   disp('Running DINEOF, please wait ...')
   if OPT.version==3
   cmd  = [ddir filesep 'dineof.exe ' OPT.initfile ' > ' OPT.logfile];
   else
   % mingw compiled version
   tmp = getlocalsettings;
   if ~exist([ddir filesep 'dineof.local.exe'],'file')
    copyfile(['c:\MinGW\msys\1.0\home\' tmp.NAME '\dineof\dineof.exe'],...
            [ddir filesep 'dineof.local.exe'])
   end
   cmd  = [ddir filesep 'dineof.local.exe ' OPT.initfile ' > ' OPT.logfile];
   end

   status = system(cmd);
   
   nc_dump(OPT.ncfile,'',[filepathstrname(OPT.resfile),'.cdl']);

if status < 0

   % make dummy matrices with expected size to allow automated plotting of results
   
   S.mean   = nan;
   S.P      = 0;
   S.lftvec = repmat(nan,[size(data,1) 1]);
   S.rghvec = repmat(nan,[size(data,3) 1]);
   S.varEx  = 0;
   S.varLab = {};
   S.vlsng  = 0;
   dataf    = permute(nan.*data,permuteback);;
   
   fprintf(2,'DINEOF failed, dummy matrices returned \n')

   if nargout==1
      varargout = {dataf};
   else
      varargout = {dataf,S};
   end       
   return

else

 if nargout==0

  %% rename output

   movefile('meandata.val'    ,[filepathstrname(OPT.resfile),'_meandata.asc'  ]);
   movefile('neofretained.val',[filepathstrname(OPT.resfile),'_neofretained.asc']);
   movefile('outputEof.lftvec',[filepathstrname(OPT.resfile),'_lftvec.asc'    ]);
   movefile('outputEof.rghvec',[filepathstrname(OPT.resfile),'_rghvec.asc'    ]);
   movefile('outputEof.varEx' ,[filepathstrname(OPT.resfile),'_varEx.asc'     ]);
   movefile('outputEof.vlsng' ,[filepathstrname(OPT.resfile),'_vlsng.asc'     ]);
   movefile('valc.dat'        ,[filepathstrname(OPT.resfile),'_valc.bin'      ]);
   movefile('valosclast.dat'  ,[filepathstrname(OPT.resfile),'_valosclast.bin']);

 else

  %% collect results

    NCid     = netcdf.open(OPT.resfile,'NOWRITE');

    varid.dataf = netcdf.inqVarID(NCid,OPT.dataname);
    dataf       = netcdf.getVar(NCid,varid.dataf);

    nodata   = netcdf.getAtt(NCid,varid.dataf,'_FillValue');
    dataf(dataf==nodata)=NaN;

    nodata   = netcdf.getAtt(NCid,varid.dataf,'missing_value');
    dataf(dataf==nodata)=NaN;

    netcdf.close(NCid);
    
    data  = OPT.transformFunInv(data );
    dataf = OPT.transformFunInv(dataf);

        S.mean   =                      load(['meandata.val'    ]);
        S.P      =                      load(['neofretained.val']);
    if  OPT.version==3
        S.lftvec =        dineof.unpack(load(['outputEof.lftvec']),mask);
        S.rghvec =                      load(['outputEof.rghvec']);
       [S.varEx, S.varLab] =    dineof.varEx(['outputEof.varEx' ]);
        S.vlsng  =                      load(['outputEof.vlsng' ]);

    else
        S.lftvec = ncread   (['DINEOF_diagnostics.nc'],'U');
        nodata   = ncreadatt(['DINEOF_diagnostics.nc'],'U','missing_value');S.lftvec (S.lftvec==nodata)=NaN;
        S.rghvec = ncread   (['DINEOF_diagnostics.nc'],'V');
        nodata   = ncreadatt(['DINEOF_diagnostics.nc'],'V','missing_value');S.rghvec (S.rghvec==nodata)=NaN;
        S.varEx  = ncread   (['DINEOF_diagnostics.nc'],'varEx');
        S.varLab = addrowcol(cellstr([num2str([1:length(S.varEx)]','Mode %d = '),num2str(S.varEx(:))]),0,1,' %');
        S.vlsng  = ncread   (['DINEOF_diagnostics.nc'],'vlsng');
    end
    
    %% consistently swap user-requested signs
    for p=1:min(length(OPT.sgn),S.P)
        S.lftvec(:,:,p) = S.lftvec(:,:,p).*OPT.sgn(p);
        S.rghvec(:  ,p) = S.rghvec(:  ,p).*OPT.sgn(p);
    end

  %% save results to netcdf

   mode     = netcdf.getConstant('CLOBBER'); % do overwrite existing files
   NCid     = netcdf.create(OPT.eoffile,mode);
   globalID = netcdf.getConstant('NC_GLOBAL');
   
   dimid.time     = netcdf.defDim(NCid,'time' ,size(data,3));
   dimid.P        = netcdf.defDim(NCid,'P'    ,S.P);
   for i=1:length(size(data))-1
   dimname = ['space',num2str(i)];
   dimid.space(i) = netcdf.defDim(NCid,dimname,size(data,i));
   end
   
   varid.time   = netcdf.defVar(NCid,OPT.timename,'float' ,dimid.time); 
   varid.mask   = netcdf.defVar(NCid,OPT.maskname,'short' ,dimid.space); 

   varid.P      = netcdf.defVar(NCid,OPT.varname.P     ,'float' ,[]); 
   varid.mean   = netcdf.defVar(NCid,OPT.varname.mean  ,'float' ,[]); 
   varid.lftvec = netcdf.defVar(NCid,OPT.varname.lftvec,'float' ,[dimid.space dimid.P]); % P first (P last in native Matlab) is what DINEOF 4.0 does
   varid.rghvec = netcdf.defVar(NCid,OPT.varname.rghvec,'float' ,[dimid.time  dimid.P]); % P first (P last in native Matlab) is what DINEOF 4.0 does
   varid.vlsng  = netcdf.defVar(NCid,OPT.varname.vlsng ,'float' , dimid.P); 
   varid.varEx  = netcdf.defVar(NCid,OPT.varname.varEx ,'float' , dimid.P); 
   
   netcdf.putAtt(NCid,varid.P     ,'long_name'    ,'optimal number of EOF modes');
   netcdf.putAtt(NCid,varid.mean  ,'long_name'    ,'spatio-temporal mean');
   netcdf.putAtt(NCid,varid.lftvec,'long_name'    ,'spatial EOF modes');
   netcdf.putAtt(NCid,varid.rghvec,'long_name'    ,'temporal EOF modes');
   netcdf.putAtt(NCid,varid.vlsng ,'long_name'    ,'singular values');
   netcdf.putAtt(NCid,varid.varEx ,'long_name'    ,'explained variance');

   netcdf.putAtt(NCid,varid.time  ,'standard_name','time');
   netcdf.putAtt(NCid,varid.time  ,'units'        ,'days since 1970-01-01');

   netcdf.putAtt(NCid,varid.mask  ,'long_name'    ,'mask');
   netcdf.putAtt(NCid,varid.mask  ,'flag_values'  ,[0 1]);
   netcdf.putAtt(NCid,varid.mask  ,'flag_meanings','land ocean');

   netcdf.putAtt(NCid,varid.mean  ,'units'        , 0.01); % percent
   if ~isempty(OPT.units)
   netcdf.putAtt(NCid,varid.mean  ,'units'        ,OPT.units);
   end
   if ~isempty(OPT.standard_name)
   netcdf.putAtt(NCid,varid.mean  ,'standard_name',OPT.standard_name);
   end
   
   netcdf.putAtt(NCid,varid.varEx ,'units'        , 0.01); % percent

   if ~isempty(OPT.lon) & ~isempty(OPT.lat)
   varid.lon = netcdf.defVar(NCid,OPT.lonname,'double' ,dimid.space); 
   varid.lat = netcdf.defVar(NCid,OPT.latname,'double' ,dimid.space); 

   netcdf.putAtt(NCid,varid.lon   ,'long_name'    ,'longitude');
   netcdf.putAtt(NCid,varid.lon   ,'standard_name','longitude');
   netcdf.putAtt(NCid,varid.lon   ,'units'        ,'degrees_east');

   netcdf.putAtt(NCid,varid.lat   ,'long_name'    ,'latitude');
   netcdf.putAtt(NCid,varid.lat   ,'standard_name','latitude');
   netcdf.putAtt(NCid,varid.lat   ,'units'        ,'degrees_north');
   
   netcdf.putAtt(NCid,varid.lftvec,'coordinates'  ,'lat lon');
   netcdf.putAtt(NCid,varid.mask  ,'coordinates'  ,'lat lon');   
   end   

   netcdf.endDef(NCid,20e3,4,0,4); 

   netcdf.putVar(NCid,varid.time,time - datenum(1970,1,1));
   netcdf.putVar(NCid,varid.mask,int8(mask));

   netcdf.putVar(NCid,varid.P     ,S.P);
   netcdf.putVar(NCid,varid.mean  ,S.mean);

   netcdf.putVar(NCid,varid.lftvec,permute(S.lftvec,[1 2 3])); % mind dummy space dimension
   netcdf.putVar(NCid,varid.rghvec,permute(S.rghvec,[1 2]));   % 
   netcdf.putVar(NCid,varid.vlsng ,S.vlsng);
   netcdf.putVar(NCid,varid.varEx ,S.varEx);

   if ~isempty(OPT.lon) & ~isempty(OPT.lat)
   netcdf.putVar(NCid,varid.lon,OPT.lon);
   netcdf.putVar(NCid,varid.lat,OPT.lat);
   end   

   netcdf.close(NCid)
   
   nc_dump(OPT.ncfile,'',[filepathstrname(OPT.eoffile),'.cdl'])
   
      
%% test netcdf.putVar
   if OPT.debug
   figure
   subplot(2,1,1)
   tmp = nc2struct(OPT.eoffile)
   plot(tmp.V','-o')
   hold on
   plot(S.rghvec,'.')
   xlabel('time');xlabel('V')

   subplot(2,1,2)
   if length(size(tmp.U))==2
       plot(permute(tmp.U,[3 1 2]),'-o')
       hold on
       plot(permute(S.lftvec,[1 3 2]),'.')
   else % 2D spatial mode
       xx = permute(tmp.U,[1 3 2]);xx = xx(:,:)';
       plot(xx,'-o')
       hold on
       xx = permute(S.lftvec,[3 1 2]);xx = xx(:,:)';
       plot(xx,'.')       
   end
   xlabel('points');xlabel('U')
   
   end

  %% delete output

  if OPT.cleanup
     delete('meandata.val'    );
     delete('neofretained.val');
     if  OPT.version==3
     delete('outputEof.lftvec');
     delete('outputEof.rghvec');
     delete('outputEof.varEx' );
     delete('outputEof.vlsng' );
     delete('valc.dat'        );
     delete('valosclast.dat'  );
     else
%     delete('DINEOF_diagnostics.nc');
     end
      
     delete(OPT.initfile);
     delete(OPT.logfile );

     delete(OPT.ncfile );
     delete(OPT.resfile);
     delete(OPT.eoffile );
  end
 end   

 %% plot

   if OPT.plot
      TMP = figure;
      dineof.display(data, time, mask, dataf, S);
      %if OPT.export
      %   print2screensize(strrep(OPT.eoffile,'.nc','.png'))
      %end
      %pausedisp
      %try, close(TMP),end
   end
   
end % status

%% out

   dataf = permute(dataf,permuteback);

   if nargout==1
      varargout = {dataf};
   else
      varargout = {dataf,S};
   end
