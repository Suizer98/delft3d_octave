%This is a copy of dflowm_io_mdu replacing the reader of the Time block, as
%in SOBEK 3 it is a datetime format

function varargout=S3_read_md1d(cmd,varargin)

%DFLOWFM_IO_MDU  x read/write D-Dlow FM ASCII Master Definition File (*.mdu) <<beta version!>>
%
%  [DATA]        = unstruc_io_mdu('read' ,<filename>);
%
%                  unstruc_io_mdu('write',<filename>,mdu_structure);
%
%  [DATA]        = unstruc_io_mdu('new',<*.csv>)
%
% loads the template, this is a csv file with the mdu definition
%
% See also: delft3d_io_mdf

fname   = varargin{1};


%% Switch read/write/new

switch lower(cmd)

case 'read'
    scratchFile='scratch';
    try % if you have the permission to write in this dir
        simona2mdu_undress(fname,scratchFile,'comments',{'#' '*'});       %removes mdu cmments which dont belong in inifile
    catch % you don't have permission to write (e.g. MATLAB/bin/.. )
        scratchFile=[tempdir 'scratch'];
        simona2mdu_undress(fname,scratchFile,'comments',{'#' '*'});
    end
    [tmp       ] = inifile('open',scratchFile);
    delete(scratchFile);

   %
   % Create one structure
   %

   for igroup = 1: size(tmp.Data,1)
       for ipar = 1:size(tmp.Data{igroup,2},1)
            grpnam = strtrim(tmp.Data{igroup,1});
            parnam = strtrim(tmp.Data{igroup,2}{ipar,1});

            %replace spaces by underscore

            grpnam = simona2mdu_replacechar(grpnam,' ','_');
            parnam = simona2mdu_replacechar(parnam,' ','_');

            % Fill mdu structure

            if ~isempty(str2num(tmp.Data{igroup,2}{ipar,2}))
                switch parnam
                    case {'StartTime','StopTime','RestartStartTime','RestartStopTime'}
                        var = datetime(tmp.Data{igroup,2}{ipar,2},'InputFormat','yyyy-MM-dd HH:mm:ss');     
                    otherwise
                        var = str2num(tmp.Data{igroup,2}{ipar,2});
                end
            else
                var = tmp.Data{igroup,2}{ipar,2};
            end
            if isletter(parnam(1)) % first char is a letter
                mdu.(grpnam).(parnam) = var;
            else  % first char is number (not allowed in MATLAB)
                % e.g. mdu.particles.3Dtype > mdu.particles.mdu_3Dtype
                mdu.(grpnam).(['mdu_' parnam]) = var;
            end
       end
   end

   varargout  = {mdu};

case 'write'
   mdu          = varargin{2};
   mdu_Comments = varargin{3};

   %
   % Fill a temporary strucrure such hat it can be written by the function inifile
   %
   names  = fieldnames(mdu);
   maxlen = 0;

   for igroup= 1: length(names)
       tmp.Data{igroup,1} = simona2mdu_replacechar(names{igroup},'_',' ');
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars);
           tmp2{ipar,1} = simona2mdu_replacechar(pars{ipar},'_',' ');
           if  strcmpi(tmp2{ipar,1},'wall ks') tmp2{ipar,1} = simona2mdu_replacechar(tmp2{ipar,1},' ','_'); end           
            switch tmp2{ipar,1}
                case {'StartTime','StopTime','RestartStartTime','RestartStopTime'}
%                     line = datestr(mdu.(names{igroup}).(pars{ipar}),'yyyy-MM-dd HH:mm:ss');
                    line = datestr(mdu.(names{igroup}).(pars{ipar}),'yyyy-mm-dd HH:MM:ss');
                otherwise
                    if ~isempty(num2str(mdu.(names{igroup}).(pars{ipar})))
                        line = num2str(mdu.(names{igroup}).(pars{ipar})) ;
                    else
                        line = mdu.(names{igroup}).(pars{ipar});
                    end
            end

           maxlen = max(maxlen,length(line) + 1);
%            line(40:c = ['# ' mdu_Comments.(names{igroup}).(pars{ipar})];
            tmp2{ipar,2} = line;
       end
       tmp.Data{igroup,2} = tmp2;
       clear tmp2
   end

   %% add comments
   for igroup = 1: length(names)
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars)
           line = tmp.Data{igroup,2}{ipar,2};
           if isempty(line); clear line; line = ''; end
           while length(line) < maxlen + 4
               line(end + 1) = ' ';
           end
           if ~isnan(mdu_Comments)
            line(maxlen + 5:maxlen + length(mdu_Comments.(names{igroup}).(pars{ipar})) + 6) = ['# ' mdu_Comments.(names{igroup}).(pars{ipar})];
           else
               line(maxlen + 5:maxlen + 2 +6) = ['#   ' ];
           end
           tmp.Data{igroup,2}{ipar,2} = line;
       end
   end

   inifile ('write',fname,tmp);

case 'new'
    %
    % Read csv file with mdu definition (used by GUI)
    % Replace space "external forcings" into underscore
    %
    tmp = simona2mdu_csvread(fname,'skiplines','*#');
    tmp(:,1) = simona2mdu_replacechar(tmp(:,1),' ','_');

    %
    % Get Groupnames
    %

    index_org = strncmpi('MduGroup',tmp(:,1),7);
    itel = 1;
    for i_ind = 1 : length(index_org)
        if index_org(i_ind) == 1
            index(itel) = i_ind;
            itel        = itel + 1;
        end
    end

    for igrp = index(1) + 1: index(2) - 1
        grpnam{igrp - index(1)} = tmp{igrp,1};
    end

    %
    % Get parameter names and their values and put in the mdu struct
    %

    for irow = index(2) + 1: size(tmp,1)
        for igrp = 1: length(grpnam)
            if strcmp(tmp{irow,1},grpnam{igrp})
                if ischar(tmp{irow,6})
                    if strcmpi(tmp{irow,6},'true')  tmp{irow,7} = 1;end
                    if strcmpi(tmp{irow,6},'false') tmp{irow,7} = 0;end
                end
                mdu.(grpnam{igrp}).(tmp{irow,2}) = tmp{irow,7};
                comment = '';
                for icol = 15: size(tmp,2)
                    if ~isempty (tmp{irow,icol})
                        comment = [comment ', ' char(tmp{irow,icol})];
                    end
                end
                mdu_Comment.(grpnam{igrp}).(tmp{irow,2}) = strtrim(comment(2:end));
            end
        end
    end

    varargout = {mdu,mdu_Comment};

end

