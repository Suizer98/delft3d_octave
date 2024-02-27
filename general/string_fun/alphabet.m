function out=alphabet(in)
%ALPHABET Transforms number to letter(s) or letter(s) to number. 
%
%Syntax:
% letter=alphabet(number)
% number=alphabet(letter)
%
%Input/output:
% number 	=	[integer] number to be convert. If number >26
%				letter multiple letters will be used (like in Excel). 	
% letter 	= [string]
%
%Example:
% alphabet(2) yields 'b'
% alphabet(28) yields 'ab'
% alphabet('c') yields 3

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%		Arcadis, Zwolle, The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%transform letter to number
if ischar(in(1))
	in=lower(in); 
	for k=length(in):-1:1
	  index_k(k)= round(double(char(in(k))-char('a'))+1); 
	  index_k(k)=26^(length(in)-k)*index_k(k);
	 end
	 out=sum(index_k); 
end %end

%transform number to letter
if isnumeric(in)
	outnum=[]; 
	while in>0
		mod_in=mod(in-1,26); 
		outnum=[mod_in,outnum]; 
		in=in-(mod_in+1); 
		in=in/26;
	end
	
	out=[];
	for k=1:length(outnum)
		out=[out,char('a'+outnum(k))]; 
	end
	
end

end %end function alphabet