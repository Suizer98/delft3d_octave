      function [Colinfo] = get_Colinfo (Comments,no_cols)

      % get_Colinfo : Gets column information from a tekal file

      %
      % Get Column information from the Comment lines
      %
      no_col = 0;
      Comhlp =  lower (Comments);
      %
      % Search for Column
      %
      irec = strfind (Comhlp,'column');
      %
      % If comumn not found search for Kolom
      %
      empty = true;
      for icol = 1: length(irec)
          if ~isempty(irec{icol})
              empty = false;
          end
      end

      if empty
         irec = strfind(Comhlp,'kolom');
      end
      %
      % Fill Colinfo cell array and sort
      %
      for icom = 1: length(irec)
          if ~isempty(irec{icom})
              no_col = no_col + 1;
              Colinfo{no_col,1} = Comments{icom}(irec{icom}:end);
              istart = irec{icom};
              while isempty(str2num(Comments{icom}(istart:istart)));
                  istart = istart + 1;
              end

              iend   = istart;

              while ~isempty(str2num(Comments{icom}(iend:iend)));
                  iend = iend + 1;
              end
              iend = iend - 1;
              Colinfo{no_col,2} = str2double(Comments{icom}(istart:iend));
          end
      end
      %
      % No Comments starting with Column or Kolom found
      %
      if ~exist('Colinfo','var')
         for icol = 1: no_cols
             Colinfo{icol,1} = sprintf('Column %2i',icol);
             Colinfo{icol,2} = icol;
         end
      end
