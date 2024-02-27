      function wrista(fid   , filetype, string_mnnes,varargin)

% wrista: writes nest stations to file


% delft hydraulics                         marine and coastal management
%
% subroutine         : wrista
% version            : v1.0
% date               : June 1997
% specs last update  :
% programmer         : Theo van der Kaaij
%
% function           :switch file writes nest stations to file

last_point = 1000;
no_pnt     = size(string_mnnes,1);

%
%-----Create a 1-dimensional array
%

switch filetype
    case {'d3d','simona'}
        itel = 0;
        for i_pnt = 1: no_pnt
            for iwght = 1: 4
                itel            = itel + 1;
                name_hulp(itel) = string_mnnes{i_pnt,iwght};
%                name_hulp(itel) = string_mnnes(i_pnt,iwght);
            end
        end
        %
        %-----remove double stations and sort
        %
        name_hulp = sort(unique(name_hulp));
        switch filetype
            case {'d3d','simona'}
                % Remove first point if m = 0
                m = str2num(name_hulp{1}(10:13));
                if m == 0
                    name_hulp = name_hulp(2:end);
                end
        end
        
        %-----then remove stations already writen to file
        %     let op: eng!!!!!
        unique_station(1:length(name_hulp)) = 1;
        
        fseek (fid,0,'bof');
        tline = fgetl(fid);
        
        while ischar(tline)
            switch filetype
                case 'd3d'
                    stat_name = tline(1:19);
                case 'simona'
                    stat_name = tline(33:51);
                    last_point = sscanf(tline(2:5),'%4i');
                    
            end
            index  = strcmp(name_hulp,stat_name);
            i_stat = find(index == 1);
            if ~isempty(i_stat) unique_station(i_stat) = 0;end
            tline = fgetl(fid);
        end
        fseek (fid,0,'eof');
        
        i_tel = 0;
        for i_stat = 1: length(name_hulp)
            if unique_station(i_stat) == 1
                i_tel = i_tel + 1;
                name_xxx{i_tel} = name_hulp{i_stat};
            end
        end
%dv        name_hulp = name_xxx;
end

%
%-----finally: write resulting stations to file
%

switch filetype
    
    case 'd3d'
        for i_pnt = 1: length(name_hulp)
            [m,n] = nesthd_convertstring2mn(name_hulp{i_pnt});
            string = [name_hulp{i_pnt} ' ???? ????'];
            string (21:24) = sprintf('%4i',m);
            string (26:29) = sprintf('%4i',n);
            fprintf(fid,'%s \n',string);
        end
    case 'simona'
        for i_pnt = 1: length(name_hulp)
            [m,n] = nesthd_convertstring2mn(name_hulp{i_pnt});
            string = ['P???? =(M =???? ,N =????, NAME=','''',name_hulp{i_pnt},'''',')'];
            last_point = last_point + 1;
            string (2:5)   = sprintf('%4.4i',last_point);
            string (12:15) = sprintf('%4i',m);
            string (21:24) = sprintf('%4i',n);
            fprintf(fid,'%s \n',string);
        end
    case'dfm'
        x_nest = varargin{1};
        y_nest = varargin{2};
        for i_pnt = 1: size(string_mnnes,1)
            for i_nes = 1: 4
                if ~isempty(string_mnnes{i_pnt,i_nes})
                    fprintf(fid,'%14.9e %14.9e %s \n',x_nest(i_pnt,i_nes),y_nest(i_pnt,i_nes),char(string_mnnes{i_pnt,i_nes}));
                end
            end
        end
end