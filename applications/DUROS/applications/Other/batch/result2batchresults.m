function result2batchresults(workdir, outputfilename, d, result, cM, WL_t, Hsig_t, Tp_t, Norm, Scen)
%% create output
%     outputvariables = strread(' Jaar  Kustvak   Raai   Methode   Rekenpeil   H0s   Tp   Xp   XpParijsCoordinaatX   XpParijsCoordinaatY   Xr   XrParijsCoordinaatX   XrParijsCoordinaatY   AVolume   TVolume   E   Norm   Scen ', '%s');

[Er, AVolume, Xplocation, Xp, Xr, TVolume] = deal(nan);

for i = 1 : length(result)
    %     NaN : Geen oplossing mogelijk tussen de iteratie grenzen
    %     0 :   'Iteration boundaries are non-consistent'(**)
    %     2 :   Channel slope zit in de weg
    %     100 : landwaards transport correctie boven water ==> onzin oplossing
    if ~(...
            ~isempty(find(isnan(vertcat(result(1).info.messages{:,1}))))|...
            any(strcmp(result(1).info.messages(:,2),'Iteration boundaries are non-consistent'))|...
            ~isempty(find(vertcat(result(1).info.messages{:,1})==2))|...
            ~isempty(find(vertcat(result(1).info.messages{:,1})==100))...
            )
        if ismember({result(i).info.ID},'DUROS-plus')
            if ~isempty(result(i).Volumes.Erosion)
                Er = -result(i).Volumes.Erosion;
            else
                Er = nan;
            end
        elseif ismember({result(i).info.ID},'DUROS-plus Erosion above SSL')
            AVolume = result(i).Volumes.Volume;
        elseif ismember({result(i).info.ID},'Additional Erosion')
            Xplocation=find(result(i).z2Active == WL_t, 1);
            if isempty(Xplocation)
                Xplocation=1;
            end
            Xp = result(i).xActive(Xplocation);
            Xr = result(i).xActive(1);
            TVolume = result(i).Volumes.Volume;
        end
    else
        [Er, AVolume, Xplocation, Xp, Xr, TVolume] = deal(nan);
    end
end

try
    [xyRDP] = xyRSP2RD(d.xRD,d.yRD,d.GRAD,360,Xp);
catch
    Xp = NaN;
    xyRDP=[nan nan];
end

try
    [xyRDR] = xyRSP2RD(d.xRD,d.yRD,d.GRAD,360,Xr);
catch
    Xr=nan;
    xyRDR=[nan nan];
end

xInitial    = d.xe(~isnan(d.ze)); %#ok<NASGU> %keep only the points with non-NaN z-values
zInitial    = d.ze(~isnan(d.ze)); %#ok<NASGU> %keep only the points with non-NaN z-values

MKL = getMKL(xInitial, zInitial, 3, 3-(2*(3-d.MLW)), 1000);
BKL = getBKL(str2double(d.areacode),d.transectID);

fid=fopen([workdir filesep outputfilename],'a');
fprintf(fid,'%i   %i   %05i   %i   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.2f   %8.6f    %i   %8.2f   %8.2f   %i   %i   %i\n', ...
    str2double(d.year),str2double(d.areacode),str2double(d.transectID),cM,WL_t,Hsig_t,Tp_t,Xp,xyRDP(1,1),xyRDP(1,2),Xr,xyRDR(1,1),xyRDR(1,2),AVolume,TVolume,Er,Norm,Scen,MKL,BKL,d.xRD,d.yRD,d.GRAD);
fclose(fid);

