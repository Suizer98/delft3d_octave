function ah = plotVolume(result, fh)

if nargin == 1
    fh = gcf;
end

try
    ph = plot(result.xold(~isnan(result.zold)),result.zold(~isnan(result.zold)),...
        'DisplayName', 'Initial profile');
end

set(gca,'Xdir','reverse')
hold on
color = {'b'};
for i = 1 : length(result)
    if ~isempty(result(i).z2Active)
        volumepatch = [result(i).xActive' fliplr(result(i).xActive'); result(i).z2Active' fliplr(result(i).zActive')]';
        hp(i) = patch(volumepatch(:,1), volumepatch(:,2), ones(size(volumepatch(:,2)))*-(length(result)-i),color{i});
        try
            set(hp(i),...
                'DisplayName', ['Volume: ' num2str(result(i).Volumes.Volume, '%.2f') 'm^3/m^1']);
        end
    end
end

box on
ah =gca;