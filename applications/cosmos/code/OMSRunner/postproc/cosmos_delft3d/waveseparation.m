function [Bulk,Separation]=waveseparation(freqs,dirs,energy,factor)
%
% [Bulk,Separation]=waveseparation(freqs,dirs,energy,factor)

% Organize directional bin
% dirs(dirs<0)=dirs(dirs<0)+360;
% dirs=sort(dirs);

[dirs,isort]=sort(dirs);
energy=energy(:,isort);

% dirs(dirs>90)=dirs(dirs>90)-90;
% dirs(dirs<90)=90-dirs(dirs<90);

EnDens=energy*factor;  %Energy Density

VarDens=EnDens/(1025*9.8);  %Variance Density

m0=trapz(freqs,...
    trapz(dirs,rot90((VarDens)))); %zeroth order moment

m1=trapz(freqs,...
    freqs.*trapz(dirs,rot90((VarDens))));  % first order moment

m2=trapz(freqs,...
    (freqs.^2).*trapz(dirs,rot90((VarDens))));  % second order moment

% Overall (bulk) parameter from overal spectra
Hs=4.*sqrt(m0);
Tm01=m0./m1;
WavDir=...
    atand((trapz(dirs,...
    sind(dirs).*trapz(freqs,((VarDens))))...
    /...
    ((trapz(dirs,...
    cosd(dirs).*trapz(freqs,((VarDens))))))));
if WavDir<0
    WavDir=WavDir+360;
end
% Peak period
% [fpi]=find((trapz(dirs,rot90(VarDens)))==max((trapz(dirs,rot90(VarDens)))));
[r,c]=find(VarDens==max(max(VarDens)));
fp=freqs(r);  % Peak Frequency
Tp=1/fp;

% Save everything into Bulk structure
Bulk.Hs=Hs;
Bulk.Tm01=Tm01;
Bulk.Tp=Tp;
Bulk.WavDir=WavDir;
Bulk.EnDens=EnDens;
Bulk.VarDens=VarDens;
Bulk.m0=m0;
Bulk.m1=m1;
Bulk.m2=m2;

%% Apply the separation
%The only criteria is frequency less than or equal to 0.15Hz is defined as
%Swell
% First, integrate over direction to obtain S(f)
VarDensF=trapz(dirs,rot90(VarDens));

% Separate based on frequency
ss=find(freqs<=0.15);
ws=find(freqs>0.15);

% Put them into their room
% For Swell
Separation.Swell.VarDens=VarDensF(ss); Separation.Swell.Freq=freqs(ss);

if Separation.Swell.VarDens==0;
    peakss=0;
    Separation.Swell.m0=0;
    Separation.Swell.m1=0;
    Separation.Swell.Hs=0;
    Separation.Swell.Tm01=0;
    Separation.Swell.Tp=0;
    
else
    % Locate the peak
    peakss=find(Separation.Swell.VarDens==max(Separation.Swell.VarDens));
    if length(peakss)>1
        peakss=peakss(1);
    end
    
    Separation.Swell.fpeak=Separation.Swell.Freq(peakss);
    
    % Calculate all the parameter for Swell room
    Separation.Swell.m0=trapz(Separation.Swell.Freq,Separation.Swell.VarDens);
    Separation.Swell.m1=trapz(Separation.Swell.Freq,...
        Separation.Swell.Freq.*Separation.Swell.VarDens);
    Separation.Swell.Hs=4.*sqrt(Separation.Swell.m0);
    Separation.Swell.Tm01=(Separation.Swell.m0)/Separation.Swell.m1;
    Separation.Swell.Tp=1/(Separation.Swell.fpeak);
end

% For Wind Sea
Separation.WindSea.VarDens=VarDensF(ws); Separation.WindSea.Freq=freqs(ws);
if Separation.WindSea.VarDens==0;
    peakws=0;
    Separation.WindSea.m0=0;
    Separation.WindSea.m1=0;
    Separation.WindSea.Hs=0;
    Separation.WindSea.Tm01=0;
    Separation.WindSea.Tp=0;
else
    % Locate the peak
    peakws=find(Separation.WindSea.VarDens==max(Separation.WindSea.VarDens));
    Separation.WindSea.fpeak=Separation.WindSea.Freq(peakws);
    % Calculate all the parameter for WindSea room
    Separation.WindSea.m0=trapz(Separation.WindSea.Freq,Separation.WindSea.VarDens);
    Separation.WindSea.m1=trapz(Separation.WindSea.Freq,...
        Separation.WindSea.Freq.*Separation.WindSea.VarDens);
    Separation.WindSea.Hs=4.*sqrt(Separation.WindSea.m0);
    Separation.WindSea.Tp=1/(Separation.WindSea.fpeak);
end

















% partLabel=watershed(VarDens);
% Nparts=max(max(partLabel));
%
% % Make Sub Partition
% for par=1:Nparts
%     [row,col]=find(partLabel==(par));
%
%     for ii=1:length(row)
%         SubPart(row(ii),col(ii))=...
%             VarDens(row(ii),col(ii));
%     end
%     % Total energy within this Sub Partition
%     Partition.SubPartition(par).EnTot=sum(sum(SubPart)); % Times df dphi??
%     % Peak Energy
%     Partition.SubPartition(par).EnPeak=max(max(SubPart));
%     [r,c]=find((SubPart)==Partition.SubPartition(par).EnPeak);
%     % Peak Frequency
%     Partition.SubPartition(par).FreqPeak=freqs(r);
%     % Peak Direction
%     Partition.SubPartition(par).DirPeak=dirs(c);
%
% end





