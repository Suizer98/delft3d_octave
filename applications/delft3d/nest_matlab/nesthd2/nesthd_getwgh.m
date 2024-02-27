      function [mnes,nnes,weight,varargout] = nesthd_getwgh (fid,mcbsp ,ncbsp ,typbnd)

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
      mnes   = [];
      nnes   = [];
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
%------------old
%            m = strread(tline(60:63),'%4d');
%            n = strread(tline(65:68),'%4d');
%------------new
             s_equal = strfind(tline,'=');
             str_temp = tline(s_equal(1) + 1: end);
             i_start = strfind(str_temp,'(') + 1;
             i_end   = strfind(str_temp,',') - 1;
             m       = sscanf (str_temp(i_start:i_end),'%i');
             i_start = i_end + 2;
             i_end   = strfind(str_temp,')') - 1;
             n       = sscanf (str_temp(i_start:i_end),'%i');

             if m == mcbsp && n == ncbsp
                found = true;
%
%---------------Read orientation (angle and positive inflow)
%
                if typbnd == 'c' || typbnd == 'r' || typbnd == 'x' || typbnd == 'p' || typbnd == 'n'
%-------------------old
%                   varargout{1} = strread(tline(78:86),'%9.3f')*pi/180.;
%-------------------new
                    str_temp = tline(s_equal(2) + 1: end);
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
                   varargout{2} = strtrim(tline(s_equal(3) + 1: end));
                end
%
%---------------Read nesting stations and belonging weights
%
                for iwght = 1: 4
                   switch typbnd
                      case {'z' 'x' 'p'}
                         [values] = fscanf(fid,'%d %d %f',3);
                      case {'c' 'r' 'n'}
                         [values] = fscanf(fid,'%d %d %f %g %g',5);
                         x(iwght) = values(4);
                         y(iwght) = values(5);
                   end
                   mnes(iwght)   = values(1);
                   nnes(iwght)   = values(2);
                   weight(iwght) = values(3);
                end
                if typbnd == 'n'
                    varargout{3} = x;
                    varargout{4} = y;
                end
             end
          end
          tline = fgetl(fid);
      end

