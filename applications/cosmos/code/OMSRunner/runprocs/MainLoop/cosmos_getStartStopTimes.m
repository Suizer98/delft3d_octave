function hm=cosmos_getStartStopTimes(hm)

if strcmp(datestr(hm.cycle,'mm-dd'),'01-01') == 1
    y=num2str(str2num(datestr(hm.cycle,'yyyy'))-1);
else
    y=datestr(hm.cycle,'yyyy');
end
hm.refTime=datenum(['01/01/' y]);

for i=1:hm.nrModels
    t0(i)=hm.cycle;
end

for i=1:hm.nrModels
    hm.models(i).tFlowStart=t0(i)+hm.models(i).startTime/24;
    hm.models(i).tOutputStart=hm.cycle+hm.models(i).startTime/24;
    hm.models(i).tWaveStart=t0(i)+hm.models(i).startTime/24;
    if hm.models(i).runTime==0
        hm.models(i).runTime=hm.runTime*60;
    else
        hm.models(i).runTime=min(hm.models(i).runTime*60,hm.runTime*60);
    end
    hm.models(i).tStop=hm.catchupCycle+hm.models(i).startTime/24+hm.models(i).runTime/1440;
    hm.models(i).refTime=hm.refTime;
    hm.models(i).rstInterval=hm.runInterval*60;
    hm.models(i).flowRstFile=[];
    hm.models(i).waveRstFile=[];
    hm.models(i).tFlowOkay=t0(i);
    hm.models(i).tWaveOkay=t0(i);
end

for i=1:hm.nrModels

    nf=hm.models(i).nestedFlowModels;
    nw=hm.models(i).nestedWaveModels;

    if isempty(nf) && isempty(nw)

        % No nesting in this model
        tfok=t0(i)+hm.models(i).startTime/24;
        twok=t0(i)+hm.models(i).startTime/24;
        nested=1;
        m=i;

        % Start climbing through model tree
        while nested
            
            if hm.models(m).runSimulation
               
                hm.models(m).tOutputStart=t0(m);

                % WAVE
                wspinup=hm.models(m).waveSpinUp/24;
                hm.models(m).tWaveStart=min(twok,hm.models(m).tWaveStart);
                switch lower(hm.models(m).type)
                    case{'ww3'}
                        [rstw,rstfil]=cosmos_checkForRestartFile(hm,m,hm.models(m).tWaveStart,wspinup,'ww3');
                    case{'delft3dflowwave'}
                        [rstw,rstfil]=cosmos_checkForRestartFile(hm,m,hm.models(m).tWaveStart,wspinup,'delft3dwave');
                    otherwise
                        rstw=[];
                        rstfil=[];
                end

                if ~isempty(rstw)
                    % Restart from restart file
                    hm.models(m).tWaveStart=rstw;
                    hm.models(m).tWaveOkay=hm.models(m).tWaveStart;
                else
%                    if hm.models(m).tWaveStart+wspinup>twok
                        hm.models(m).tWaveStart=min(twok-wspinup,hm.models(m).tWaveStart);
%                    end
                    hm.models(m).tWaveOkay=hm.models(m).tWaveStart+wspinup;
                end
                hm.models(m).waveRstFile=rstfil;

                % FLOW
                fspinup=hm.models(m).flowSpinUp/24;
                hm.models(m).tFlowStart=min(tfok,hm.models(m).tFlowStart);
                % Flow always starts before wave
%                 tfstartnowaves=hm.models(m).tFlowStart;
                hm.models(m).tFlowStart=min(hm.models(m).tWaveStart,hm.models(m).tFlowStart);
                switch lower(hm.models(m).type)
                    case{'delft3dflowwave','delft3dflow'}
                        [rstf,rstfil]=cosmos_checkForRestartFile(hm,m,hm.models(m).tFlowStart,fspinup,'delft3dflow');
                    otherwise
                        rstf=[];
                        rstfil=[];
                end
                if ~isempty(rstf)
                    % Restart from restart file
                    hm.models(m).tFlowStart=rstf;
                    hm.models(m).tFlowOkay=hm.models(m).tFlowStart;
                else
%                    hm.models(m).tFlowStart=max(hm.models(m).tFlowStart,tfstartnowaves)-fspinup;
                    hm.models(m).tFlowStart=min(tfok-fspinup,hm.models(m).tFlowStart);
%                    hm.models(m).tFlowStart=min(hm.models(m).tWaveStart,hm.models(m).tFlowStart);
                    hm.models(m).tFlowOkay=hm.models(m).tFlowStart+fspinup;
                end
                hm.models(m).flowRstFile=rstfil;

                tfok=hm.models(m).tFlowStart;
                twok=hm.models(m).tWaveStart;

            end

            nested=hm.models(m).flowNested || hm.models(m).waveNested;

            m0=m;
            
            if hm.models(m0).flowNested
                m=hm.models(m0).flowNestModelNr;
            end

            if hm.models(m0).waveNested
                m=hm.models(m0).waveNestModelNr;
            end

        end
    end

end
