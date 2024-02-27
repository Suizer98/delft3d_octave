function run_now(handles,varargin)

% run_now : runs nesting programs in batch (without ui)
if ~isempty(varargin)
    OPT = varargin{1};
end

Active = handles.active;

if strcmpi(Active,'Nesthd1')
   handles = nesthd_check_nesthd1(handles);
   if strcmpi(handles.run_nesthd1_onoff,'on')
      nesthd_nesthd1(handles.files_hd1);
   end
else
    handles = nesthd_check_nesthd2(handles);
    if strcmpi(handles.run_nesthd2_onoff,'on')
        nesthd_nesthd2(handles.files_hd2,handles.add_inf,OPT);
    end
end

