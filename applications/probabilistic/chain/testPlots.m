S = exampleStochastVar('active', [0 0 0 1 1 0]);

S(2).Params = {225e-6};
S(6).Params = {12};

S = exampleStochastVar;

C = exampleChainVar;

C(1).Stochast = S;
C(2).Stochast = S;
C(3).Stochast = S;
C(4).Stochast = S;

C(1).Params = [{'x2zFunction' @x2z_DUROS 'variables' {'resistance' 25} 'seed' 1234 'NrSamples' 1000} C(1).Params];
C(2).Params = [{'x2zFunction' @x2z_DUROS 'variables' {'resistance' 25} 'seed' 1234 'NrSamples' 50} C(2).Params];
C(3).Params = [{'x2zFunction' @x2z_DUROS 'variables' {'resistance' 25} 'seed' 1234 'NrSamples' 10} C(3).Params];
C(4).Params = [{'x2zFunction' @x2z_DUROS 'variables' {'resistance' 25} 'epsZ' .01} C(4).Params];

C(2:3) = [];

r = prob_chain(C);

%%

figure; hold on;

colors = 'rgbcymk';

c = 0;
for i = 1:length(C)-1
    scatter(r{i}.Output.u(~r{i}.Output.idFail,4),r{i}.Output.u(~r{i}.Output.idFail,5),10,colors(i));
    scatter(r{i}.Output.u( r{i}.Output.idFail,4),r{i}.Output.u( r{i}.Output.idFail,5),10,colors(i),'filled');
    
    if i > 1
        scatter(r{i}.settings.IS(1).Params{1},r{i}.settings.IS(2).Params{1},50,colors(i),'filled','MarkerEdgeColor','k');
    end
    
    c = c+r{i}.Output.Calc;
end

i = max([i 0]) + 1;

if ~isscalar(r{i}.settings.startU)
    scatter(r{i}.settings.startU(4),r{i}.settings.startU(5),50,'c','filled','MarkerEdgeColor','k');
end

scatter(r{i}.Output.designpoint.finalU(:,4),r{i}.Output.designpoint.finalU(:,5),50,'m','filled','MarkerEdgeColor','k');

fprintf('%30s: %4f\n', 'Monte Carlo calculations', c);
fprintf('%30s: %4f\n', 'FORM calculations', r{i}.Output.Calc);
fprintf('%30s: %4f\n', 'Total calculations', c+r{i}.Output.Calc);
fprintf('%30s: %4f\n', 'FORM distance traveled', r{i}.Output.designpoint.distU);
fprintf('%30s: %4f\n', 'FORM start U BSS', r{i}.Output.designpoint.BSS);