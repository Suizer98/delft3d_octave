function output_text = delft3d_obs_file_in_polygon(grd_file,pol_file,obs_file_out,varargin)
% delft3d_obs_file_in_polygon creates observation points in all grid cells
% within the specified polygon (generated with e.g. RGFGRID or ldbTool) and
% names them according to nesting standards (so you can use them for ad hoc
% nesting without having to run the model again, nesthd2 can be started directly)
%
%  <obs_text> = delft3d_obs_file_in_polygon(grd_file,pol_file,obs_file_out,<obs_file_in>);
%
%  <obs_text>    = Optional, output text that is written to obs_file_out as well
%                  this text excludes the original points though (only added ones)
%  grd_file      = Required, grid file (its name with or without location in
%                  a text string)
%  pol_file      = Required, polygon file (its name with or without location in
%                  a text string)
%  obs_file_out  = Required, output observation file name (its name with or 
%                  without location in a text string)
%  <obs_file_in> = Optional, observation file linked to grd_file, all
%                  locations that are within the polygon, but already
%                  within <obs_file_in> will be ignored
%
% Example 1:
%    delft3d_obs_file_in_polygon('grd.grd','pol.pol','additional_obs.obs');
%
% Example 2:
%    delft3d_obs_file_in_polygon('D:/d3d/grd.grd',...
%                                'C:/some_folder/pol.pol',...
%                                'D:/d3d/testing/additional_obs.obs',...
%                                'D:/d3d/original_obs.obs);
%
% Example 3:
%    output_text = delft3d_obs_file_in_polygon('grd.grd',...
%                                              'pol.pol',...
%                                              'additional_obs.obs');
%    disp('All locations as stored in additional_obs.obs:'); disp(' ');
%    output_text
%
% See also: wlgrid, inpolygon, landboundary, LDBTool,
% dflowfm.obs_file_in_polygon, delft3d_io_obs

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Freek Scheel
%
%       <freek.scheel@deltares.nl>;
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

if ~isstr(grd_file)
    error('Specify a name or location of the grid file in a string');
elseif exist(grd_file)~=2
    error('Specified grid file is non-existend');
else
    try
        grd = wlgrid('read',grd_file);
    catch
        error('Grid file loading failed');
    end
end

if ~isstr(pol_file)
    error('Specify a name or location of the polygon file in a string');
elseif exist(pol_file)~=2
    error('Specified grid file is non-existend');
else
    try
        pol = landboundary('read',pol_file);
    catch
        error('Polygon file loading failed');
    end
end

if ~isstr(obs_file_out)
    error('Specify a name or location of the polygon file in a string');
else
    if length(obs_file_out)<5
        obs_file_out = [obs_file_out '.obs'];
    elseif ~strcmp(obs_file_out(end-3:end),'.obs')
        obs_file_out = [obs_file_out '.obs'];
    end
end

if length(varargin) == 1
    obs_file = varargin{1};
    if ~isstr(obs_file)
        error('Specify a name or location of the observation file in a string');
    elseif exist(obs_file)~=2
        error('Specified observation file is non-existend');
    else
        try
            obs = delft3d_io_obs('read',obs_file);
        catch
            error('Observation file loading failed');
        end
    end
elseif length(varargin) > 1
    warning('Too many input parameters specified, ignoring all input after the first 3 and trying to continue anyway');
    obs_file = varargin{1};
    if ~isstr(obs_file)
        error('Specify a name or location of the observation file in a string');
    elseif exist(obs_file)~=2
        error('Specified observation file is non-existend');
    else
        try
            obs = delft3d_io_obs('read',obs_file);
        catch
            error('Observation file loading failed');
        end
    end
end

if exist('obs')==1
    if isempty(obs.m)
        warning('No data found in observation file, ignored');
        clear obs
    end
end

tel=0;
inp = zeros(size(grd.X));
for m=1:size(grd.X,1)
    for n=1:size(grd.X,2)
        inp(m,n) = inpolygon(grd.X(m,n),grd.Y(m,n),pol(:,1),pol(:,2));
        if inp(m,n) == 1
            if exist('obs') == 1
                if  isempty(find(obs.m==m & obs.n==n))
                    tel = tel+1;
                    loc_names{tel,1} = ['(M,N)=(' sprintf('%5.0f',m) ',' sprintf('%5.0f',n) ') '];
                    MN(tel,:) = [m n];
                    output_text{tel,1} = [loc_names{tel,1} sprintf('%8.0f',m) ' ' sprintf('%8.0f',n)];
                else
                    inp(m,n) = 0;
                end
            else
                tel = tel+1;
                loc_names{tel,1} = ['(M,N)=(' sprintf('%5.0f',m) ',' sprintf('%5.0f',n) ') '];
                MN(tel,:) = [m n];
                output_text{tel,1} = [loc_names{tel,1} sprintf('%8.0f',m) ' ' sprintf('%8.0f',n)];
            end
        end
    end
end

if ~exist('MN')
    error('No locations were found within the polygon, please check this');
end

if exist('obs')==1
    MN        = [[obs.m; obs.n]' ;MN];
    loc_names = [cellstr(obs.namst); loc_names];
end

obs_new.m = MN(:,1);
obs_new.n = MN(:,2);
obs_new.namst = loc_names;

delft3d_io_obs('write',obs_file_out,obs_new);

