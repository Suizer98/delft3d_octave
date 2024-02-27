function varargout = detran_convert_d3d_grid_to_transects(grd_file,varargin)
%DETRAN_CONVERT_D3D_GRID_TO_TRANSECTS converts a Delft3D grid (grid-cell-faces) into Detran transects
%
%detran_convert_d3d_grid_to_transects converts an entire Delft3D grid file
%into a Detran transects file (*.pol) which can be used to define transects
%in Detran (based on all grid-cell-faces within the specified Delft3D grid)
%
%Syntax:
%
%<output> = detran_convert_d3d_grid_to_transects(grid_file,<polygon_file>,<custom_line_separator>);
%
%Please note that all variables in <...> are optional
%
%Input parameters:
%
%grid_file                 Required: string specifying the name of the
%                          used gridfile (with or without complete path
%                          and/or file-extension)
%<polygon_file>            Optional: string specifying the name of the
%                          output polygon file (with or without complete
%                          path and/or file-extension). Default name is
%                          'detran_convert_d3d_grid_to_transects_output.pol'
%<custom_line_separator>   Optional: value (number) specifying the line-
%                          separator in the output transects file (*.pol)
%                          It is advised not to change this value as
%                          Detran uses a default value of 999.999, which
%                          is also the default within this script
%
%Output parameters:
%
%<output>                  Optional: can be one or two variables. When
%                          specifying one output variable, a [Mx2] matrix
%                          is returned, in which the line-separator is set
%                          to NaN. When specifying two output variables
%                          (e.g. [X,Y]) two [Mx1] vectors are returned,
%                          containing X and Y values, respectively. In
%                          here, the line-separator is also set to NaN
%
%Example 1
%
%detran_convert_d3d_grid_to_transects('D:\example\delft3d_grid.grd');
%
%Example 2
%
%[X,Y] = detran_convert_d3d_grid_to_transects('D:\example\delft3d_grid.grd',...
%                                             'my_transects.pol');
%plot(X,Y,'k'); axis equal; grid on; box on;
%
%
%Note on advised Delft3D grids to use within this tool:
%
%A good way to start is by derefining your original grid, this way,
%gridlines are more or less followed. Considering a smaller area (area of
%interest) also speeds up the Detran process (transect transport computations)
%
%One could also generate a custom grid just for usage with Detran, Delft
%Dashboard would be a good option to generate the grid. Also here, you are
%advised to use quite large gridcells as Detran requires quite some time to
%compute transports through each transect (especially when transects are
%overlapping quite a number of computational cells).
%
%Eventually, aiming at something like the visual example below results in
%Detran results being nicely depicted within final figures:
%_   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _ 
% _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ 
%\ _ \ _ \ _ \ __\___\___\___\___\___\___\___\___\___\___\ _ \ _ \ _ \ _ \ 
% \ _ \ _ \ _ | _ \ _ \ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \
%_ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \ _ | _ \ _ \ _ \ _ \ _ \ | \ _ \ _ \ _ \ _ 
% _ \ _ \ _ \ | \ _ \ _ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _
%\ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _ \ | \ _ \ _ \ _ \ _ \ _ | _ \ _ \ _ \ _ \ 
% \ _ \ _ \ _ | _ \ _ \ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \
%_ \ _ \ _ \ _|\___\___\___\___\___|___\___\___\___\___\_| \ _ \ _ \ _ \ _ 
% _ \ _ \ _ \ | \ _ \ _ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _
%\ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _ \ | \ _ \ _ \ _ \ _ \ _ | _ \ _ \ _ \ _ \ 
% \ _ \ _ \ _ | _ \ _ \ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \
%_ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \ _ | _ \ _ \ _ \ _ \ _ \ | \ _ \ _ \ _ \ _ 
% _ \ _ \ _ \ | \ _ \ _ \ _ \ _ \ _|\ _ \ _ \ _ \ _ \ _ \|_ \ _ \ _ \ _ \ _
%\ _ \ _ \ _ \|__\___\___\___\___\_|_\___\___\___\___\___| _ \ _ \ _ \ _ \ 
% \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \
%_ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ \ _ 
%
%Contact Freek Scheel (freek.scheel@deltares.nl) if bugs are encountered
%
%See also: detran detran_engines

%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Please contact me if errors occur.
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

poly_name = 'detran_convert_d3d_grid_to_transects_output.pol';
NaN_val   = 999.999;

if exist(grd_file)~=2
    error('Grid file does not exist, please check this...');
end

if nargin > 1
    if ischar(varargin{1})
        poly_name = varargin{1};
        if length(poly_name)>3
            if ~strcmp(poly_name(end-3:end),'.pol')
                poly_name = [poly_name '.pol'];
            end
        else
            poly_name = [poly_name '.pol'];
        end
    else
        error('Please specify the output polygon filename as a string...');
    end
    
    if nargin > 2
        if isnumeric(varargin{2})
            NaN_val = varargin{2};
            if NaN_val ~= 999.999
                disp(['Using ' num2str(NaN_val) ' as line-separator (default is 999.999), are you sure about this?']);
                disp(['The Script continues automatically...']);
                disp(' ');
            else
                disp(['Specifying the line-separator value is not required']);
                disp(['The script continues using 999.999 as specified (equal to the default value)']);
                disp(' ');
            end
        else
            error('The input paramater specifying the line-separator is not a numeric value, please change this or ignore this input parameter as it is optional');
        end
    end
end

grd = wlgrid('read',grd_file);

pol = [];
for ii=1:size(grd.X,1)
    for jj=1:size(grd.X,2)
        try
            if ~isnan(grd.X(ii,jj)) & ~isnan(grd.X(ii+1,jj))
                pol = [pol; grd.X(ii,jj) grd.Y(ii,jj); grd.X(ii+1,jj) grd.Y(ii+1,jj); NaN_val NaN_val];
            end
        end
        try
            if ~isnan(grd.X(ii,jj)) & ~isnan(grd.X(ii,jj+1))
                pol = [pol; grd.X(ii,jj) grd.Y(ii,jj); grd.X(ii,jj+1) grd.Y(ii,jj+1); NaN_val NaN_val];
            end
        end
    end
end

pol(end,:) = [];

if exist(poly_name)==2
    answ = questdlg({['File ' poly_name ' already exists'];' ';'Would you like to overwrite this file?'},'Polygon file already exists','Yes, overwrite','No, abort','Yes, overwrite');
    if ~strcmp(answ,'Yes, overwrite')
        return
    end
end

fid = fopen(poly_name,'w+');
fprintf(fid,['*column 1 = x coordinate\n*column 2 = y coordinate\n1\n' num2str(size(pol,1)) ' ' num2str(size(pol,2)) '\n']);
for ii=1:size(pol,1)
    if pol(ii,1) == NaN_val
        fprintf(fid,['%g %g\n'],[pol(ii,:)]);
    else
        fprintf(fid,['%9.9f %9.9f\n'],[pol(ii,:)]);
    end
end
fclose(fid);

if nargout>0
    pol(find(pol==NaN_val)) = NaN;
    if nargout == 1
        varargout{1} = pol;
    elseif nargout == 2
        varargout{1} = pol(:,1);
        varargout{2} = pol(:,2);
    end
end

disp(['Polygon ' poly_name ' was generated succesfully']);

end