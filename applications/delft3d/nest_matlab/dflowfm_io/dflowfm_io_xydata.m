function varargout=dflowfm_io_xydata(cmd,varargin)

%DFLOWFM_IO_xydata  read/write D-Flow FM xy file or xy data file where data can be a number (depth, viscosity etc) or
%                   a string (a station name)
%
%  [LINE]        = dflowfm_io_xydata('read' ,<filename>);
%
%                  dflowfm_io_xydata('write',<filename>,LINE);
%
%   LINE(1).DATA{:,3}  contains x-coordinate, y-coordinate and z-value or string (stationname for instance)
%   LINE(:).Blckname   contains blockname (for instance the name of the crosssection or simply LINE in case of a thindam)
%
% See also: dflowfm_io_mdu

fname   = varargin{1};


%% Switch read/write

switch lower(cmd)

case 'read'

   %
   %  first try if it as an "almost normal" tekal data file
   %
   fid = fopen(fname,'r');
   try
       iblck = 0;
       while ~feof(fid)
           iblck = iblck + 1;
           tline = fgetl(fid);
           LINE(iblck).Blckname = strtrim(tline);
           tline = fgetl(fid);
           nrowcol = sscanf(tline,'%i %i');
           nrows   = nrowcol(1);
           ncols   = nrowcol(2);
           for i_row = 1: nrows
               tline = strtrim(fgetl(fid));
               index = d3d2dflowfm_decomposestr(tline);
               if length(index) == 3
                   LINE(iblck).DATA{i_row,1} = str2num(tline(index(1):index(2) - 1));
                   LINE(iblck).DATA{i_row,2} = str2num(tline(index(2):end         ));
               else
                   LINE(iblck).DATA{i_row,1} = str2num(tline(index(1):index(2) - 1));
                   LINE(iblck).DATA{i_row,2} = str2num(tline(index(2):index(3) - 1));
                   if ~isempty(str2num(tline(index(3):end)))
                       LINE(iblck).DATA{i_row,3} = str2num(tline(index(3):end));
                   else
                        LINE(iblck).DATA{i_row,3} = tline(index(3):end);
                   end
               end
           end
       end
   catch
       %
       % Probably xy, xyz or xystring data
       %
       fseek (fid,0,'bof');
       LINE  = rmfield(LINE,'Blckname');

       i_row = 0;
       while~feof(fid)
           i_row = i_row + 1;
           tline = fgetl(fid);
           index = d3d2dflowfm_decomposestr(tline);
           if isempty(str2num(tline(index(1):index(2)-1)))
               LINE.DATA{i_row,1} = tline(index(1):index(2)-1);
           else
               LINE.DATA{i_row,1} = str2num(tline(index(1):index(2)-1));
           end
           
           if length(index) == 2
               if isempty(str2num(tline(index(2):end)))
                   LINE.DATA{i_row,2} = tline(index(2):end);
               else
                   LINE.DATA{i_row,2} = str2num(tline(index(2):end));
               end
           else
               LINE.DATA{i_row,2} = str2num(tline(index(2):index(3) - 1));
               if ~isempty(str2num(tline(index(3):end)))
                   LINE(iblck).DATA{i_row,3} = str2num(tline(index(3):end));
               else
                    LINE(iblck).DATA{i_row,3} = tline(index(3):end);
               end
           end
       end
    end

   fclose(fid);

   varargout{1} = LINE;

case 'write'

   fid  =  fopen(fname,'w+');
   LINE = varargin{2};

   for iline = 1: length(LINE)

       nrows      = size(LINE(iline).DATA,1);
       ncols      = size(LINE(iline).DATA,2);

       if isfield(LINE(iline),'Blckname')

          % Comments Specified
          if isfield(LINE(iline),'Comments');
              for i_com = 1: length(LINE(iline).Comments)
                  fprintf(fid,'%s \n',LINE(iline).Comments{i_com});
              end
          end

          %Blockname specified, write blockname, nrows, ncols
          block_name = LINE(iline).Blckname;

          fprintf(fid,'%s       \n',block_name      );
          ncols = 2;
          if size(LINE(iline).DATA,2) == 3
              if isnumeric(LINE(iline).DATA{1,3})
                 ncols = 3;
              end
          end
          if ischar(LINE(iline).DATA{1,1})
              ncols = 3;
          end
          fprintf(fid,'%5i  %5i \n',nrows     , ncols);
       end

       if size(LINE(iline).DATA,2) == 3

           % xyz or xy string data
           if ischar(LINE(iline).DATA{1,3})

               % xy string data (stations for example
               for irow = 1: size(LINE(iline).DATA,1)
                   fprintf(fid,'%14.9e %14.9e %s \n',LINE(iline).DATA{irow,1},LINE(iline).DATA{irow,2},LINE(iline).DATA{irow,3});
               end
           else
               % xyz data
               for irow = 1: size(LINE(iline).DATA,1)
                   fprintf(fid,'%14.9e %14.9e %14.9e \n',LINE(iline).DATA{irow,1},LINE(iline).DATA{irow,2},LINE(iline).DATA{irow,3});
               end
           end
       else
           if ischar(LINE(iline).DATA{1,1})
               % Date Time value
               for irow = 1: size(LINE(iline).DATA,1)
                   fprintf(fid,'%s %12.4f \n',LINE(iline).DATA{irow,1},LINE(iline).DATA{irow,2});
               end
           else
               % only x and y values
               for icol = 1: nrows
                  fprintf(fid,'%14.9e  %14.9e  \n',LINE(iline).DATA{icol,1},LINE(iline).DATA{icol,2});
               end
           end
       end
   end

   fclose(fid);

end

