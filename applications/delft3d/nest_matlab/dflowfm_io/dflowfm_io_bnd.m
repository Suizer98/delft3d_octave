function varargout=dflowfm_io_bnd(cmd,fname,varargin)

%  DFLOWFM_IO_bnd : reads or writes pli files
%% Switch read/write

switch lower(cmd)

    %% Extract boundary information from the pli's
    case 'read'
        [~,fileType] = EHY_getTypeOfModelFile(fname);
        switch fileType
            case 'pli'
                filelist{1} = fname;
                bndtype{1}  = 'z';
            otherwise

                %% Create list of pli files out of the ext file or the mdu file
                [path,~,~] = fileparts(fname);
                switch fileType
                    case 'mdu'
                        mdu = dflowfm_io_mdu(fname);
                        if isfield(mdu.external_forcing,'ExtForceFileNew') && ~isempty(mdu.external_forcing.ExtForceFileNew)
                            fname = [path filesep mdu.external_forcing.ExtForceFileNew];
                        else
                            fname = [path filesep mdu.external_forcing.ExtForceFile];
                        end
                end

                ext     = dflowfm_io_extfile('read',fname);
                
                %% new inifile format (covert to old structure, remainder of the past)
                if isfield(ext,'Chapter')
                    for i_ext = 1: length(ext)
                        ext(i_ext).quantity     = 'notExisting';
                        ext(i_ext).locationfile = 'notExisting';
                        names                   = ext(i_ext).Keyword.Name;
                        i_val                   = get_nr(lower(names),'quantity');
                        if ~isempty (i_val); ext(i_ext).quantity     = ext(i_ext).Keyword.Value{i_val}; end
                        i_val                   = get_nr(lower(names),'locationfile');
                        if ~isempty (i_val); ext(i_ext).locationfile = ext(i_ext).Keyword.Value{i_val}; end
                    end
                end
                
                %% Get names of pli files for which boundary conditions should be generated
                allowedVars = {'waterlevel','normalvelocity','velocity','neumann','uxuyadvectionvelocitybnd'};
                i_file  = 0;
                for i_ext = 1: length(ext)
                    if ~isfield(ext(i_ext),'Chapter') || (isfield(ext(i_ext),'Chapter') && strcmpi(ext(i_ext).Chapter,'boundary'))
                        if ~isempty(strfind(ext(i_ext).quantity,'bnd'        )) && ~isempty(find(~cellfun('isempty',regexp(ext(i_ext).quantity,allowedVars))))
                            
                            i_file = i_file + 1;
                            if ~isempty(path)
                                if isfield(ext(i_ext),'filename')
                                    if ~isabsolutepath(ext(i_ext).filename)
                                        filelist{i_file} = [path filesep ext(i_ext).filename];
                                    else
                                        filelist{i_file} = ext(i_ext).filename;
                                    end
                                elseif isfield(ext(i_ext),'locationfile')
                                    if ~isabsolutepath(ext(i_ext).locationfile)
                                        filelist{i_file} = [path filesep ext(i_ext).locationfile];
                                    else
                                        filelist{i_file} = ext(i_ext).locationfile;
                                    end
                                end
                            else
                                if isfield(ext(i_ext),'filename')
                                    filelist{i_file} = [ext(i_ext).filename];
                                elseif isfield(ext(i_ext),'locationfile')
                                    filelist{i_file} = [ext(i_ext).locationfile];
                                end
                            end
                            
                            if ~isempty(strfind(ext(i_ext).quantity,'waterlevel'))
                                bndtype{i_file} = 'z';
                            elseif ~isempty(strfind(ext(i_ext).quantity,'velocity')) && isempty(strfind(ext(i_ext).quantity,'normalvelocity')) ...
                                    && isempty(strfind(ext(i_ext).quantity,'uxuyadvectionvelocitybnd'))
                                bndtype{i_file} = 'c';
                            elseif ~isempty(strfind(ext(i_ext).quantity,'neumann'))
                                bndtype{i_file} = 'n';
                            elseif ~isempty(strfind(ext(i_ext).quantity,'uxuyadvectionvelocitybnd'))
                                bndtype{i_file} = 'p';
                            end
                        end
                    end
                end
        end

        %% Get the name of the pli and the (x,y) coordinate pairs
        no_bnd = 0;
        for i_file = 1: length(filelist)
            [~,name,~] = fileparts(filelist{i_file});
            tmp = dflowfm_io_xydata('read',filelist{i_file});
            X        = cell2mat(tmp.DATA(:,1));
            Y        = cell2mat(tmp.DATA(:,2));
            for i_pnt = 1: length(X)
               no_bnd            = no_bnd + 1;
               out.DATA(no_bnd).X        = X(i_pnt);
               out.DATA(no_bnd).Y        = Y(i_pnt);
               out.DATA(no_bnd).bndtype  = bndtype{i_file};
               out.DATA(no_bnd).datatype = 't';
               if size(tmp.DATA,2) == 3
                   out.Name{no_bnd}      = tmp.DATA{i_pnt,3};
               else
                   if ~isfield(tmp,'Blckname')
                       out.Name{no_bnd}      = [name '_' num2str(i_pnt,'%4.4i')];
                   else
                       out.Name{no_bnd}      = [tmp.Blckname '_' num2str(i_pnt,'%4.4i')];
                   end
               end
               out.FileName{no_bnd} = name;
            end
        end

        varargout = {out};

    case 'write'

        %% To implement
end

function trueorfalse = isabsolutepath(fname)

%% returns true if fname contains absolute path, false if it is a relative path

trueorfalse = false; % relative path
if strcmp(fname(2),':') || strcmp(fname([1 3]),[filesep filesep]) % e.g. Windows: C:\.. or Unix: /p/..
    trueorfalse = true; % absolute path
end
