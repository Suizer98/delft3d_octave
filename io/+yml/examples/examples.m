%% Examples for reading reading
fname1  = 'C:\checkouts\votools\trunk\matlab\io\+yml\examples\ibm_example.yml';
result1 = yml.read(fname1); %, nosuchfileaction, makeords, treatasdata, dictionary)

fname2 = 'C:\checkouts\votools\trunk\matlab\io\+yml\examples\yaml_start.yml';
result2 = yml.read(fname2); %, nosuchfileaction, makeords, treatasdata, dictionary)

%% Examples for writing
fname1w = 'C:\checkouts\votools\trunk\matlab\io\+yml\examples\ibm_example_witten.yml';
yml.write(fname1w, result1)
result1r = yml.read(fname1w);

fname2w = 'C:\checkouts\votools\trunk\matlab\io\+yml\examples\yaml_start_witten.yml';
yml.write(fname2w, result2)
result2r = yml.read(fname2w);

