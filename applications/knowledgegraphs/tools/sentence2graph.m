function sentence2graph
fid = fopen('f:\McTools\mc_programs\DelftConStruct\tools\SmallText.txt','r');
[words_cell] = getAllWordsFromText(fid);

for i = 1:size(words_cell,1)-1
    addRelation(words_cell{i},words_cell{i+1},13)
end
% save([fileparts(fileparts(mfilename('fullpath'))) filesep 'graphs' filesep 'testsession.mat'],'session')