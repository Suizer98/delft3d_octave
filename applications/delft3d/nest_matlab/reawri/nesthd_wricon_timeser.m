function wrihyd_timeser(filename,bnd,nfs_inf,bndval,add_inf,varargin)

% wricon_timeser L: write transport bc to a tiemser (SIMONA) file

%
% Set some general parameters
%
notims        = length(bndval);
kmax          = size(bndval(1).value,2);
lstci         = size(bndval(1).value,3);
thick         = nfs_inf.thick;

OPT.ipnt      = NaN;
OPT           = setproperty(OPT,varargin);
bndNr         = OPT.ipnt;

%% Switch orientation if overall model is dflowfm
if strcmpi(nfs_inf.from,'dfm')
    [bndval,thick] = nesthd_flipori(bndval,thick);
end

%% Cycle over constituents
for l = 1: lstci
    
    %
    % Open output file
    %
    if bndNr == 1 && l == 1; fid = fopen(filename,'w+'); else fid = fopen(filename,'a'); end
    
    if add_inf.genconc(l)
        %
        % Set pointname
        %
        if isfield(bnd,'pntnr')
            pntname = ['P' num2str(bnd.pntnr(i_pnt))];
        else
            pntname  = ['P' num2str(bndNr,'%4.4i')];
        end
        
        for k = 1:kmax
            
            %
            % Write general information
            %
            
            Line = ['TS : CO',num2str(l),' ',pntname,' CINIT=0.0 SERIES=','''','regular',''''];
            
            if kmax > 1
                Line = [Line ' Layer = ' num2str(k)];
            end
            fprintf(fid, '%s\n', Line);
            tstart = (nfs_inf.times( 1 ) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;
            dtmin  = (nfs_inf.times(2) - nfs_inf.times(1))*1440 ;
            tend   = tstart + (notims - 1)*dtmin;
            
            Line = ['Frame = ' num2str(tstart) ' ' num2str(dtmin) ' ' num2str(tend)];
            fprintf(fid, '%s\n', Line);
            Line = 'Values = ';
            fprintf(fid, '%s\n', Line);
            
            %
            % Write the series to file
            %
            
            for itim = 1: notims
                values(itim) =bndval(itim).value(1,k,l,1);
            end
            
            fprintf(fid,' %12.6f %12.6f %12.6f %12.6f %12.6f \n',values);
            if mod(notims,5) ~= 0; fprintf(fid,'\n');end
        end
    end
end

fclose (fid);