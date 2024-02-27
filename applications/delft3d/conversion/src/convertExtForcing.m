%%% Clear screen and ignore warnings

clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the ext file name has been specified (D-Flow FM)
fileext     = get(handles.edit10,'String');
if isempty(fileext);
    if exist('wb'); close(wb); end;
    errordlg('The external forcings file name has not been specified.','Error');
%     break;
end
if length(fileext) > 4;
    if strcmp(fileext(end-3:end),'.ext') == 0;
        if exist('wb'); close(wb); end;
        errordlg('The external forcings file name has an improper extension.','Error');
%         break;
    end
end



%%% WRITE HEADER OF THE EXT FORCINGS FILE

% Put the output directory name in the filenames
fileext     = [pathout,'\',fileext];

% Write header
convertExtForcingHeader;

% Catch the polyline names for the boundary conditions
filepli     = get(handles.listbox1,'String');
npli        = size(filepli,1);
japli       = 1;
if strcmpi(filepli,' '); 
    japli   = 0;
end

% Check if salinity and/or temperature is active
filebcc     = get(handles.edit14,'String');
filebcc     = deblank2(filebcc);
jasal       = 1;
if isempty(filebcc);
    jasal   = 0;
end


%%% READ POLYLINE FILES AND CHECK BOUNDARY CONDITIONS TYPE

% Loop over all the boundary pli-files
if japli == 1;
    for i=1:npli;
        fileplistr              = cell2mat(filepli(i,:));
        fpli                    = [pathout,'\',fileplistr];
        if strcmpi(fpli(end-7:end),'_sal.pli');
            if jasal == 1;
                typ             = 'salinitybnd';
            else
                break;
            end
        elseif strcmpi(fpli(end-7:end),'_tem.pli');
            if jasal == 1;
                typ             = 'temperaturebnd';
            else
                break;
            end            
        else
            fid                 = fopen(fpli,'r');
            tline               = fgetl(fid);
            tline               = fgetl(fid);
            tline               = fgetl(fid);
            tline               = textscan(tline,'%s%s%s%s%s');
            tlinestr            = tline{3}{1};
            switch tlinestr;
                case 'Z';
                    typ  = 'waterlevelbnd';
                case 'C';
                    typ  = 'velocitybnd';
                case 'N';
                    typ  = 'neumannbnd';
                case 'Q';
                    typ  = 'dischargebnd';
                    warndlg('Option dischargepergridcellbnd is not yet supported by this converter. Hence, boundary is depicted as dischargebnd.','Warning');
                case 'T';
                    typ  = 'dischargebnd';
                case 'R';
                    typ  = 'riemannbnd';
                    warndlg('Option riemannbnd is not supported yet by D-Flow FM.','Warning');
            end
        end
        fprintf(fidext,['QUANTITY='  ,typ         ,'\n']);
        fprintf(fidext,['FILENAME='  ,fileplistr  ,'\n']);
        fprintf(fidext,['FILETYPE=9'              ,'\n']);
        fprintf(fidext,['METHOD  =3'              ,'\n']);
        fprintf(fidext,['OPERAND =O'              ,'\n']);
        fprintf(fidext,[                          ,'\n']);
    end
end
fclose all;