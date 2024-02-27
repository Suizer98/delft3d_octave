function Im2Ico(icon, map, mask, filename)
%IM2ICO Imag2Ico converts bitmaps to a WIN32 icon and writes it to a file.
%
% Imag2Ico(BITMAP, MAP, MASK, FILENAME); BITMAP and MASK are cell 
% arrays of equal length. MAP is a cell array of arbitrary length > 0. 
% BITMAP are indexed and may be rectangular. Numeric input can be DOUBLE    
% or UINT8. If BITMAP is DOUBLE, the pixels may range from 1 to 
% SIZE(MAP, 1); if BITMAP is UINT8, the pixels may range from 0 to 
% SIZE(MAP, 1) - 1. MAP must contain at least one colormap. If there are
% fewer colormaps than bitmaps, the last colormap will be copied as 
% often as necessary. If MASK is empty it is filled with zeros. A zero 
% mask pixel is opaque, a 1 mask pixel is transparent.
% 
% Examples for how to create an icon:
%
% Adobe Photoshop Elements
% ------------------------
% New; 32 pixel, 32 pixel, 2 pixel/cm, RGB-color; pencil 1 pixel; tear 
% off color palette; draw image; save as GIF, exact, primary colors, 
% normal. The GIF-image is UINT8, indexed, the colormap is complemented
% with zeros to a power of 2. The first eight colors, 0 (white) to 7 
% (black) are colors of 1s and 0s, the other colors are fractions 
% between 0 and 1 as needed. In Matlab read as: 
%    [gifimage, gifmap] = imread('filename.gif'); 
%    Imag2Ico({gifbild}, {gifmap}, {}, 'filename.ico').
%
% ACD Foto Canvas
% ---------------
% New, 32, 32, 8bpp, zoom in, pencil, view, tool options, line width 1;
% select primary and secondary colors with the left and the right mouse
% button, draw with both buttons. Save as BMP. The bitmap is indexed 
% UINT8, the colormap is 216 lines of colors and 40 lines of zeros. In
% Matlab read as:
%    [bmpimage, bmpmap] = imread('filename.bmp');
%    Imag2Ico({bmpimage}, {bmpmap}, {}, 'filename.ico').
%
% 48 x 48, 96 dpi, works fine for desktop icons. PAINT works also.
%
% See also: imread

% Background info: http://www.iconolog.net/info/icoFormat.html.
% PMWNave@yahoo.de
% 2004-12-10, started.
% 2006-11-03, cosmetics, comments.

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

%
%

  if nargin ~= 4,
     error(' ### %s requires exactly four input arguments.', mfilename)
  end
  imcount = length(icon);
  if imcount == 0,
     error(' ### %s needs at least one input bitmap.', mfilename)
  end
  dm = length(map);
  if dm == 0,
     error(' ### %s needs (a) colormap(s).', mfilename)
  end
  if dm < imcount,                       % pad maps.
     for ii = dm + 1:imcount,
        map{ii} = map{ii - 1};
     end
  end

  dm = length(mask);
  for ii = dm + 1:imcount,
     mask{ii} = zeros(size(icon{ii}));
  end
  for ii = 1:dm,
     if ~isequal(size(icon{ii}), size(mask{ii})),
        mask{ii} = zeros(size(icon{ii}));
     end
  end
%
% Open the output file.
%
  [dpath, dfilename, dm] = fileparts(filename);      %#ok.
  filename = fullfile(dpath, [dfilename, '.ico']);

  clear dpath dfilename dm
  [fid, mess] = fopen(filename, 'w', 'ieee-le');     % little-endian.
  if fid == -1,
     error([' ### %s could not open the output file \n     ', ...
            '%s\n     %s', mfilename, filename, mess])
  end
%
% Write the signature and the number of icons to write.
%
  fwrite(fid, [0, 1, imcount], 'uint16');
%
% Write all directories. Loop over all icons.
%
  resourceoffset = imcount * 16 + 6;     % total length of directories.
  cmapsize       = zeros(1, imcount);
  ipaddedwidth   = zeros(1, imcount);
  mpaddedwidth   = zeros(1, imcount);
  bitmapsize     = zeros(1, imcount);
  resourcesize   = zeros(1, imcount);
  masksize       = zeros(1, imcount);
  dessize        = zeros(1, imcount);
  bitdepth       = zeros(1, imcount);
  height         = zeros(1, imcount);
  width          = zeros(1, imcount);
  for p = 1:imcount,
     plane = icon{p};
     bool  = IsNotIndexed(plane);
     if bool,                            % not an indexed bitmap.
        fclose(fid);
        delete(filename);
        error(' ### %s: bitmap %d is not an indexed image.', ...
              mfilename, p)
     end
     [height(p), width(p)] = size(plane);
%
% Make sure that the length of the colormap is one of these: 2^1, 2^4, 
% or 2^8. --- 2^1 does not seem to work.
%
     dmap = map{p};
     dm   = size(dmap, 1);
     if dm <= 2,
        bitdepth(p) = 4; %1; % <<===<<
     elseif dm <= 16,
        bitdepth(p) = 4;
     else
        bitdepth(p) = 8;
     end
     dessize(p) = 2^bitdepth(p);
     numofcolors = dessize(p);           % not used by Matlab but may be 
     if numofcolors > 16,                % required by other 
        numofcolors = 0;                 % applications.
     end
     if dm < dessize(p),
        map{p} = [dmap; zeros(dessize(p) - dm, 3)];
     elseif dm > dessize(p),
        map{p} = dmap(1:dessize(p), :);
     end

     headersize      = 40;  % 40 is minimum, may be larger.      
     cmapsize(p)     = dessize(p) * 4;
     ipaddedwidth(p) = ceil(width(p) / 8) * 8;   % for icons.
     mpaddedwidth(p) = ceil(width(p) / 32) * 32; % for masks.
     bitmapsize(p)   = ipaddedwidth(p) * height(p) * bitdepth(p) / 8;
     masksize(p)     = mpaddedwidth(p) * height(p) / 8;
    
     resourcesize(p) = headersize + cmapsize(p) + ...
                       bitmapsize(p) + masksize(p);

     fwrite(fid, [width(p), height(p), numofcolors, zeros(1, 5)], ...
            'uint8');
     fwrite(fid, [resourcesize(p), resourceoffset], 'uint32');  
     resourceoffset  = resourceoffset + resourcesize(p);
  end
%
% Write the resources.
%
  for p = 1:imcount,
     plane = icon{p};
%
% Bitmap header. The two longwords following HEADERSIZE are not used
% by Matlab but are required by many other applications.
%
     fwrite(fid, [headersize, width(p), height(p) * 2], 'uint32');   
%
% NUMPLANES = number of planes; details of purpose not known.
%
     numplanes = 1;
     fwrite(fid, [numplanes, bitdepth(p), 0, 0], 'uint16'); 
     fwrite(fid, [bitmapsize(p) + masksize(p), 0, 0, 0, 0], 'uint32');
%
% Color map.
%
     dmap = map{p};
     dmap = ([fliplr(floor(dmap * 255)), zeros(dessize(p), 1)])';
     fwrite(fid, dmap(:), 'uint8');
%
% Bitmap.
% 
     if isa(plane, 'double'),
        dicon = plane - 1;               % <<===<<
     else
        dicon = double(plane);
     end
     if any(dicon < 0),
        fclose(fid);
        delete(filename)
        error(' ### %s: illegal pixel(s) in bitmap no. %d', ...
               mfilename, p)          % also catches true color images.
     end
     dicon(dicon > dessize(p) - 1) = dessize(p) - 1;
     if width(p) ~= ipaddedwidth(p),
        dicon = [dicon, zeros(height(p), ...
                 ipaddedwidth(p) - width(p))]; %#ok.
     end
     
     dicon = rot90(dicon, -1);           % rotate 90 degrees clockwise.
     if bitdepth(p) == 1, 
        fwrite(fid, dicon(:), 'ubit1');
     elseif bitdepth(p) == 4,
        dicon = dicon(2:2:end) + dicon(1:2:end) * 16;
        fwrite(fid, dicon(:), 'uint8');
     else
        fwrite(fid, dicon(:), 'uint8');
     end
     dmask = double(mask{p});
     if width(p) ~= mpaddedwidth(p),
        dmask = [dmask, zeros(height(p), ...
                 mpaddedwidth(p) - width(p))]; %#ok.
     end
     dmask = reshape(dmask, 8 * height(p), mpaddedwidth(p) / 8);
     dmask = fliplr(dmask);
     dmask = reshape(dmask, height(p), mpaddedwidth(p));
     dmask = rot90(flipud(dmask));
     fwrite(fid, dmask(:), 'ubit1');
  end
  fclose(fid);
end
  
function  bool = IsNotIndexed(iniarg)
  bool = true;
  if ndims(iniarg) ~= 2,                %#ok.
     return
  end
  if isa(iniarg, 'logical'),
     iniarg = double(iniarg);
  end
  if (isa(iniarg, 'uint8') || isa(iniarg, 'uint16')),
     bool = false;
     return
  end
  if any(iniarg ~= floor(iniarg)) | any(iniarg < 1),       %#ok.
     return
  end
  bool = false;
end
% EOF Imag2Ico.
