function [handles] = check_nesthd2(handles)

% check_nesthd2 : checks if all information for nesthd2 is present

handles.run_nesthd2_onoff = 'off';
handles.bcc_onoff         = 'on';

if ~isempty(handles.files_hd2{1}) && ~isempty(handles.files_hd2{2}) && ...
   ~isempty(handles.files_hd2{3}) && ~isempty(handles.files_hd2{4})
   if handles.nfs_inf.lstci > 0
      if sum(handles.add_inf.genconc) == 0
         handles.run_nesthd2_onoff = 'on';
         handles.bcc_onoff         = 'off';
      elseif ~isempty(handles.files_hd2{5})
         handles.run_nesthd2_onoff = 'on';
      end
   else
      handles.run_nesthd2_onoff = 'on';
      handles.bcc_onoff         = 'off';
   end
end
