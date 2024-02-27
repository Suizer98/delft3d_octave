function varargout = swan_io_spectrum(varargin)
%SWAN_IO_SPECTRUM_WRITE   Writes a 1D SWAN spectrum file (BETA VERSION).
%
% <iostat> = SWAN_IO_SPECTRUM_WRITE(fname,DAT)
% 
% Write an ASCII SWAN spectrum file into a struct DAT 
% with <optional> and required fields
%
%                    <comment>: 
%                           x : [1 x nloc double]     or  lon  [1 x nfreq double] 
%                          <y>: [1 x nloc double]        <lat> [1 x nfreq double] 
%
%               frequency_type: 'a<bsolute>'          or rfreq [1 x nfreq double] 
%                               'r<elative>'             afreq [1 x nfreq double] 
%                    frequency: [1 x nfreq double]         
%
%         direction_convention: 'n<autical>'          or ndir  [1 x ndir double]
%                               'c<artesian>'            cdir  [1 x ndir double]
%                   directions: [1 x ndir double]     or       [1 x 1    double]
%
%                       EnDens: [nloc x nfreq double]
%                         NDIR: [nloc x nfreq double] or       [1 x 1    double]
%                     DSPRDEGR: [nloc x nfreq double] or       [1 x 1    double] (1D only)
%
% A 1D spectrum read with SWAN_IO_SPECTRUM can be written
% with SWAN_IO_SPECTRUM_WRITE.
%
% See also: SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_BOT, SWAN_IO_GRD

%% TO DO: align output columns

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Mar Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%% Keywords

   OPT.OS       = 'dos';
   
          DAT.number_of_locations = [];
                          DAT.mxc = [];
                          DAT.myc = [];
                            DAT.x = [];
                            DAT.y = [];
                          DAT.lon = [];
                          DAT.lat = [];
               DAT.frequency_type = '';

        DAT.number_of_frequencies = [];
                    DAT.frequency = [];
                        DAT.afreq = [];
                        DAT.rfreq = [];

        DAT.dimension_of_spectrum = [];
         DAT.number_of_quantities = [];
    DAT.quantity_exception_values = [];%[-99 -999 -9]
               DAT.quantity_names = {};%{'EnDens'  'CDIR'  'DSPRDEGR'}
          DAT.quantity_names_long = {};%{'variance densities in m2/Hz'  'average Cartesian direction in degr'  ''}
               DAT.quantity_units = {};%{'J/m2/Hz'  'degr'  'degr'}
                       DAT.EnDens = [];
                       DAT.VaDens = [];
                         DAT.CDIR = [];
                         DAT.NDIR = [];
                     DAT.DSPRDEGR = [];
                     
                     DAT.directions = [];
                     DAT.direction_convention = [];
                     

%% Input
   
   iostat       = 1;

   if nargin==2
   DAT          = varargin{2};
   else
   DAT = setproperty(DAT,varargin{2:end});
   end
   
   DAT.filename = varargin{1,1}; % overwrite one in struct
   DAT.filename = 'test.bnd'
   %[DAT.path DAT.name DAT.ext] = fileparts(DAT);
   
%% Check for overwriting
   
   tmp       = dir(DAT.filename);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else
   
      while 0 % ~islogical(writefile)
         disp(['Spectrum file already exists: ''',DAT.filename,'''']);
         writefile    = input('o<verwrite> / c/<ancel>: ','s');
         if strcmpi(writefile(1),'o')
            writefile = true;
         elseif strcmpi(writefile(1),'c')
            writefile = false;
            iostat    = 0;
         end
      end
   
   end % length(tmp)==0      
   
   if ~writefile
      return
   end
   
%% Open

   fid = fopen(DAT.filename,'w');
   if fid==-1            
      iostat=-1;
   end
      
   if iostat
   
   Q = swan_quantity();
      
%% Write header
         
         fprintf  (fid,'%s','SWAN   1                                Swan standard spectral file, version');
         fprinteol(fid,OPT.OS);
         
         if isfield(DAT,'comment');
            for irec=1:length(DAT.comment)
            rec = [DAT.comment{irec}];
            fprintf  (fid,'$%s',rec);
            fprinteol(fid,OPT.OS);
            end
         else
         
            fprintf  (fid,'%s',['$File created by $Id: swan_io_spectrum_write.m 15133 2019-02-07 10:49:31Z nederhof $'        ]);fprinteol(fid,OPT.OS);
            fprintf  (fid,'%s',['$File created on',datestr(now)]);fprinteol(fid,OPT.OS);
         
         end

%% Write locations

         if isfield(DAT,'x')

            fprintf  (fid,'%s','LOCATIONS                               locations in x-y-space');
            fprinteol(fid,OPT.OS);
            
            DAT.number_of_locations   = length(DAT.x);
            rec  = '                                        number of locations';
            rec0 = num2str(DAT.number_of_locations,'   %g');
            rec(1:length(rec0)) = rec0;
            fprintf  (fid,'%s',rec);
            fprinteol(fid,OPT.OS);
         
            if ~isfield(DAT,'y')
               DAT.y = zeros(size(DAT.x));
            end
            if isempty(DAT.y)
               DAT.y = zeros(size(DAT.x));
            end
            
            for iloc=1:DAT.number_of_locations
            fprintf  (fid,'      %g',DAT.x(iloc));
            fprintf  (fid,'      %g',DAT.y(iloc));
            fprinteol(fid,OPT.OS);
            end
         
         elseif isfield(DAT,'lon')
         
            fprintf  (fid,'%s','LONLAT');fprinteol(fid,OPT.OS);
            
            DAT.number_of_locations   = length(DAT.lon);
            rec  = '                                        number of locations';
            rec0 = num2str(DAT.number_of_locations,'   %g');
            rec(1:length(rec0)) = rec0;
            fprintf  (fid,'%s',rec);
            fprinteol(fid,OPT.OS);
         
            if ~isfield(DAT,'lat')
               DAT.lat = zeros(size(DAT.lon));
            end
            
            for iloc=1:DAT.number_of_locations
            fprintf  (fid,'      %g',DAT.lon(iloc));
            fprintf  (fid,'      %g',DAT.lat(iloc));
            fprinteol(fid,OPT.OS);
            end            

         else
         
            error('Either field ''x'' or ''lon'' required.')
            
         end
         
%% Write frequencies

         if isfield(DAT,'afreq')
            if ~isempty(DAT.afreq)
            DAT.frequency_type = 'absolute';
            DAT.frequency      = DAT.afreq;
            end
         end
         if isfield(DAT,'rfreq')
            if ~isempty(DAT.rfreq)
            DAT.frequency_type = 'relative';
            DAT.frequency      = DAT.rfreq;
            end
         end
         
         if ~isfield(DAT,'frequency_type')
         
            error('field ''frequency_type'' required.')
            
         end
         
         if     strcmpi(DAT.frequency_type,'a');% absolute

            fprintf  (fid,'%s','AFREQ                                   absolute frequencies in Hz');
            fprinteol(fid,OPT.OS);
            
            DAT.number_of_frequencies   = length(DAT.frequency);
            rec  = '                                        number of frequencies';
            rec0 = num2str(DAT.number_of_frequencies,'   %g');
            rec(1:length(rec0)) = rec0;
            fprintf  (fid,'%s',rec);
            fprinteol(fid,OPT.OS);            

            for iloc=1:DAT.number_of_frequencies
            fprintf  (fid,'      %g',DAT.frequency(iloc));
            fprinteol(fid,OPT.OS);
            end            
            
         elseif strcmpi(DAT.frequency_type,'r');% relative

            fprintf  (fid,'%s','RFREQ                                   relative frequencies in Hz');
            fprinteol(fid,OPT.OS);
            
            DAT.number_of_frequencies   = length(DAT.frequency);
            rec  = '                                        number of frequencies';
            rec0 = num2str(DAT.number_of_frequencies,'   %g');
            rec(1:length(rec0)) = rec0;
            fprintf  (fid,'%s',rec);
            fprinteol(fid,OPT.OS);
            
            for iloc=1:DAT.number_of_frequencies
            fprintf  (fid,'      %g',DAT.frequency(iloc));
            fprinteol(fid,OPT.OS);
            end            

         end

%% Define parameters

   if isfield(DAT,'EnDens')
      if ~isempty(DAT.EnDens)
      DAT.quantity_names{1}            = 'EnDens';
      DAT.quantity_units{1}            = 'J/m2/Hz';
      DAT.quantity_exception_values(1) = Q.EEEE.OVEXCV;
      end
   end
   
   if isfield(DAT,'VaDens')
      if ~isempty(DAT.VaDens)
      DAT.quantity_names{1}            = 'VaDens';
      DAT.quantity_units{1}            = 'm2/Hz';
      DAT.quantity_exception_values(1) = Q.VaDens.OVEXCV;
      end
   end
   
      if ~isempty(DAT.DSPRDEGR)
      DAT.quantity_names{3}            = 'DSPRDEGR';
      DAT.quantity_units{3}            =  'degr';    
      DAT.quantity_exception_values(3) = Q.DSPR.OVEXCV;
      if     length(DAT.DSPRDEGR)==1
      DAT.DSPRDEGR = repmat(DAT.DSPRDEGR,size(DAT.frequency));
      elseif length(DAT.DSPRDEGR)==length(DAT.frequency)
      else
      error('length(DSPRDEGR) should be 1 or identical to frequency')
      end
      end
           

%% Write directions

         if isfield(DAT,'NDIR')
         if ~isempty(DAT.NDIR)
            DAT.direction_convention         = 'nautical';
            DAT.directions                   = DAT.NDIR;
            DAT.quantity_names{2}            = 'NDIR';
            DAT.quantity_units{2}            = 'degr';
            DAT.quantity_exception_values(2) = Q.DIR.OVEXCV;
            DAT.NDIR = repmat(DAT.NDIR,size(DAT.frequency));
         end
         end
         
         if isfield(DAT,'CDIR')
         if ~isempty(DAT.CDIR)
            DAT.direction_convention         = 'cartesian';
            DAT.directions                   = DAT.CDIR;
            DAT.quantity_names{2}            = 'CDIR';
            DAT.quantity_units{2}            = 'degr';
            DAT.quantity_exception_values(2) = Q.DIR.OVEXCV;
            if prod(size(DAT.CDIR))==1
            DAT.CDIR = repmat(DAT.CDIR,size(DAT.frequency));
            end
         end
         end
         
         DAT.number_of_directions    = length(DAT.directions);
         
%          if isempty(DAT.direction_convention) & ...
%             isfield(DAT,'directions')
%             error('field ''direction_convention'' required for 2D spectra.')
%          end

         if isfield(DAT,'directions') & DAT.number_of_directions > 1 & ...
            ~(isvector(DAT.quantity_names{1}))
         
         if     strcmpi(DAT.direction_convention(1),'n');% nautical

            fprintf  (fid,'%s','NDIR');fprinteol(fid,OPT.OS);
            
             fprintf  (fid,'   %g',DAT.number_of_directions);
            fprinteol(fid,OPT.OS);

            for iloc=1:DAT.number_of_directions
            fprintf  (fid,'      %g',DAT.directions(iloc));
            fprinteol(fid,OPT.OS);
            end            
            
         elseif strcmpi(DAT.direction_convention(1),'c');% cartesian

            fprintf  (fid,'%s','CDIR');fprinteol(fid,OPT.OS);
            fprintf  (fid,'   %g',DAT.number_of_directions);
            fprinteol(fid,OPT.OS);
            
            for iloc=1:DAT.number_of_directions
            fprintf  (fid,'      %g',DAT.directions(iloc));
            fprinteol(fid,OPT.OS);
            end            

         end
         
         end
         
%% Write quantity header
         
         fprintf  (fid,'%s','QUANT');
         fprinteol(fid,OPT.OS);
         
         DAT.number_of_quantities = length(DAT.quantity_names);
         rec  = '                                        number of quantities in table';
         rec0 = num2str(DAT.number_of_quantities,'   %g');
         rec(1:length(rec0)) = rec0;
         fprintf  (fid,'%s',rec);
         fprinteol(fid,OPT.OS);         
         
         for iquant=1:length(DAT.quantity_names)

            quantity_name = DAT.quantity_names{iquant};
         
            fprintf  (fid,'%s'   ,DAT.quantity_names           {iquant});fprinteol(fid,OPT.OS);
            fprintf  (fid,'%s'   ,DAT.quantity_units           {iquant});fprinteol(fid,OPT.OS);
            fprintf  (fid,'   %g',DAT.quantity_exception_values(iquant));fprinteol(fid,OPT.OS);
            
            
            nodata = isnan(DAT.(quantity_name));
            DAT.(quantity_name)(nodata) = DAT.quantity_exception_values(iquant);
            
         end
         
%% Write data

         if DAT.number_of_locations==1
               for iquant=1:DAT.number_of_quantities
               quantity_name = DAT.quantity_names{iquant};
                  if size(DAT.(quantity_name),2)==1
                  DAT.(quantity_name) = DAT.(quantity_name)';
                  end
               end
         end
         
         for iloc=1:DAT.number_of_locations
         
            fprintf  (fid,'%s ','LOCATION ');
            fprintf  (fid,'%g ',iloc);
            fprinteol(fid,OPT.OS);
         
            for ifreq=1:length(DAT.frequency)
               for iquant=1:DAT.number_of_quantities
               quantity_name = DAT.quantity_names{iquant};
               fprintf  (fid,'%g ',DAT.(quantity_name)(iloc,ifreq));
               end
            end
         end

      iostat = fclose(fid);

   end % if iostat
   
   DAT.iomethod = ['written by $Id: swan_io_spectrum_write.m 15133 2019-02-07 10:49:31Z nederhof $ at ',datestr(now)];
   DAT.iostatus = iostat;
   
   if iostat==-1
      fclose(fid);
      error(['Error in opening file: ',DAT.filename]);
   end
      
%% Function output

   if nargout      ==1
      varargout= {iostat};
   end

%% EOF