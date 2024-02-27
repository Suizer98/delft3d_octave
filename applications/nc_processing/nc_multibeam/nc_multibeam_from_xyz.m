function varargout = nc_multibeam_from_xyz(varargin)
%NC_MULTIBEAM_FROM_XYZ  One line description goes here.
%
%      NC_MULTIBEAM_FROM_XYZ
%
%   <OPT> = nc_multibeam_from_asc(<keyword,value>)
%
%See also: nc_multibeam

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Jun 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: nc_multibeam_from_xyz.m 5898 2012-03-28 21:10:18Z k.w.pruis.x $
% $Date: 2012-03-29 05:10:18 +0800 (Thu, 29 Mar 2012) $
% $Author: k.w.pruis.x $
% $Revision: 5898 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/nc_processing/nc_multibeam/nc_multibeam_from_xyz.m $
% $Keywords: $
%
% nc_SetOptions  can be used to collect the input parameters
% Example
% OPT = nc_SetOptions
% nc_multibeam_to_kml_tiles_png(OPT.nc)

%%
%% Kees Pruis
set(0,'defaultFigureWindowStyle','normal')

if nargin==0
    varargout = {'Input parameters are not given'};
    return
end

OPT = setproperty(varargin{:});

% ----------------------------------------------------------------------
if OPT.make
    multiWaitbar( 'Raw data to NetCDF',0,'Color',[0.2 0.6 0.2])
    disp('generating nc files... ')
    %% limited input check
%     if isempty(OPT.raw_path)
%         error %#ok<LTARG>
%     end
%     if isempty(OPT.netcdf_path)
%         error  %#ok<LTARG>
%     end
    
    %%
    EPSG             = load('EPSG');
    mkpath(fullfile(OPT.basepath_local,OPT.netcdf_path));
    delete(fullfile(OPT.basepath_local,OPT.netcdf_path,'*.nc'));
    
    if OPT.zip
        mkpath(OPT.cache_path);
        fns = dir(fullfile(OPT.raw_path,OPT.zip_extension));
    else
        fns = dir(fullfile(OPT.raw_path,OPT.raw_extension));
    end
    
    %% check if files are found
    if isempty(fns)
        error('no raw files')
    end
    
    %% initialize waitbar
    WB.done       = 0;
    WB.bytesToDo  = 0;
    if OPT.zip
        multiWaitbar('raw_unzipping'  ,0,'Color',[0.2 0.7 0.9])
    end
    multiWaitbar('nc_reading'         ,0,'Color',[0.1 0.5 0.8],'label','Reading')
    multiWaitbar('nc_writing'         ,0,'Color',[0.1 0.3 0.6],'label','Writing')
    for ii = 1:length(fns)
        WB.bytesToDo = WB.bytesToDo + fns(ii).bytes;
    end
    WB.bytesToDo =  WB.bytesToDo*2;
    WB.bytesDoneClosedFiles = 0;
    WB.zipratio = 1;
    for jj = 1:length(fns)
        if OPT.zip
            multiWaitbar('raw_unzipping', 0,'label',sprintf('Unzipping %s',fns(jj).name));
            %delete files in cache
            delete(fullfile(OPT.cache_path, '*'));
            
            % uncompress files with a gui for progres indication
            uncompress(fullfile(OPT.raw_path,fns(jj).name),...
                'outpath',fullfile(OPT.cache_path),'gui',true,'quiet',true);
            
            % read the output of unpacked files
            fns_unzipped = dir(fullfile(OPT.cache_path,OPT.raw_extension));
            
            % get the size of the unpacked files that will be processed
            unpacked_size = 0;
            for kk = 1:length(fns_unzipped)
                unpacked_size = unpacked_size + fns_unzipped(kk).bytes;
            end
            WB.bytesToDo = WB.bytesToDo/WB.zipratio;
            
            % calculate a zip ratio to estimate the compression level (used
            % to estimate the total work for the progress bar)
            WB.zipratio = (WB.zipratio*(jj-1)+unpacked_size/fns(jj).bytes)/jj;
            WB.bytesToDo = WB.bytesToDo*WB.zipratio;
            multiWaitbar('raw_unzipping', 1);
        else
            fns_unzipped = fns(jj);
        end
        
        for ii = 1:length(fns_unzipped)
            %% set waitbars to 0 and update label
            multiWaitbar('nc_writing',0,'label','Writing: *.nc')
            multiWaitbar('nc_reading',0,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name)))
            %% read data
            
            % process time
            
            try
                time    = OPT.dateFcn(fns_unzipped(ii).name) - datenum(1970,1,1);
                OPT.SetTime = 0;
            catch
                time = now -datenum(1970,1,1);
                disp('The date of the data is set to be NOW')
                OPT.SetTime = 1;
            end
            
            if OPT.zip
                fid      = fopen(fullfile(OPT.cache_path,fns_unzipped(ii).name));
            else
                fid      = fopen(fullfile(OPT.raw_path  ,fns_unzipped(ii).name));
            end
            
            % waitbar stuff
            WB.bytesDoneOfCurrentFile = 0;
            WB.bytesWritten  = 0;
            WB.bytesRead     = 0;
            
            headerlines      = OPT.headerlines;
            %test which delimiter does the job
             D_check1     = textscan(fid,OPT.format,10,...
                                  'delimiter',OPT.delimiter,...
                                'headerlines',headerlines,...
                        'MultipleDelimsAsOne',OPT.MultipleDelimsAsOne);
                    
%             D_check2     = textscan(fid,OPT.format,10,...
%                       'delimiter',OPT.delimiter2,...
%                     'headerlines',headerlines,...
%             'MultipleDelimsAsOne',OPT.MultipleDelimsAsOne);
            
%             if size(D_check1{1,1},1)<size(D_check2{1,3},1)
%                 OPT.delimiter_used = OPT.delimiter2;
%             elseif size(D_check1{1,1},1)>size(D_check2{1,3},1)
%                 OPT.delimiter_used = OPT.delimiter;
%             end
            while ~feof(fid)
                multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+WB.bytesRead+WB.bytesWritten)/WB.bytesToDo)
                multiWaitbar('nc_reading',ftell(fid)/fns_unzipped(ii).bytes,'label',sprintf('Reading: %s...', (fns_unzipped(ii).name))) ;
                WB.bytesDoneOfCurrentFile = ftell(fid);
                
                    D     = textscan(fid,OPT.format,OPT.block_size,...
                                  'delimiter',OPT.delimiter,...
                                'headerlines',headerlines,...
                        'MultipleDelimsAsOne',OPT.MultipleDelimsAsOne);
                    
                    if numel(unique(cellfun(@numel,D))) ~= 1
                        if OPT.zip
                            n = fullfile(OPT.cache_path,fns_unzipped(ii).name);
                        else
                            n = fullfile(OPT.raw_path  ,fns_unzipped(ii).name);
                        end
                        error('error reading file: %s',n);
                    end
                headerlines     = 0; % only skip headerlines on first read
                
                % waitbar stuff
                WB.bytesRead = ftell(fid);
                multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+ WB.bytesRead+WB.bytesWritten)/WB.bytesToDo)
                multiWaitbar('nc_reading'        , WB.bytesRead/fns_unzipped(ii).bytes,...
                    'label',sprintf('Reading: %s', (fns_unzipped(ii).name))) ;
                WB.numel        = length(D{OPT.xid});
                
                
                %% find min and max
                minx    = min(D{OPT.xid});
                miny    = min(D{OPT.yid});
                maxx    = max(D{OPT.xid});
                maxy    = max(D{OPT.yid});
                minx    = floor(minx/OPT.mapsizex)*OPT.mapsizex + OPT.xoffset;
                miny    = floor(miny/OPT.mapsizey)*OPT.mapsizey + OPT.yoffset;
                
                %% loop through data
                
                for x0      = minx : OPT.mapsizex : maxx
                    for y0  = miny : OPT.mapsizey : maxy

                        try
                        xbounds = [x0 x0+((OPT.mapsizex/OPT.gridsizex)-1) * OPT.gridsizex];
                        ybounds = [y0 y0+((OPT.mapsizey/OPT.gridsizey)-1) * OPT.gridsizey];
                        
                        ids     = D{OPT.xid}>=min(xbounds) & D{OPT.xid}<=max(xbounds) & ...
                                  D{OPT.yid}>=min(ybounds) & D{OPT.yid}<=max(ybounds);
                        catch
                            n=1;
                        end
                        if sum(ids)>0
                            x   =  D{OPT.xid}(ids);
                            y   =  D{OPT.yid}(ids);   
                            z   =  D{OPT.zid}(ids)*OPT.zfactor;
                            
                            % generate X,Y,Z
                            x_vector = x0 + (0:(OPT.mapsizex/OPT.gridsizex)-1) * OPT.gridsizex;
                            y_vector = y0 + (0:(OPT.mapsizey/OPT.gridsizey)-1) * OPT.gridsizey;
                            [X,Y]    = meshgrid(x_vector,y_vector);
                            
                            % place xyz data on XY matrices
                            Z = OPT.gridFcn(x,y,z,X,Y);
                            
                            % set the name for the nc file
                            ncfile = fullfile(OPT.basepath_local,OPT.netcdf_path,...
                                    sprintf('%.2f_%.2f_%s_data.nc',x0-.5*OPT.gridsizex,y0-.5*OPT.gridsizey,OPT.datatype));
                                
                            if any(~isnan(Z(:)))
                                Z = flipud(Z);
                                Y = flipud(Y);
                                % if a non trivial Z matrix is returned write the data
                                % to a nc file
                                
                                if ~exist(ncfile, 'file')
                                    nc_multibeam_createNCfile(OPT,EPSG,ncfile,X,Y)
                                end
                                nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z')
                            end
                            
                            % crop ncfile name for waitbars
                            if length(ncfile)>70
                                ncfile = ['...' ncfile(end-68:end)];
                            end
                            
                            %  waitbar stuff
                            WB.numelDone               = length(x);
                            WB.bytesWritten            = WB.bytesWritten + WB.numelDone/WB.numel*(WB.bytesRead-WB.bytesDoneOfCurrentFile);
                            multiWaitbar('Raw data to NetCDF',(WB.bytesDoneClosedFiles*2+WB.bytesRead+WB.bytesWritten)/WB.bytesToDo)
                            multiWaitbar('nc_writing',WB.bytesWritten/fns_unzipped(ii).bytes,...
                                'label',ncfile);
                        end
                    end
                end
                WB.bytesWritten = WB.bytesRead;
            end
            fclose(fid);
            WB.bytesDoneClosedFiles = WB.bytesDoneClosedFiles + fns_unzipped(ii).bytes;
        end
    end
    
    if OPT.zip
        try %#ok<TRYNC>
            rmdir(OPT.cache_path,'s')
        end
        multiWaitbar('raw_unzipping','close')
    end
    
    multiWaitbar('Raw data to NetCDF',1)
    multiWaitbar('nc_reading','close')
    multiWaitbar('nc_writing','close')
    disp('generation of nc files completed')
else
    disp('generation of nc files skipped')
end

OPT = nc_multibeam_copync2server(OPT);

varargout = {OPT};