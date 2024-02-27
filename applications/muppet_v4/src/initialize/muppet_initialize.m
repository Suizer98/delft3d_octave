function handles=muppet_initialize(handles)

handles=muppet_getCoordinateSystems(handles);
handles=muppet_initializeAnimationSettings(handles);
handles.dateformats=muppet_readDateFormats([handles.settingsdir 'dateformats' filesep 'dateformats.def']);
handles.colormaps=muppet_importColorMaps([handles.settingsdir 'colormaps' filesep]);
handles=muppet_readXmlFiles(handles);
