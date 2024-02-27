function this = optiRun(this)

%OPTIRUN - run specified optimizer in/for optiStruct data

eval(['this = ' this.optiSettings.method '(this);']);