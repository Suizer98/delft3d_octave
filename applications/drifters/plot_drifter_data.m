mid = 'eb_15_10';
mdir = 'g:\PhDData\Survey\MegaPEX\Drifters\';
gt31 = process_drifterlog(mid,mdir);

figure;
hold on;
for i = 1:length(gt31)
    for j = 1:length(gt31{i})
        plot(gt31{i}(j).lon,gt31{i}(j).lat,'k-','linewidth',2);
    end
end