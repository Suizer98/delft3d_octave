function [Separation,spec,Bulk]=getWaveSeparationFromSP2(fname,varargin)

tstart=[];
tstop=[];
istation=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'starttime','time'}
                tstart=varargin{i+1};
            case{'stoptime'}
                tstop=varargin{i+1};
            case{'station'}
                istation=varargin{i+1};
        end
    end
end

spec=readSWANSpec(fname);

if isempty(tstart)
    it1=1;
    it2=length(spec.time);
else
    it1=find(spec.time.time==tstart);
    if isempty(tstop)
        it2=it1;
    else
        it2=find(spec.time.time==tstop);
    end
end

if isempty(istation)
    istat1=1;
    istat2=spec.nPoints;
else
    istat1=1;
    istat2=length(spec.nPoints);
end


itime=0;
for i=it1:it2
    itime=itime+1;
    disp(datestr(spec.time(i).time));
    for j=1:(spec.nPoints)
        [Bulk,Separation]=waveseparation(...
            spec.freqs,spec.dirs,spec.time(i).points(j).energy,spec.time(i).points(j).factor);

    end
end
