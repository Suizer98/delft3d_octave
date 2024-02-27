%$Revision: 18337 $
%$Date: 2022-08-26 17:49:07 +0800 (Fri, 26 Aug 2022) $
%$Author: kaaij $
%$Id: dflowfm_io_mdu.m 18337 2022-08-26 09:49:07Z kaaij $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/nest_matlab/dflowfm_io/dflowfm_io_mdu.m $

function varargout=dflowfm_io_mdu(cmd,varargin)

%DFLOWFM_IO_MDU  x read/write D-Dlow FM ASCII Master Definition File (*.mdu) <<beta version!>>
%
%  [DATA]        = unstruc_io_mdu('read' ,<filename>);
%
%                  unstruc_io_mdu('write',<filename>,mdu_structure,mdu_Comments);
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
    scratchFile=strrep(sprintf('scratch_%18.17f',datenum(datetime('now'))+rand),'.',''); %if you call <dflowfm_io_mdu> twice at the same time running in the same folder, using the same name causes failure
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
            val_raw=tmp.Data{igroup,2}{ipar,2};
            val_num=str2double(val_raw);
            if isnan(val_num) %it is a character
                val=val_raw;
            else %it is a number
                if strcmp(parnam,'FileVersion') %treat as string
                    val=val_raw;
                else %treat as number
                    val = str2double(val_raw);
                end
            end

            if isempty(parnam) %input to previous parameter is in several lines
                %                 e.g.
                % ObsFile = file1.xyn   \
                %           file2.xyn   \
                mdu.(grpnam).(parnam_prev) = [mdu.(grpnam).(parnam_prev)(:)',{val}];
            elseif isletter(parnam(1)) % first char is a letter
                mdu.(grpnam).(parnam) = val;
                parnam_prev=parnam;
            else  % first char is number (not allowed in MATLAB)
                % e.g. mdu.particles.3Dtype > mdu.particles.mdu_3Dtype
                mdu.(grpnam).(['mdu_' parnam]) = val;
                parnam_prev=parnam;
            end
       end
   end

   varargout  = {mdu};

case 'write'
   mdu          = varargin{2};
   if numel(varargin)>2
       isComments=true;
       mdu_Comments = varargin{3};
   else
       isComments=false;
   end

   %
   % Fill a temporary strucrure such hat it can be written by the function inifile
   %
   names  = fieldnames(mdu);
   maxlen = 0;

   %when writing a file read with delft3d_io_sed, the block names have a number.
   %Here we remove it

    ngroup=numel(names);
    names_clean=cell(ngroup,1);
    for kb=1:ngroup
        tok=regexp(names{kb,1},'\d','split');
        names_clean{kb,1}=tok{1,1};
    end %kb

   for igroup=1:ngroup
       tmp.Data{igroup,1} = simona2mdu_replacechar(names_clean{igroup},'_',' ');
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars)
           tmp2{ipar,1}=pars{ipar};
           val=mdu.(names{igroup}).(pars{ipar});
           if strcmp(class(val),'Delft3D')

           else
               if iscell(val)
                   line=sprintf('%s ',val{:});
                   line=strrep(line,' \ ',''); %a bar may have been used to seprate input in several lines
               elseif isa(val,'double')
                   line = num2str(val);
               else
                    if strcmp(tmp2{ipar,1},'Name') && strcmp(names_clean{igroup},'Sediment')
                        line=sprintf('#%s#',val);
                    else
                        line = val;
                    end


               end
               maxlen = max(maxlen,length(line) + 1);
               tmp2{ipar,2} = line;
           end
       end
       tmp.Data{igroup,2} = tmp2;
       clear tmp2
   end

   %% add comments
   if isComments
   for igroup = 1: length(names)
       pars = fieldnames(mdu.(names{igroup}));
       for ipar = 1: length(pars)
           line = tmp.Data{igroup,2}{ipar,2};
           if isempty(line); clear line; line = ''; end
           while length(line) < maxlen + 4
               line(end + 1) = ' ';
           end
           line(maxlen + 5:maxlen + length(mdu_Comments.(names{igroup}).(pars{ipar})) + 6) = ...
           ['# ' mdu_Comments.(names{igroup}).(pars{ipar})];
       end
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

