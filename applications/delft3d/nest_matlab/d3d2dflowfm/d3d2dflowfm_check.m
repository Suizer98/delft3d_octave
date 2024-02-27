function d3d2dlowfm_check

% check : performs a number of test conversions to check if everything went okay

tstdir = 'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\';

filmdf ={[tstdir 'simona\Testmaas\mdf_t1250\t1250.mdf'                          ]
         [tstdir 'delft3d\SeaOfMarmara\mdf\b01.mdf'                             ]
         [tstdir 'delft3d\scope\scope_n.mdf'                                    ]
         [tstdir 'delft3d\d42_input\mdf\d42.mdf'                                ]
         [tstdir 'simona\simona-scaloost-fijn-exvd-v1\mdf_fou\scaloost_fou.mdf' ]
         [tstdir 'simona\Simona_waal_weir\mdf\hf1.mdf'                          ]
         [tstdir 'simona\A80\mdf_zuno\zunov4.mdf'                               ]
         [tstdir 'simona\simona-kustzuid-2004-v4\mdf\kzv4.mdf'                  ]
         [tstdir 'simona\A80\mdf_csm\dcsmv6.mdf'                                ]};
filmdu ={[tstdir 'simona\Testmaas\mdu_t1250\t1250.mdu'                          ]
         [tstdir 'delft3d\SeaOfMarmara\mdu\b06.mdu'                             ]
         [tstdir 'delft3d\scope\mdu\scope_n.mdu'                                ]
         [tstdir 'delft3d\d42_input\mdu\d42.mdu'                                ]
         [tstdir 'simona\simona-scaloost-fijn-exvd-v1\mdu_fou\scaloost_fou.mdu' ]
         [tstdir 'simona\Simona_waal_weir\mdu\hf1.mdu'                          ]
         [tstdir 'simona\A80\mdu_zuno\zunov4.mdu'                               ]
         [tstdir 'simona\simona-kustzuid-2004-v4\mdu\kzv4.mdu'                  ]
         [tstdir 'simona\A80\mdu\dcsmv6.mdu'                                    ]};

for itest = 1 : length(filmdf)

    [path_mdu,name_mdu,~] = fileparts(filmdu{itest});
    if ~isdir(path_mdu);mkdir(path_mdu);end

    %
    % Convert
    %

    d3d2dflowfm(filmdf{itest},filmdu{itest});

    %
    % Generate the list of files to compare
    %

    files = [];
    iifile = 0;
    contents = dir([path_mdu filesep name_mdu '*']);
    for ifile = 1: length(contents)
        index = strfind (contents(ifile).name,'org');
        if isempty (index)
            iifile = iifile + 1;
            files{iifile}    = [path_mdu filesep contents(ifile).name];
        end
    end

    %
    % Finally: compare
    %

    nesthd_cmpfiles(files,'Filename',['compare_' datestr(now,'yyyymmdd') '.txt']);
end
