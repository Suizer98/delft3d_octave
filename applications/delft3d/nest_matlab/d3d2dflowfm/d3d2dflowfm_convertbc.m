function varargout = d3d2dflow_convertbc(filinp,filpli,path_output,varargin)

%% Determine type of forcing for which conversion is requested,
%% First check the additional input arguments, secondly by using the file extension
OPT.Astronomical = false;
OPT.Harmonic     = false;
OPT.Series       = false;
OPT.Salinity     = false;
OPT.Temperature  = false;
OPT.Correction   = '';
OPT.Sign         = false;
OPT.Thick        = 100.;

if ~isempty(varargin)
    OPT = setproperty(OPT,varargin);
else
    if ~isempty(filinp)
        [~,~,extension] = fileparts(filinp);
        if strcmp(extension,'.bca') OPT.Astronomical = true; end
        if strcmp(extension,'.bch') OPT.Harmonic     = true; end
        if strcmp(extension,'.bct') OPT.Series       = true; end
    end
end

if OPT.Salinity || OPT.Temperature
    OPT.Series = true;
end

%% Read the forcing data
if OPT.Astronomical         bca    = delft3d_io_bca('read',filinp)        ;end
if OPT.Harmonic             bch    = delft3d_io_bch('read',filinp)        ;end
if OPT.Series               bct    = ddb_bct_io    ('read',filinp)        ;end
if ~isempty(OPT.Correction) cor    = delft3d_io_bca('read',OPT.Correction);end

if OPT.Harmonic
    freq    = bch.frequencies(2:end);
    freq    = 60*360./freq;            % Convert from degrees/hr ==> minutes
    no_freq = length(freq);
    a0      = bch.a0;
    amp     = bch.amplitudes;
    phases  = bch.phases;
end

%% Cycle over the pli's
i_output = 0;
for i_pli = 1: length(filpli)
    LINE = dflowfm_io_xydata('read',filpli{i_pli});
    for i_pnt = 1: size(LINE.DATA,1)
        SERIES   = [];
        i_output = i_output + 1;

        %% Get the type of forcing for this point
        if size(LINE.DATA,2) == 3
            index =  d3d2dflowfm_decomposestr(LINE.DATA{i_pnt,3});
        else
            continue
        end
        
        sign = str2num(LINE.DATA{i_pnt,3}(index(end-1):index(end) - 1));
        if OPT.Salinity || OPT.Temperature
            b_type  = 't';
        else
            b_type = lower(strtrim(LINE.DATA{i_pnt,3}(index(2):index(3) - 1)));
        end

        switch b_type

            %% Astronomical boundary forcing
            case 'a'
                if OPT.Astronomical
                    %% Filename with astronomical bc
                    filename{i_output} = [path_output filesep LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.cmp'];

                    %% Put General information in Series struct
                    SERIES.Comments{1} = '* COLUMNN=3';
                    SERIES.Comments{2} = '* COLUMN1=Astronomical Componentname';
                    SERIES.Comments{3} = '* COLUMN2=Amplitude (ISO)';
                    SERIES.Comments{4} = '* COLUMN3=Phase (deg)';

                    %% Find correct label and write names, amplitudes and phases
                    pntname  = strtrim(LINE.DATA{i_pnt,3}(index(3):index(4) - 1));
                    for i_bca=1:length(bca.DATA);
                        if strcmp(pntname,bca.DATA(i_bca).label);
                            for i_cmp=1:length(bca.DATA(i_bca).names);
                                SERIES.Values {i_cmp,1} = char(bca.DATA(i_bca).names{i_cmp});
                                SERIES.Values {i_cmp,2} = sign*bca.DATA(i_bca).amp(i_cmp);
                                SERIES.Values {i_cmp,3} = bca.DATA(i_bca).phi(i_cmp);
                            end
                            break
                        end
                    end

                    %% Include correcion from the *.cor file
                    if ~isempty (OPT.Correction)
                        for i_cor = 1: length(cor.DATA)
                            if strcmp(pntname,cor.DATA(i_cor).label)
                                for i_cmp = 1: size (SERIES.Values,1)
                                    for i_cmp_cor = 1: length(cor.DATA(i_cor).names)
                                        if strcmp(SERIES.Values{i_cmp,1},cor.DATA(i_cor).names{i_cmp_cor})
                                            SERIES.Values{i_cmp,2} = SERIES.Values{i_cmp,2} *  cor.DATA(i_cor).amp(i_cmp_cor);
                                            SERIES.Values{i_cmp,3} = SERIES.Values{i_cmp,3} +  cor.DATA(i_cor).phi(i_cmp_cor);
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
               end

            %% Harmonic boundary forcing
            case 'h'
                if OPT.Harmonic
                    %% Filename with harmonic bc
                    if ~isempty(path_output)
                        filename{i_output} = [path_output filesep LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.cmp'];
                    else
                        filename{i_output} = [LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.cmp'];
                    end

                    %% Write some general information
                    SERIES.Comments{1} = '* COLUMNN=3';
                    SERIES.Comments{2} = '* COLUMN1=Period (min)';
                    SERIES.Comments{3} = '* COLUMN2=Amplitude (ISO)';
                    SERIES.Comments{4} = '* COLUMN3=Phase (deg)';

                    %% Find harmonic boundary number and side
                    i_harm = str2num(LINE.DATA{i_pnt,3}(index(3):index(3) + 3));
                    if strcmpi      (LINE.DATA{i_pnt,3}(end -2  :end -2),'a');
                        i_side = 1;
                    else
                        i_side = 2;
                    end

                    %% Write harmonic data to forcing file
                    SERIES.Values(1,1) = 0.0;
                    SERIES.Values(1,2) = sign*a0(i_side,i_harm);
                    SERIES.Values(1,3) = 0.0;

                    for i_freq = 1:no_freq
                        SERIES.Values(i_freq+1,1) = freq(i_freq);
                        SERIES.Values(i_freq+1,2) = sign*amp (i_side,i_harm,i_freq);
                        SERIES.Values(i_freq+1,3) = phases (i_side,i_harm,i_freq);
                    end
                    SERIES.Values = num2cell(SERIES.Values);
                end

            %% Time series forcing data
            case 't'
                if OPT.Series
                    if ~isempty(path_output)
                        filename{i_output} = [path_output filesep LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.tim'];
                    else
                        filename{i_output} = [LINE.Blckname '_' num2str(i_pnt,'%0.4d') '.tim'];
                    end

                    %% Find Time series table number
                    bndname = strtrim(LINE.DATA{i_pnt,3}(index(3):index(end - 1) - 1));
                    side    = bndname(end:end);
                    bndname = bndname(1:end-5);
                    nr_table = [];
                    for i_table = 1: bct.NTables
                        name_bct = bct.Table(i_table).Location;
                        quan_bct = bct.Table(i_table).Parameter(2).Name;
                        quan_bct = sscanf(quan_bct,'%s');
                        if OPT.Salinity
                            if strcmp(strtrim(bndname),strtrim(name_bct)) && strcmpi(quan_bct(1:8 ),'Salinity')
                                nr_table = i_table;
                                break
                            end
                        elseif OPT.Temperature
                            if strcmp(strtrim(bndname),strtrim(name_bct)) && strcmpi(quan_bct(1:11),'Temperature')
                                nr_table = i_table;
                                break
                            end
                        else
                            if strcmp(strtrim(bndname),strtrim(name_bct))
                                nr_table = i_table;
                                break
                            end
                        end
                    end

                    %% Misuse kmax to adress the correct columns (for averaging in case of step/linear/3d-profile)
                    if strcmpi(bct.Table(nr_table).Contents,'step') || strcmpi(bct.Table(nr_table).Contents,'linear')
                        kmax = 2;
                    else
                        % Uniform/Logarithmic/3D-Profile
                        kmax = floor(size(bct.Table(nr_table).Data,2) - 1) / 2;
                    end

                    %% Fill series array
                    %  First: Time in minutes
                    SERIES.Values(:,1) = bct.Table(nr_table).Data(:,1);
                    quan_bct           = bct.Table(nr_table).Parameter(2).Name;
                    quan_bct           = sscanf(quan_bct,'%s');
                                        
                    Values_A = bct.Table(nr_table).Data(:,2       :2        + (kmax - 1));
                    Values_B = bct.Table(nr_table).Data(:,2 + kmax:2 + kmax + (kmax - 1));
                                                 
                    % Then: Values (for now generate the depth averaged values)
                    if (~isempty(strfind(quan_bct,'Current')) || OPT.Salinity || OPT.Temperature) && kmax > 1
                        for i_time = 1: size(Values_A,1)
                            Values_A(i_time,:) = (OPT.Thick/100.).*Values_A(i_time,:);
                            Values_B(i_time,:) = (OPT.Thick/100.).*Values_B(i_time,:);
                            if ~isempty(strfind(quan_bct,'Current'))
                                 Values_A(i_time,:) = sign*Values_A(i_time,:);
                                 Values_B(i_time,:) = sign*Values_B(i_time,:);
                            end
                        end
                    end
                    
                    if contains(quan_bct,'totaldischarge') && ~OPT.Salinity && ~OPT.Temperature
                        Values_A= sign*Values_A;
                    end
                    
                    if strcmpi      (side,'a')                                      %end A
                        SERIES.Values(:,2)      = sum(Values_A,2);
                    else                                                            %end B
                        SERIES.Values(:,2)      = sum(Values_B,2);
                        % Total discharge boundary, side B = -999 in bct file but not used!
                        if floor(mean(abs(SERIES.Values(:,2)))) == 999
                            SERIES.Values(:,2)  = sign*mean(bct.Table(nr_table).Data(:,2       :2        + (kmax - 1)),2);
                        end
                    end

                    % Temporary fix! Always positive discharges!
                    % (only for hydrodynamic bc if sign is not computed)
                    % For salinity and temperature also specify sign = true (quan_bct does not contail 14 characters!)
                    if ~OPT.Sign
                        if strcmpi(quan_bct(1:14),'flux/discharge') || strcmpi(quan_bct(1:14),'totaldischarge');
                            SERIES.Values  = abs(SERIES.Values);
                        end
                    end
                    
                    % Fill values
                    SERIES.Values      = num2cell(SERIES.Values);

                    %% General Comments
                    SERIES.Comments{1} = '* COLUMNN=2';
                    SERIES.Comments{2} = '* COLUMN1=Time (min) since the reference date';
                    SERIES.Comments{3} = '* COLUMN2=Value';
                end
        end
        %% Write the Series
        if ~isempty(SERIES)
            % Write series
            dflowfm_io_series( 'write',filename{i_output},SERIES);
            clear SERIES;

            % Remove boundary conditions information from the pli-file
            if i_pnt == size(LINE.DATA,1)
                readData           = dflowfm_io_xydata('read' ,filpli{i_pli});
                readData.DATA(:,3) = [];
                dflowfm_io_xydata('write' ,filpli{i_pli} ,readData);
            end
        end
    end
end

varargout{1} = filename;
