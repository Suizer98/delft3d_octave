function simona2mdf_check

tstdir = 'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\';

% check : performs a number of test conversions to check if ewverything went okay

filwaq ={[tstdir 'simona\test_erik\siminp.simN001'                                   ];
         [tstdir 'simona\Testmaas\s1\berekeningen\T1250\siminp.t1250'                ];
         [tstdir 'simona\Simona_waal_weir\siminp.hf1'                                ];
         [tstdir 'simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp'    ];
         [tstdir 'simona\A80\siminp.dcsmv6'                                          ];
         [tstdir 'simona\tidal_flume_triwaq\triwaq_coarse\siminp.009'                ];
         [tstdir 'simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4'    ];
         [tstdir 'simona\tidal_flume_triwaq\triwaq_small_3\siminp.small'             ];
         [tstdir 'simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp.fou'];
         [tstdir 'simona\A80\siminp.zunov4'                                          ]};
filmdf ={[tstdir 'simona\test_erik\mdf\N001.mdf'                                     ];
         [tstdir 'simona\Testmaas\mdf_t1250\t1250.mdf'                               ];
         [tstdir 'simona\Simona_waal_weir\mdf\hf1.mdf'                               ];
         [tstdir 'simona\simona-scaloost-fijn-exvd-v1\mdf\scaloost.mdf'              ];
         [tstdir 'simona\A80\mdf_csm\dcsmv6.mdf'                                     ];
         [tstdir 'simona\tidal_flume_triwaq\mdf_coarse\coarse.mdf'                   ];
         [tstdir 'simona\simona-kustzuid-2004-v4\mdf\kzv4.mdf'                       ];
         [tstdir 'simona\tidal_flume_triwaq\mdf_small\small.mdf'                     ];
         [tstdir 'simona\simona-scaloost-fijn-exvd-v1\mdf_fou\scaloost_fou.mdf'      ];
         [tstdir 'simona\A80\mdf_zuno\zunov4.mdf'                                    ]};

for itest = 1 : length(filwaq)

    [path_mdf,name_mdf,~] = fileparts(filmdf{itest});
    if ~isdir(path_mdf);mkdir(path_mdf);end

    %
    % Convert
    %

    simona2mdf(filwaq{itest},filmdf{itest});

    %
    % Generate the list of files to compare
    %

    files = [];
    iifile = 0;
    contents = dir([path_mdf filesep name_mdf '*']);
    for ifile = 1: length(contents)
        index = strfind (contents(ifile).name,'org');
        if isempty (index)
            iifile = iifile + 1;
            files{iifile}    = [path_mdf filesep contents(ifile).name];
        end
    end

    %
    % Finally: compare
    %
    nesthd_cmpfiles(files,'Filename',['compare_' datestr(now,'yyyymmdd') '.txt']);
end
