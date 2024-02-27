%% load transect data
tr = jarkus_transects(...
    'id', [13000267 13000301],...
    'year', [1973 1982 1995 2010]);

%% plot
ntransects = length(tr.id);
colors = {'k' 'b' 'g' 'r'};
for itransect = 1:ntransects
    subplot(ntransects,1,itransect)
    hold on
    for iyear = 1:length(tr.time)
        date = datevec(tr.time(iyear)+datenum(1970,1,1));
        year = date(1);
        nnid = ~isnan(squeeze(tr.altitude(iyear,itransect,:)));
        plot(tr.cross_shore(nnid), squeeze(tr.altitude(iyear,itransect,nnid)),...
            'DisplayName', num2str(year),...
            'color', colors{iyear})
    end
    title(['transect ' num2str(tr.id(itransect))])
    xlabel('cross-shore coordinate [m]')
    ylabel('altitude [m]')
    legend('toggle')
end