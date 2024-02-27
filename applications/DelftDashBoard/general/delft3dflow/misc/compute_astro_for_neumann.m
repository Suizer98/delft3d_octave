function compute_astro_for_neumann(bcafile_in,bcafile_out,dx)
% Computes astronomical components for neumann boundaries.
% Script reads in bca file containing two component sets for the two offshore
% boundary points. The order is important! The first set must for the
% boundary point with the lowest grid index.
% Outputs new bca file with original component sets plus a third set with
% the Neumann components.
%
% E.g.
% bcafile_in  = 'egmond.bca';                  % Input bca file (should contain two component sets for the two offshore boundary points)
% bcafile_out = 'egmond_with_neumann.bca';     % Output bca file (will contain original two component sets plus a third with the neumann components)
% dx=2000;                                     % Length of offshore in metres
% compute_astro_for_neumann(bcafile_in,bcafile_out,dx);

astronomicComponentSets = delft3dflow_readBcaFile(bcafile_in);

amp1=astronomicComponentSets(1).amplitude;
phi1=astronomicComponentSets(1).phase;
phi1=phi1*pi/180;

amp2=astronomicComponentSets(2).amplitude;
phi2=astronomicComponentSets(2).phase;
phi2=phi2*pi/180;

nocomp=length(amp1);

for icmp=1:nocomp
    a=amp2(icmp)*cos(phi2(icmp)) - amp1(icmp)*cos(phi1(icmp));
    b=amp2(icmp)*sin(phi2(icmp)) - amp1(icmp)*sin(phi1(icmp));
    amp3(icmp)=sqrt(a^2+b^2)/dx;
    phi3(icmp)=atan2(b,a);
end
phi3=mod(phi3,2*pi);

astronomicComponentSets(3)=astronomicComponentSets(1);
astronomicComponentSets(3).name='Neumann';
astronomicComponentSets(3).amplitude=amp3;
astronomicComponentSets(3).phase=phi3*180/pi;

delft3dflow_saveBcaFile(astronomicComponentSets, bcafile_out);

%%
function astronomicComponentSets = delft3dflow_readBcaFile(fname)
fid=fopen(fname);
k=0;
for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if ~isempty(v0)
        if length(v0)==1
            k=k+1;
            j=1;
            astronomicComponentSets(k).name=v0{1};
        else
            astronomicComponentSets(k).component{j}=v0{1};
            astronomicComponentSets(k).amplitude(j)=str2double(v0{2});
            if length(v0)>2
                astronomicComponentSets(k).phase(j)=str2double(v0{3});
            else
                % Only amplitude given (A0 component)
                astronomicComponentSets(k).phase=0;
            end
            astronomicComponentSets(k).correction(j)=0;
            astronomicComponentSets(k).amplitudeCorrection(j)=1;
            astronomicComponentSets(k).phaseCorrection(j)=0;
            astronomicComponentSets(k).nr=j;
            j=j+1;
        end
    else
        fclose(fid);
        return
    end
end
fclose(fid);

%%
function delft3dflow_saveBcaFile(astronomicComponentSets, fname)
fid=fopen(fname,'w');
nr=length(astronomicComponentSets);
for i=1:nr
    fprintf(fid,'%s\n',astronomicComponentSets(i).name);
    for j=1:astronomicComponentSets(i).nr
        cmp=astronomicComponentSets(i).component{j};
        amp=astronomicComponentSets(i).amplitude(j);
        pha=astronomicComponentSets(i).phase(j);
        if isnan(pha) % then A0
            fprintf(fid,'%s %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp);
        else
            fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
        end
    end
end
fclose(fid);

