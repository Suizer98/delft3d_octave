function wricon_bcc(filename,bnd,nfs_inf,bndval,add_inf,varargin)

% wricon_bcc : writes transport boundary conditions to a bcc file

%
% Get some general parameters
%
notims        = length(bndval);
kmax          = size(bndval(1).value,2);
thick         = nfs_inf.thick;
lstci         = size(bndval(1).value,3);
namcon        = nfs_inf.namcon;


OPT.ipnt      = NaN;
OPT           = setproperty(OPT,varargin);
bndNr         = OPT.ipnt;

%% Switch orientation if overall model is dflowfm
if strcmpi(nfs_inf.from,'dfm')
    [bndval,thick] = nesthd_flipori(bndval,thick);
end

%
% Fill the INFO structure (general information)
%

profile = 'uniform'; if kmax > 1 profile = '3d-profile';end

if bnd.DATA(bndNr).datatype == 'T'
    for l = 1:lstci
        if ~odd(bndNr) load(['sideA_' num2str(l,'%2.2i') '.mat']); delete(['sideA_' num2str(l,'%2.2i') '.mat']); end
        if add_inf.genconc(l)
            quant                      = '                    ';
            quant(1:length(namcon{l})) = namcon{l};
            switch lower(namcon{l}(1:4))
                case{'sali'}
                    unit='[psu]';
                case{'temp'}
                    unit='[oC]';
                otherwise
                    unit='[-]';
            end
            
            Info.Table(1).Name=['Boundary Section : ' num2str(floor((bndNr - 1)/2) + 1)];
            Info.Table(1).Contents=profile;
            Info.Table(1).Location=bnd.DATA(bndNr).name;
            Info.Table(1).TimeFunction='non-equidistant';
            Info.Table(1).ReferenceTime=str2num(datestr(nfs_inf.itdate,'yyyymmdd'));
            Info.Table(1).TimeUnit='minutes';
            Info.Table(1).Interpolation='linear';
            Info.Table(1).Parameter(1).Name='time';
            Info.Table(1).Parameter(1).Unit='[min]';
            
            switch lower(profile)
                case{'uniform'}
                    Info.Table(1).Parameter(2).Name=[quant 'End A'];
                    Info.Table(1).Parameter(2).Unit=unit;
                    Info.Table(1).Parameter(3).Name=[quant 'End B'];
                    Info.Table(1).Parameter(3).Unit=unit;
                case{'3d-profile'}
                    j=1;
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(1).Parameter(j).Name=[quant 'End A layer: ' num2str(kk)];
                        Info.Table(1).Parameter(j).Unit=unit;
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(1).Parameter(j).Name=[quant 'End B layer: ' num2str(kk)];
                        Info.Table(1).Parameter(j).Unit=unit;
                    end
            end
            
            %
            % Fill Info structure with time series
            %
            
            for itim = 1: notims
                Info.Table(1).Data(itim,1) = (nfs_inf.times(itim) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;
                for ilay = 1: kmax
                    if odd(bndNr)
                        Info.Table(1).Data(itim,ilay+1     ) = bndval(itim).value(1,ilay,l,1);
                    else
                        Info.Table(1).Data(itim,ilay+kmax+1) = bndval(itim).value(1,ilay,l,1);
                    end
                end
            end
        end
        
        if odd(bndNr) save (['sideA_' num2str(l,'%2.2i') '.mat'],'Info'); end
        %
        % Finally write to the bct file
        %
        if bndNr == 2 && l == 1
            ddb_bct_io('write',filename,Info,'append',false);
        elseif ~odd(bndNr)
            ddb_bct_io('write',filename,Info,'append',true);
        end
    end
end
