Please use the following settings to run a D++ computation:

    DuneErosionSettings('set','ParabolicProfileFcn',@getParabolicProfilePLUSPLUS);
    DuneErosionSettings('set','rcParabolicProfileFcn',@getRcParabolicProfilePLUSPLUS);
    DuneErosionSettings('set','invParabolicProfileFcn',@invParabolicProfilePLUSPLUS);
    DuneErosionSettings('set','Plus','-plusplus'); % sets D++
    DuneErosionSettings('set','d',waterdepth);  % Set waterdepth relative to reference level (e.g. in m NAP). In the model the SWL is added to this value to obtain the total water depth.
    
    <start your DUROS computation>