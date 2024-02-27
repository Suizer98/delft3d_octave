% private function for ddb_NestingToolbox_DFlowFM_Fews
function ddb_NestingToolbox_Change_Dimr(modeldir, dflowfmname, wavename, tstart, dt, tend)

% Define dimr config
fid = fopen([modeldir, 'dimr_config.xml'], 'rt') ;
X   = fread(fid) ;
fclose(fid) ;
X = char(X.') ;

% Replace start time
text_to_search  = 'TTSTART';
text_to_replace = ['', num2str(tstart), '.0'];
X = strrep(X, text_to_search, text_to_replace) ;    % replace string S1 with string S2

% Replace update interval
text_to_search  = 'TTDT';
text_to_replace = ['', num2str(dt), '.0'];
X = strrep(X, text_to_search, text_to_replace) ;    % replace string S1 with string S2

% Replace end time
%         timeneeded      = (tend - tstart) * 24 * 60 * 60;
timeneeded = tend;
text_to_search  = 'TTEND';
text_to_replace = ['', num2str(timeneeded), '.0'];
X = strrep(X, text_to_search, text_to_replace) ;    % replace string S1 with string S2

% Replace mdu name
text_to_search  = 'MDUNAME';
X = strrep(X, text_to_search, dflowfmname) ;    % replace string S1 with string S2

% Replace mdw name
text_to_search  = 'MDWNAME';
X = strrep(X, text_to_search, wavename) ;    % replace string S1 with string S2

% Save DIMR
fid2 = fopen([modeldir, 'dimr_config.xml'],'wt') ;
fwrite(fid2,X) ;
fclose (fid2) ;
fclose('all');  