function [ TVolume ] = tvolumefunction( AVolume )
%TVOLUMEFUNCTION Example of custom function needed to calculate T volume from A volume

% Exmple:
%       DuneErosionSettings('set','AdditionalVolume',@tvolumefunction)
%       r = mpa_durosplus()

TVolume = 0.25*AVolume;
end