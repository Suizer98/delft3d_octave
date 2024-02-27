function saveplot(fh, dir, name)
%SAVEPLOT: provide figure handle, output directory and filename (without extension)

pname = [dir filesep name];

hgsave(fh, [pname '.fig']);
disp(['Saved "' pname '.fig"']);

print(fh, '-depsc2', [pname '.eps']);
disp(['Saved "' pname '.eps"']);

print(fh, '-dpng', [pname '.png']);
disp(['Saved "' pname '.png"']);