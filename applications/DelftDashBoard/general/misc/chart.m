function chart( fontname )
% CHART Show ANSI-chart like display of characters MATLAB can produce.
%       CHART( 'fontname' ) will display a figure window with all
%       255 characters of the named font in a 16x16 grid.
%       The grid produced by CHART( 'fontname' ) displays the 
%       hexidecimal values for the characters in 'fontname'.
%       Close figure when done, it creates 256 text objects. You may
%       want that memory back!
%
%       Here is an example that shows how to display the summation 
%       symbol as a text object in a plot using the font symbol:
%
%       chart('symbol')
%       a=hex2dec('e5');
%       figure
%       plot(1:10)
%       text(5,5,setstr(a),'fontname','symbol','fontsize',35)


%       Chuck Packard, The Mathworks, Inc., 25 Jan 93
%       This is an unsupported, purely for example, M-file.
%
%
%make a new figure  and axis
%( I'm assuming you want to keep the current graph in the gcf. )
figure;
axis([-1 16 -1 16])
ax = gca;

%
%set font to be used
%
set(ax, 'DefaultTextFontName', fontname )

%
%some other Handle Graphics settings, written out in full.
%See manual for more info.
%
set(ax, 'YDir', 'Reverse', 'Box', 'on')
set(ax, 'YTick', 0:15, 'XTick', 0:15)
set(ax, 'DefaultTextHorizontalAlignment', 'Center')
set(ax, 'DefaultTextVerticalAlignment', 'Bottom')

%
%not vectorized like all 'good' MATLAB M-files, but easier to
%understand!
%
x = reshape( 0:255, 16, 16 );
for h=1:16
   for v=1:16
      text(h-1,v-1,setstr(x(v,h)), 'Interpreter', 'None');
   end
end

axlab = ['0';'1';'2';'3';'4';'5';'6';'7';'8';'9';'A';'B';'C';'D';'E';'F'];
set(gca,'YTick',get(gca,'YTick')-.5)
set(gca,'XTickLabel',axlab,'YTickLabel',axlab)
title('AsciiValue = hex2dec(''XValueYValue'')')
xlabel('XValue')
ylabel('YValue')
