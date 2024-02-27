function ddb_DFlowFM_outputTimes(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectobservationpointfrommap'}
%            ddb_DFlowFM_plotBoundaries(handles,'update');
    end
end
