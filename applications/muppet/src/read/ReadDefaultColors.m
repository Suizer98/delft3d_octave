function Colors=ReadDefaultColors(pth);

txt=ReadTextFile([pth 'settings' filesep 'defaults' filesep 'colors.def']);

noc=0;

for i=1:size(txt,2)
    if isnan(str2double(txt{i}))
        noc=noc+1;
        Colors(noc).Name=txt{i};
        Colors(noc).Val(1)=str2num(txt{i+1})/255;
        Colors(noc).Val(2)=str2num(txt{i+2})/255;
        Colors(noc).Val(3)=str2num(txt{i+3})/255;
    end
end
