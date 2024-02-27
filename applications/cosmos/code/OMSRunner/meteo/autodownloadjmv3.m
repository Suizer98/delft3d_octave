function alltracks=autodownloadjmv3(varargin)
% Automated downloading of JTWC JMV3.0 files

alltracks=[];

if isempty(varargin)
    folder='.\';
else
    folder=varargin{1};
end

s=urlread('http://www.usno.navy.mil/JTWC/');
ijmv=strfind(s,'JMV 3.0 Data');
ihrf=strfind(s,'href=');
ilt=strfind(s,'>');

n=0;
for j=1:length(ijmv)
    try
        i1=ihrf(find(ihrf<ijmv(j),1,'last'))+5;
        i2=ilt(find(ilt<ijmv(j),1,'last'))-1;
        url=s(i1:i2);
        name=url(end-9:end-4);
        fname=url(end-9:end);
        urlwrite(url,fname);
        tc=readjmv30(fname);
        basin=name(1:2);
        tc.year=2000+str2double(name(end-1:end));
        yr=num2str(tc.year);
        tc.number=str2double(name(3:4));
        if ~isdir([folder filesep basin filesep name])
            mkdir([folder filesep basin filesep yr filesep name]);
        end
        movefile(fname,[folder filesep basin filesep yr filesep name filesep name '.' num2str(tc.advisorynumber,'%0.2i') '.tcw']);
        n=n+1;
        tc.basin=basin;
        alltracks(n).tc=tc;
    end
end
