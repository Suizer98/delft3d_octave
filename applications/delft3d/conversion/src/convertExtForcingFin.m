%%% Clear screen and ignore warnings

fclose all;
clc;
warning off all;


%%% STANDARD GUI CHECK ON DIRECTORIES

convertGuiDirectoriesCheck;


%%% GUI CHECKS

% Check if the ext file name has been specified (D-Flow FM)
extfile     = deblank2(get(handles.edit10,'String'));
if isempty(extfile);
    if exist('wb'); close(wb); end;
    errordlg('The external forcings file name has not been specified.','Error');
%     break;
end

% Check if the roughness file name has been specified (D-Flow FM)
wndfile     = deblank2(get(handles.edit33,'String'));
jawnd       = 1;
if isempty(wndfile);
    wndfile = [];
    jawnd   = 0;
end

% Check if the roughness file name has been specified (D-Flow FM)
spwfile     = deblank2(get(handles.edit35,'String'));
jaspw       = 1;
if isempty(spwfile);
    spwfile = [];
    jaspw   = 0;
end

% Check if the roughness file name has been specified (D-Flow FM)
rghfile     = deblank2(get(handles.edit24,'String'));
jargh       = 1;
if isempty(rghfile);
    rghfile = [];
    jargh   = 0;
end

% Check if the viscosity file name has been specified (D-Flow FM)
visfile     = deblank2(get(handles.edit25,'String'));
javis       = 1;
if isempty(visfile);
    visfile = [];
    javis   = 0;
end

% Check if the initial conditions file name has been specified (D-Flow FM)
inifile     = deblank2(get(handles.edit28,'String'));
jaini       = 1;
if isempty(inifile);
    inifile = [];
    jaini   = 0;
end

% Couple to path
extfile     = [pathout,'\',extfile];


%%% CHECK IF THE EXT FILE HAS BEEN FINALIZED PREVIOUSLY

fidext      = fopen(extfile,'r');
while ~feof(fidext);
    tline                 = fgetl(fidext);
    if length(tline) >= 9;
        if strcmpi(tline(1:9),'QUANTITY=');
            if strcmpi(tline(10:end),'frictioncoefficient');
                jargh     = 0;
            end
            if strcmpi(tline(10:end),'horizontaleddyviscositycoefficient');
                javis     = 0;
            end
            if strcmpi(tline(10:end),'initialwaterlevel');
                jaini     = 0;
            end
        end
    end
end


%%% APPEND NEW DATA TO THE ALREADY EXISTING EXT FILE

fidext      = fopen(extfile,'at+');
if jawnd == 1;
    fprintf(fidext,['QUANTITY=' ,'windxy'                            ,'\n']);
    fprintf(fidext,['FILENAME=' ,wndfile                             ,'\n']);
    fprintf(fidext,['FILETYPE=2','\n']);
    fprintf(fidext,['METHOD  =1','\n']);
    fprintf(fidext,['OPERAND =O','\n']);
    fprintf(fidext,[            ,'\n']);
end
if jaspw == 1 & jawnd == 0;
    fprintf(fidext,['QUANTITY=' ,'airpressure_windx_windy'           ,'\n']);
    fprintf(fidext,['FILENAME=' ,spwfile                             ,'\n']);
    fprintf(fidext,['FILETYPE=5','\n']);
    fprintf(fidext,['METHOD  =1','\n']);
    fprintf(fidext,['OPERAND =O','\n']);
    fprintf(fidext,[            ,'\n']);
end
if jargh == 1;
    fprintf(fidext,['QUANTITY=' ,'frictioncoefficient'               ,'\n']);
    fprintf(fidext,['FILENAME=' ,rghfile                             ,'\n']);
    fprintf(fidext,['FILETYPE=7','\n']);
    fprintf(fidext,['METHOD  =5','\n']);
    fprintf(fidext,['OPERAND =O','\n']);
    fprintf(fidext,[            ,'\n']);
end
if javis == 1;
    fprintf(fidext,['QUANTITY=' ,'horizontaleddyviscositycoefficient','\n']);
    fprintf(fidext,['FILENAME=' ,visfile                             ,'\n']);
    fprintf(fidext,['FILETYPE=7','\n']);
    fprintf(fidext,['METHOD  =5','\n']);
    fprintf(fidext,['OPERAND =O','\n']);
    fprintf(fidext,[            ,'\n']);
end
if jaini == 1;
    fprintf(fidext,['QUANTITY=' ,'initialwaterlevel'                 ,'\n']);
    fprintf(fidext,['FILENAME=' ,inifile                             ,'\n']);
    fprintf(fidext,['FILETYPE=7','\n']);
    fprintf(fidext,['METHOD  =5','\n']);
    fprintf(fidext,['OPERAND =O','\n']);
    fprintf(fidext,[            ,'\n']);
end
fclose all;


%%% CHECK SIMULATEOUS WIND USE 

if jawnd == 1 & jaspw == 1;
    errordlg('Simultaneous use of unimagdir wind and spiderweb wind not supported by D-Flow FM yet. Only unimagdir wind written to .ext file.','Error');
%     continue;
end