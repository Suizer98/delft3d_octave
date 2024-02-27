function  s = triana_perform_triana_for_measurements(s)

for ss = 1:length(s.modID)
    
    s.triana.Gobs(:,ss) = zeros(length(s.triana.Cmp),1)+NaN;
    s.triana.Aobs(:,ss) = zeros(length(s.triana.Cmp),1)+NaN;
    if ~isnan(s.measID(ss))
        s.triana.statsObs{ss} = s.meas.data(s.measID(ss)).name;
        for cc = 1:length(s.triana.Cmp)
            for cc2 = 1:length(s.meas.data(s.measID(ss)).Cmp)
                if strcmpi(s.meas.data(s.measID(ss)).Cmp{cc2},s.triana.Cmp{cc})
                    s.triana.Aobs(cc,ss) = s.meas.data(s.measID(ss)).A(cc2);
                    s.triana.Gobs(cc,ss) = s.meas.data(s.measID(ss)).G(cc2);
                end
            end
        end
    else
        s.triana.statsObs{ss} = NaN;
    end
end

s.triana.X = s.model.data.X;
s.triana.Y = s.model.data.Y;
s.triana.statsComp = s.model.data.stats;