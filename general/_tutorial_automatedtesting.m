%% 3. Automated testing
% Developing an extensive toolbox with multiple developers working on the same set of functions can 
% create problems when one of the main engines is adjusted. To overcome this problem many projects
% tend to write test functions for these key-functions in which the basic functionalities are
% recorded and tested. Within the framework of OpenEarthTools a matlab based test environment is
% developed to facilitate testing of the functions.
% 
% <html>
% <table border="0" cellpadding="5" width="100%">
%   <tr valign="top">
%       <td width="400">
%           <a class="relref" href="testsInGeneral_tutorial.html" relhref="testsInGeneral_tutorial.html">Tests in general and in OpenEarthTools</a>
%       </td>
%       <td width="600">
%           General information about various types of tests and how we should use them in OpenEarthTools.
%       </td>
%   </tr>
%   <tr valign="top">
%       <td width="400">
%           <a class="relref" href="testdefinitions_tutorial.html" relhref="testdefinitions_tutorial.html">Creating a test</a>
%       </td>
%       <td width="600">
%           Describes how to write your own testdefinition and what possibilities the test toolbox has regarding to documenting your testcases.
%       </td>
%   </tr>
%   <tr valign="top">
%       <td width="400">
%           <a class="relref" href="runningatest_tutorial.html" relhref="runningatest_tutorial.html">Running an individual test</a>
%       </td>
%       <td width="600">
%           There are vaious ways to run a test created according to the definition used in OpenEarthTools. This document describes how to run an individual test.
%       </td>
%   </tr>
%   <tr valign="top">
%       <td width="400">
%           <a class="relref" href="runtestswithmtestengine_tutorial.html" relhref="runtestswithmtestengine_tutorial.html">Automated testing</a>
%       </td>
%       <td width="600">
%           Describes the basics of testing with the mtest toolbox.
%       </td>
%   </tr>
% </table> 
% </html>
%
% <html>
% <style>
% #notediv {
%   background-color:   #D8E4F1;
%   border:             solid; 
%   border-width:       1px;  
%   padding:            10px;
%   }
% </style>
% <div id="notediv">
%   <strong>
%       <p>Tests are meant to check the basic functionalities of functions in the most simple form, so:</p> 
%       <ul>
%           <li>Test are not meant to show off, keep the tests as simple as possible!!!</li>
%           <li>Do not write a test that needs user input</li>
%           <li>Do not write a test that needs an internet connection to run</li>
%       </ul>
%       <p>(Tests that do need user input will be added to the ignore list for automatic testing of the toolbox)</p>
%   </strong>
% </div>
% </html>
