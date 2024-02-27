%%
% clear; close all; clc
dbstate off
CaseNrs     = 0:7;
startTime	= clock;
steps       = [25  5 20  5 20]; % WL_t Hsig_t D50 profile others

% waterlevel
Pmin        = 1e-7;
Pmax        = 1e-2;
logPmin     = log(Pmin);
logPmax     = log(Pmax);
logP = logPmin:(logPmax-logPmin)/steps(1):logPmax;
PWL_t = fliplr(exp(logP));
FWL_t = 1 - (diff(PWL_t)/2+PWL_t(1:end-1));
P = -diff(PWL_t);

% wave height
FHsig_t = 1/(2*steps(2)) : 1/steps(2) : 1;

% peak wave period
FTp_t = 0;

% grain size
FD50 = 1/(2*steps(3)) : 1/steps(3) : 1;

% profile
FProfileFluct = 1/(2*steps(4)) : 1/steps(4) : 1;

%others
[FDuration, FGust, FAccuracy] = deal(1/(2*steps(5)) : 1/steps(5) : 1);

for CaseNr = CaseNrs
    startTime	= clock;
    id = 1;
    clear results
    results = zeros(prod(steps),3);
    for a = 1 : steps(1) % all waterlevels
        for b = 1 : steps(2) % all wave heights
            for c = 1 : steps(3) % all grain sizes
                for d = 1 : steps(4) % all profile fluctuations
                    for e = 1 : steps(5) % all others
                        try
                            RD = getDuneErosion_Prob2B(FD50(c), FWL_t(a), FHsig_t(b), FTp_t, FProfileFluct(d), FDuration(e), FGust(e), FAccuracy(e), 0, CaseNr); %#ok<NASGU>
                        catch
                            fclose all
                            s = lasterror;
                            fprintf('\nWhen using input:\nFD50=%g; FWL_t=%g; FHsig_t=%g; FTp_t=%g; FProfileFluct=%g; FDuration=%g; FGust=%g; FAccuracy=%g; CaseNr=%g\n',[FD50(c), FWL_t(a), FHsig_t(b), FTp_t, FProfileFluct(d), FDuration(e), FGust(e), FAccuracy(e), CaseNr]);
                            fileseplocations = strfind(s.stack(1).file, filesep); % find positions of file separators
                            linestr=['<a href="error:' s.stack(1).file ',' num2str(s.stack(1).line) ',1">' s.stack(1).file(fileseplocations(end)+1:end) '</a>'];
                            fprintf('In file %s at line %.0f an error occured:\n%s\n',linestr, s.stack(1).line, s.message)
                            RD(id) = 0; % dummy value for RD
                            fprintf('  Warning: RD has been set to dummy value zero\n')
                        end
                        probability  = P(a)*prod(1./steps(2:end));
                        results(id,1:2) = [RD probability];
                        id = id + 1;
                    end
                end
            end
        end
        if a == 1 || a == steps(1)
            endTime = estTime(startTime,a/steps(1));
        end
    end
end

filename = ['Case_' num2str(CaseNr) filesep 'NumericalIntegration_Case_' num2str(CaseNr) '.asc'];
save(filename, 'results', '-ascii')
% results = sortrows(results, 1); % sort based on AF
% results(:,3) = flipud(cumsum(flipud(results(:,2)))); % cumulative probability
% 
% k = max(find(results(:,end)>1e-5));
% NormativeRD = interp1(log(results(k:k+1,end)),results(k:k+1,1),log(1e-5)); % log-interpolate 1e-5 probability
% 
% set(0,'Units','pixels') 
% position = get(0,'ScreenSize') + [0 30 0 -97];
% figure('Position',position,'Color','w')
% semilogx(results(:,end),results(:,end-2),[1e-5 1e-5 1],[0 NormativeRD NormativeRD],'--r')
% 
% set(gca,'XDir','reverse','XLim',[1e-6 1e-2],'YLim',[0 max([100 NormativeRD])]);
% yticks=get(gca,'YTick');
% set(gca,'YTick',sort([yticks NormativeRD]),'YTicklabel',sort([yticks round(NormativeRD)]));
% grid on
% 
% title('Numerical integration (Van de Graaff, 1984)')
% xlabel('Probability of exceedance per year')
% ylabel('RD [m]','Rotation',270,'VerticalAlignment','top')