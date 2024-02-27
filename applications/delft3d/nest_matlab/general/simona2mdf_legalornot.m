function simona2mdf_legalornot (figure,Iconfile)

% simona2mdf_legalornot: replaces matlab icon by a diiferent one
%  not sure of this is allowed

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(figure,'javaframe');
jIcon=javax.swing.ImageIcon(Iconfile);
jframe.setFigureIcon(jIcon);
