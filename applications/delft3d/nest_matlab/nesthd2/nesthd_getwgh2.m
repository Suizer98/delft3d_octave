      function [mnnes,weight,varargout] = nesthd_getwgh2 (fid,mnbcsp,typbnd)

      % getwgh : gets coordinates and weights from the nest administration file

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : getwgh
% version            : v1.0
% date               : June 1997
% programmer         : Theo van der Kaaij
%
% function           : Gets coordinates and weights for water level
%                      and velocity boundaries
% limitations        :
% subroutines called :
%
% Modified dd 02/04/2015 to allow for more flexible (less formatted) reading
%***********************************************************************
      mnnes  = '';
      weight = [];

      fseek (fid,0,'bof');

      switch typbnd
         case 'z'
            quantity = 'water level';
         case {'c' 'r' 'n'}
            quantity = 'velocity';
         case {'x' 'p'}
            quantity = 'velocity(t)';
      end
%
%-----cycle through administration file
%
      found = false;
      tline = fgetl(fid);
      while ischar (tline) && ~found;
          pos = strfind (tline,quantity);
          if ~isempty(pos)
             index   = strfind(tline,'"');
             if strcmp(tline(index(1)+1:index(2)-1),mnbcsp)
                found = true;
                tline = tline(index(2):end);
%
%---------------Read orientation (angle and positive inflow)
%
                if typbnd == 'c' || typbnd == 'r' || typbnd == 'x' || typbnd == 'p' || typbnd == 'n'
%-------------------old
%                   varargout{1} = strread(tline(78:86),'%9.3f')*pi/180.;
%-------------------new
                    index    = strfind(tline,'=');
                    str_temp = tline(index(1) + 1: end);
                    if typbnd == 'c' || typbnd == 'r'
                        i_end    = strfind(lower(str_temp),'posi') - 1;
                    else
                        i_end    = length(str_temp);
                    end
                    varargout{1} = sscanf(str_temp(1:i_end),'%f')*pi/180.;
                end
                if typbnd == 'r'
%------------------old
%                  varargout{2} = strread(tline(98:end),'%s');
%------------------new
                   varargout{2} = strtrim(tline(index(2) + 1: end));
                end
%
%---------------Read nesting stations and belonging weights
%
                for iwght = 1: 4
                   tline          = fgetl  (fid);
                   index         = strfind(tline,'"');
                   mnnes {iwght} = tline  (index(1)+1:index(2)-1);
                   switch typbnd
                      case {'z' 'x' 'p'}
                         weight(iwght) = sscanf (tline(index(2) + 1:end),'%f');
                      case {'c' 'r' 'n'}
                         values = sscanf(tline(index(2) + 1:end),'%f %g %g');
                         weight(iwght) = values(1);
                         x     (iwght) = values(2);
                         y     (iwght) = values(3);
                   end
                   
                end
                if typbnd == 'n'
                    varargout{3} = x;
                    varargout{4} = y;
                end
             end
          end
          tline = fgetl(fid);
      end

