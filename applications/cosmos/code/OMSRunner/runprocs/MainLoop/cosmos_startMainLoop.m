function cosmos_startMainLoop(hm)

delay=hm.delay;

if hm.cycle<hm.stoptime-0.01
    if now>hm.cycle+delay/24
        starttime=now+1/86400;
    else
        starttime=hm.cycle+delay/24;
        disp(['Execution of cycle ' datestr(hm.cycle,'yyyymmdd.HHMMSS') ' will start at ' datestr(starttime)]);
    end
    
    t = timer;
    set(t,'ExecutionMode','singleShot','BusyMode','drop');
    set(t,'TimerFcn',{@cosmos_runMainLoop},'Tag','MainLoop');
    startat(t,starttime);
end
