function handles=muppet_initializeSubplot(handles,ifig,isub)

subplot=muppet_setDefaultAxisProperties;

handles.figures(ifig).figure.subplots(isub).subplot=subplot;
