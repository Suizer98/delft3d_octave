function saveplot(fh, dir, name)
%SAVEPLOT: provide figure handle, output directory and filename (without extension)

if isempty(dir)
    pname=name;
else
    pname = [dir,filesep,name];
end

%hgsave(fh, [pname '.fig']);
%disp(['    Saved "' pname '.fig"']);

%print(fh, '-depsc2', [pname '.eps']);
%disp(['    Saved "' pname '.eps"']);

print(fh, '-dpng', [pname '.png']);
disp(['    Saved "' pname '.png"']);