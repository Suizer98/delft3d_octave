function d=TIDE_readTKA(fName)

% TIDE_READTKA - function to quickly read tidal TKA file


if nargin==0
    [name,pat]=uigetfile('*.tka','Select TKA file');
    if name==0
        return
    end
    fName=[pat filesep name];
end

fid=fopen(fName);

%Determine headerlines
hc=0;
lin=fgetl(fid);
while lin(1)=='*'
    hc=hc+1;
    lin=fgetl(fid);
end

frewind(fid);
%Skip headerlines+2
for ii=1:hc+2
    fgetl(fid);
end


d=fscanf(fid,'%f',[6 inf]);
d=d';

fclose(fid);
