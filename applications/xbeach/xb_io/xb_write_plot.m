function xb_write_plot(fh, dir, name)
%SAVEPLOT: provide figure handle, output directory and filename (without extension)

%set(fh, 'Renderer', 'ZBuffer');

pname = fullfile(dir, name);

hgsave(fh, [pname '.fig']);
disp(['Saved "' pname '.fig"']);

print(fh, '-depsc2', [pname '.eps']);
disp(['Saved "' pname '.eps"']);

print(fh, '-dpng', [pname '.png']);
disp(['Saved "' pname '.png"']);