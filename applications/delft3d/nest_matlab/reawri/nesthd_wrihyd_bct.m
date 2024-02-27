function wrihyd_bct(filename,bnd,nfs_inf,bndval,add_inf,varargin)

% wrihyd_bct : writes hydrodynamic bc to a *.bct (Delft3D-Flow) file

%
% Get some general parameters
%
% Modified 2/9/2015: bndval now point structured in stead of bnd
%                    structured
notims        = length(bndval);

OPT.ipnt      = NaN;
OPT           = setproperty(OPT,varargin);
bndNr         = OPT.ipnt;

if size(bndval(1).value,2) == 1
    kmax = 1;
else
    kmax = size(bndval(1).value,2)/2;
end
thick         = nfs_inf.thick;

%% Switch orientation if overall model is dflowfm
if strcmpi(nfs_inf.from,'dfm')
    [bndval,thick] = nesthd_flipori(bndval,thick,bnd);
end

%
% Fill the INFO structure (general information)
%

quant2=[];
unit2 =[];
profile = 'uniform';

if bnd.DATA(bndNr).datatype == 'T'
    if ~odd(bndNr) load ('sideA.mat'); delete ('sideA.mat'); end
    if  odd(bndNr)
        switch lower(bnd.DATA(bndNr).bndtype)
            case{'z'}
                quant='Water elevation (Z)  ';
                unit='[m]';
            case{'c'}
                quant='Current         (C)  ';
                unit='[m/s]';
                profile = add_inf.profile;
            case{'n'}
                quant='Neumann         (N)  ';
                unit='[-]';
            case{'r'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
                profile = add_inf.profile;
            case{'x'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
                profile = add_inf.profile;
            case{'p'}
                quant='Current         (C)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
                profile = add_inf.profile;
        end
        Info.Table(1).Name=['Boundary Section : ' num2str(floor(bndNr - 1)/2 + 1)];
        Info.Table(1).Contents=profile;
        Info.Table(1).Location=bnd.DATA(bndNr).name;
        Info.Table(1).TimeFunction='non-equidistant';
        Info.Table(1).ReferenceTime=str2num(datestr(nfs_inf.itdate,'yyyymmdd'));
        Info.Table(1).TimeUnit='minutes';
        Info.Table(1).Interpolation='linear';
        Info.Table(1).Parameter(1).Name='time';
        Info.Table(1).Parameter(1).Unit='[min]';
        
        switch lower(profile)
            case{'uniform' 'logarithmic'}
                Info.Table(1).Parameter(2).Name=[quant 'End A'];
                Info.Table(1).Parameter(2).Unit=unit;
                Info.Table(1).Parameter(3).Name=[quant 'End B'];
                Info.Table(1).Parameter(3).Unit=unit;
                if ~isempty(quant2)
                    Info.Table(1).Parameter(4).Name=[quant2 'End A'];
                    Info.Table(1).Parameter(4).Unit=unit2;
                    Info.Table(1).Parameter(5).Name=[quant2 'End B'];
                    Info.Table(1).Parameter(5).Unit=unit2;
                end
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
                if ~isempty(quant2)
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(1).Parameter(j).Name=[quant2 'End A layer: ' num2str(kk)];
                        Info.Table(1).Parameter(j).Unit=unit2;
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(1).Parameter(j).Name=[quant2 'End B layer: ' num2str(kk)];
                        Info.Table(1).Parameter(j).Unit=unit2;
                    end
                end
        end
    end
    %
    % Fill Info structure with time series
    %
    
    for itim = 1: notims
        Info.Table(1).Data(itim,1) = (nfs_inf.times(itim) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;
        
        switch bnd.DATA(bndNr).bndtype
            case{'Z' 'N'}
                if odd(bndNr)
                    Info.Table(1).Data(itim,2) = bndval(itim).value(1,1,1);
                else
                    Info.Table(1).Data(itim,3) = bndval(itim).value(1,1,1);
                end
            case{'C' 'R' 'X' 'P'}
                for ilay = 1: kmax
                    if odd(bndNr)
                        Info.Table(1).Data(itim,ilay+1     ) = bndval(itim).value(1,ilay,1);
                    else
                        Info.Table(1).Data(itim,ilay+kmax+1) = bndval(itim).value(1,ilay,1);
                    end
                    
                    switch bnd.DATA(bndNr).bndtype
                        case{'X' 'P'}
                            
                            if odd(bndNr)
                                Info.Table(1).Data(itim,ilay+2*kmax+1) = bndval(itim).value(1,ilay+kmax,1);
                            else
                                Info.Table(1).Data(itim,ilay+3*kmax+1) = bndval(itim).value(1,ilay+kmax,2);
                            end
                    end
                end
        end
    end
    if odd(bndNr) save('sideA.mat','Info'); end
    
    %
    % Finally write to the bct file
    %
    if ~odd(bndNr)
        if bndNr == 2
            ddb_bct_io('write',filename,Info,'append',false);
        else
            ddb_bct_io('write',filename,Info,'append',true);
        end
    end
    
end

