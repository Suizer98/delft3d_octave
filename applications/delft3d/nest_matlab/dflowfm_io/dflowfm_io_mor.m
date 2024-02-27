function varargout=dflowfm_io_mor(cmd,varargin)

%DFLOWFM_IO_MOR  x read/write D-Dlow FM ASCII Morphology Definition File (*.mor) <<beta version!>>
%
%  [DATA]        = unstruc_io_mor('read' ,<filename>);
%
%                  unstruc_io_mor('write',<filename>,mor_structure);
%
%  [DATA]        = unstruc_io_mor('new',<*.csv>)
%
% loads the template, this is a csv file with the mor definition
%
% Marlies van der Lugt 6/11/2019
%
% See also: dflowfm_io_mdu

warning('use dflowfm_io_mdu')

fname   = varargin{1};


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

            % Fill mor structure
            temp = tmp.Data{igroup,2}{ipar,2};
            temp = strsplit(temp);
            if ~isempty(str2double(temp{1})) && ~isnan(str2double(temp{1}))
                var = str2double(temp{1});
            else
                var = temp{1};
            end
            if isletter(parnam(1)) % first char is a letter
                mor.(grpnam).(parnam) = var;
            else  % first char is number (not allowed in MATLAB)
                % e.g. mdu.particles.3Dtype > mdu.particles.mdu_3Dtype
                mor.(grpnam).(['mor_' parnam]) = var;
            end
       end
   end

   varargout  = {mor};
   
   case 'write'
       fprintf('TO DO\n')
       
   case 'new'
      fprintf('TO DO\n')
end