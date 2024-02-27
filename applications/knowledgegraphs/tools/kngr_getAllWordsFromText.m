 function [words_cell]=getAllWordsFromText(fid)
%---------------function     [word]=getAllWordsFromText(fid)--------------------------
%Finds and returns as a vector of strings all the contiguous blocks of
%nonwhitespace characters (ASCII values from 33-126 inclusive) in the
%open (and unread) file identified by fid (e.g. fid = fopen('file.txt','r'));).  
%--------------------------------------------------------------------------

%J O Deasy 14-July-96 j...@bcc.louisville.edu. (Freely distributable.)
%Tested only on Windows 95 and Matlab 4.2c.

file_str=fread(fid,Inf,'char');  
words=[];
word=[];
hit_word=0;

for i=1:length(file_str)  
  next_char=file_str(i);
  if next_char>=33 & next_char<=126
    word=[word next_char];
    hit_word=1;
  end
  if (next_char<33 | next_char>126) & hit_word==1
      words=str2mat(words,setstr(word));
      word=[];
      hit_word=0;
  end
end

cntr = 0;
for i = 1:size(words,1)
    if ~isempty(strtrim(words(i,:)))
        cntr = cntr + 1;
        words_cell{cntr,1} = strtrim(words(i,:));
    end
end