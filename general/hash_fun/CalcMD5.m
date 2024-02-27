function MD5 = CalcMD5(varargin)  %#ok<STOUT,INUSD>
% 128 bit MD5 checksum: file, string, byte stream [MEX]
%
% Downloaded from the mathworks file exchange on 8-3-2012 
%
% This function calculates a 128 bit checksum for arrays and files.
% Digest = CalcMD5(Data, [InClass], [OutClass])
% INPUT:
%   Data:   Data array or file name. Either numerical or CHAR array.
%           Currently only files and arrays with up to 2^32 bytes (2.1GB) are
%           accepted.
%   InClass: String to declare the type of the 1st input.
%           Optional. Default: 'Char'.
%           'File': [Data] is a file name as string. The digest is calculated
%                   for this file.
%           'Char': [Data] is a char array to calculate the digest for. Only the
%                   ASCII part of the Matlab CHARs is used, such that the digest
%                   is the same as if the array is written to a file as UCHAR,
%                   e.g. with FWRITE.
%           'Unicode': All bytes of the input [Data] are used to calculate the
%                   digest. This is the standard for numerical input.
%   OutClass: String, format of the output. Just the first character matters.
%           Optional, default: 'hex'.
%           'hex': [1 x 32] string as lowercase hexadecimal number.
%           'HEX': [1 x 32] string as uppercase hexadecimal number.
%           'Dec': [1 x 16] double vector with UINT8 values.
%           'Base64': [1 x 22] string, encoded to base 64 (A:Z,a:z,0:9,+,/).
%
% OUTPUT:
%   Digest: A 128 bit number is replied in a format depending on [OutClass].
%           The chance, that different data sets have the same MD5 sum is about
%           2^128 (> 3.4 * 10^38). Therefore MD5 can be used as "finger-print"
%           of a file rather than e.g. CRC32.
%
% EXAMPLES:
%   Three methods to get the MD5 of a file:
%   1. Direct file access (recommended):
%     MD5 = CalcMD5(which('CalcMD5.m'), 'File')
%   2. Import the file to a CHAR array (binary mode for exact line breaks!):
%     FID = fopen(which('CalcMD5.m'), 'rb');
%     S   = fread(FID, inf, 'uchar=>char');
%     fclose(FID);
%     MD5 = CalcMD5(S, 'char')
%   3. Import file as a byte stream:
%     FID = fopen(which('CalcMD5.m'), 'rb');
%     S   = fread(FID, inf, 'uint8=>uint8');
%     fclose(FID);
%     MD5 = CalcMD5(S, 'unicode');  // 'unicode' can be omitted here
%
%   Test string:
%     CalcMD5(char(0:511), 'char', 'HEX')
%       => F5C8E3C31C044BAE0E65569560B54332
%     CalcMD5(char(0:511), 'unicode', 'HEX')
%       => 3484769D4F7EBB88BBE942BB924834CD
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP, [UnitTest]
% Author: Jan Simon, Heidelberg, (C) 2009-2010 J@n-Simon.De
% License: This program is derived from the RSA Data Security, Inc.
%          MD5 Message Digest Algorithm, RFC 1321, R. Rivest, April 1992
%
% See also CalcCRC32.
% Michael Kleder has published a Java call to compute the MD5 (and further
% check sums): http://www.mathworks.com/matlabcentral/fileexchange/8944

% $JRev: R5.00j V:015 Sum:zh2gTrvHwbd7 Date:17-Dec-2009 02:46:53 $
% $File: CalcMD5\CalcMD5.m $
% History:
% 015: 15-Dec-2009 16:53, BUGFIX: UINT32 has 32 bits on 64 bit systems now.
%      Thanks to Sebastiaan Breedveld!

% If the current Matlab path is the parent folder of this script, the
% MEX function is not found - change the current directory!
% Copyright (c) 2009, Jan Simon
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


% due to issues I do not understand, differen computers require different
% compiled versions of this function. The first time this function is
% called, all available methods are tested
persistent method;

% vs10: compiled with visual studio 10
% lcc: compiled with matlab lcc compiler
if isempty(method)
    try
        MD5 = CalcMD5_vs10('test','Char','hex');
        assert(strcmp(MD5,'098f6bcd4621d373cade4e832627b4f6'));
        method = 1;
    catch %#ok<*CTCH>
        try
            MD5 = CalcMD5_lcc_1('test','Char','hex');
            assert(strcmp(MD5,'098f6bcd4621d373cade4e832627b4f6'));
            method = 2;
        catch
            try
                MD5 = CalcMD5_lcc_2('test','Char','hex');
                assert(strcmp(MD5,'098f6bcd4621d373cade4e832627b4f6'));
                method = 3;
            catch
                error(['JSim:', mfilename, ':NoMex'], 'Cannot find MEX script.');
            end
        end
    end
end

switch method
    case 1
        MD5 = CalcMD5_vs10 (varargin{:});
    case 2
        MD5 = CalcMD5_lcc_1(varargin{:});
    case 3
        MD5 = CalcMD5_lcc_2(varargin{:});
end
  
  

  