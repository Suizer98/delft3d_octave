function newico (figure,Iconfile)

%
% Repaces matlab icon by other one (stored in "Iconfile")
%

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(figure,'javaframe');
jIcon=javax.swing.ImageIcon(Iconfile);
jframe.setFigureIcon(jIcon);
