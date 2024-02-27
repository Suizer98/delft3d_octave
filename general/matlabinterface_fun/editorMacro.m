function bindingsList = editorMacro(keystroke, macro, macroType)
% EditorMacro assigns a macro to a keyboard key-stroke in the Matlab-editor
%
% Syntax:
%    bindingsList = EditorMacro(keystroke, macro, macroType)
%    bindingsList = EditorMacro(bindingsList)
%
% Description:
%    EditorMacro assigns the specified MACRO to the requested keyboard
%    KEYSTROKE, within the context of the Matlab editor.
%
%    KEYSTROKE is a string representation of the keyboard combination.
%    Special modifiers (Alt, Ctrl or Control, Shift, Meta, AltGraph) are
%    recognized and should be separated with a space, dash (-), plus (+) or
%    comma (,). At least one of the modifiers should be specified, otherwise
%    very weird things will happen...
%    For a full list of supported keystrokes, see:
%    <a href="http://tinyurl.com/2s63e9">http://java.sun.com/javase/6/docs/api/java/awt/event/KeyEvent.html</a>
%    If KEYSTROKE was already defined, then it will be updated (overridden).
%
%    MACRO should be in one of Matlab's standard callback formats: 'string',
%    @FunctionHandle or {@FunctionHandle,arg1,...} - read MACROTYPE below
%    for a full description. To remove a KEYSTROKE-MACRO definition, simply
%    enter an empty MACRO ([], {} or '').
%
%    MACROTYPE is an optional input argument specifying the type of action
%    that MACRO is expected to do:
%
%     - 'text' (=default value) indicates that if the MACRO is a:
%        1. 'string': this string will be inserted as-is into the current
%             editor caret position (or replace the selected editor text).
%             Multi-line strings can be set using embedded \n's (example: 
%             'Multi-line\nStrings'). This can be used to insert generic
%             comments or code templates (example: 'try \n catch \n end').
%        2. @FunctionHandle -  the specified function will be invoked with
%             two input arguments: the editorPane object and the eventData
%             object (the KEYSTROKE event details). FunctionHandle is
%             expected to return a string which will then be inserted into
%             the editor document as expained above.
%        3. {@FunctionHandle,arg1,...} - like #2, but the function will be
%             called with the specified arg1+ as input args #3+, following
%             the editorPane and eventData args.
%
%     - 'run' indicates that MACRO should be invoked as a Matlab command,
%             just like any regular Matlab callback. The accepted MACRO
%             formats and function input args are exactly like for 'text'
%             above, except that no output string is expected and no text
%             insertion/replacement will be done (unless specifically done
%             within the invoked MACRO command/function). This MACROTYPE is
%             useful for closing/opening files, moving to another document
%             position and any other non-textual action.
%
%    BINDINGSLIST = EditorMacro returns the list of currently-defined
%    KEYSTROKE bindings as a 3-columned cell array:{keystroke,macro,type}.
%
%    BINDINGSLIST = EditorMacro(KEYSTROKE,MACRO) returns the bindings list
%    after defining a specific KEYSTROKE-MACRO binding.
%
%    EditorMacro(BINDINGSLIST) can be used to set a bunch of key bindings
%    using a single command. BINDINGSLIST is the cell array returned from
%    a previous invocation of EditorMacro, or by manual construction (just
%    be careful to set the keystroke strings correctly!).
%
% Examples:
%    bindingsList = EditorMacro;  % get list of current key-bindings
%    EditorMacro('Ctrl Shift C', '%%% Main comment %%%\n% \n% \n% \n');
%    EditorMacro('Alt-x', 'try\n  % Main code here\ncatch\n  % Exception handling here\nend');
%    EditorMacro('Ctrl-Alt C', @myCallbackFunction);  % myCallbackFunction returns a string to insert
%    EditorMacro('Alt control t', @(a,b)datestr(now), 'text');  % insert current timestamp
%    EditorMacro('Shift-Control d', {@computeDiameter,3.14159}, 'run');
%
% Known limitations (=TODO for future versions):
%    1. Multi-keystroke bindings (e.g., 'alt-U,L') are not supported
%    2. EditorMacro KEYSTROKEs operate independently of the editor's
%       so you cannot override the default keybindings. For example,
%       if you set 'Ctrl-R', you'll get both your macro and the default
%       editor action (=comment the selection).
%    3. In Matlab 6, macro insertions are un-undo-able (ok in Matlab 7)
%    4. Key bindings are sometimes lost when switching between a one-document
%       editor and a two-document one (i.e., adding/closing the second doc)
%    5. Key bindings are not saved between editor sessions
%    6. In split-pane mode, when inserting a macro on the secondary (right/
%       bottom) pane, then both panes (and the actual document) are updated
%       but the secondary pane does not display the inserted macro (the
%       primary pane looks ok).
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 6 & 7+, but use at your own risk!
%
%    A technical description of the implementation can be found at:
%    <a href="http://undocumentedmatlab.com/blog/EditorMacro/">http://UndocumentedMatlab.com/blog/EditorMacro/</a>
%
% Change log:
%    2009-07-01: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>

% Programmed by Yair M. Altman: altmany(at)gmail.com
% $Revision: 901 $  $Date: 2009-09-02 20:44:04 +0800 (Wed, 02 Sep 2009) $

  persistent appdata
  try
      % Check input args
      if nargin == 1 & ~iscell(keystroke)  %#ok Matlab 6 compatibility
          myError('YMA:EditorMacro:missingArg','missing MACRO input argument');
      elseif nargin ==2
          macroType = 'text';
      elseif nargin > 3
          myError('YMA:EditorMacro:tooManyArgs','too many input argument');
      end

      % Try to get the editor's Java handle
      jEditor = getJEditor;
      try
          appdata = getappdata(jEditor,'EditorMacro');
      catch
          % never mind - will use the persistent object...
      end

      % If any macro setting is requested
      if nargin

          % If no EditorMacro has been set yet
          if isempty(appdata)
              % Loop over all the editor's currently-open documents
              jMainPane = getJMainPane(jEditor);
              for docIdx = 1 : jMainPane.getComponentCount
                  % Instrument these documents to catch user keystrokes
                  instrumentDocument([],[],jMainPane.getComponent(docIdx-1),jEditor,appdata);
              end

              % Update the editor's ComponentAdded callback to also instrument new documents
              set(jMainPane,'ComponentAddedCallback',{@instrumentDocument,[],jEditor,appdata})
              if isempty(get(jMainPane,'ComponentAddedCallback'))
                  pause(0.1);
                  set(jMainPane,'ComponentAddedCallback',{@instrumentDocument,[],jEditor,appdata})
              end

              % Set the initial binding hashtable
              appdata = {}; %java.util.Hashtable is better but can't extract {@function}...
          end

          % Update the bindings list with the new key binding
          if nargin > 1
              appdata = updateBindings(appdata,keystroke,macro,macroType);
          elseif iscell(keystroke) & (isempty(keystroke) | size(keystroke,2)==3) %#ok Matlab 6 compatibility
              appdata = keystroke;
          else
              myError('YMA:EditorMacro:invalidBindingsList','invalid BINDINGSLIST input argument');
          end
          setappdata(jEditor,'EditorMacro',appdata);
      end

      % Check if output is requested
      if nargout
          if ~iscell(appdata)
              appdata = {};
          end
          bindingsList = appdata;
      end

  % Error handling
  catch
      handleError;
  end

%% Get the Java editor component handle
function jEditor = getJEditor
  jEditor = [];
  try
      % Matlab 7
      jEditor = com.mathworks.mde.desk.MLDesktop.getInstance.getGroupContainer('Editor');
  catch
      % Matlab 6
      try
          %desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop; % no use - can't get to the editor from here...
          openDocs = com.mathworks.ide.editor.EditorApplication.getOpenDocuments;  % a java.util.Vector
          firstDoc = openDocs.elementAt(0);  % a com.mathworks.ide.editor.EditorViewContainer object
          jEditor = firstDoc.getParent.getParent.getParent;  % a com.mathworks.mwt.MWTabPanel or com.mathworks.ide.desktop.DTContainer object
      catch
          myError('YMA:EditorMacro:noEditor','Cannot retrieve the Matlab editor handle - possibly no open documents');
      end
  end
  if isempty(jEditor)
      myError('YMA:EditorMacro:noEditor','Cannot retrieve the Matlab editor handle');
  end
  try
      jEditor = handle(jEditor,'CallbackProperties');
  catch
      % never mind - might be Matlab 6...
  end

%% Get the Java editor's main documents container handle
function jMainPane = getJMainPane(jEditor)
  jMainPane = [];
  try
      v = version;
      if (v(1) >= '7')
          for childIdx = 1 : jEditor.getComponentCount
              if isa(jEditor.getComponent(childIdx-1),'com.mathworks.mwswing.desk.DTMaximizedPane') | ...
                 isa(jEditor.getComponent(childIdx-1),'com.mathworks.mwswing.desk.DTFloatingPane')  | ...
                 isa(jEditor.getComponent(childIdx-1),'com.mathworks.mwswing.desk.DTTiledPane')  %#ok Matlab 6 compatibility
                  jMainPane = jEditor.getComponent(childIdx-1);
                  break;
              end
          end
          if isa(jMainPane,'com.mathworks.mwswing.desk.DTFloatingPane')
              jMainPane = jMainPane.getComponent(0);  % a com.mathworks.mwswing.desk.DTFloatingPane$2 object
          end
      else
          for childIdx = 1 : jEditor.getComponentCount
              if isa(jEditor.getComponent(childIdx-1),'com.mathworks.mwt.MWGroupbox') | ... 
                 isa(jEditor.getComponent(childIdx-1),'com.mathworks.ide.desktop.DTClientFrame') %#ok Matlab 6 compatibility
                  jMainPane = jEditor.getComponent(childIdx-1);
                  break;
              end
          end
      end
  catch
      % Matlab 6 - ignore for now...
  end
  if isempty(jMainPane)
      myError('YMA:EditorMacro:noMainPane','Cannot find the Matlab editor''s main document pane');
  end
  try
      jMainPane = handle(jMainPane,'CallbackProperties');
  catch
      % never mind - might be Matlab 6...
  end

%% Internal error processing
function myError(id,msg)
  v = version;
  if (v(1) >= '7')
      error(id,msg);
  else
      % Old Matlab versions do not have the error(id,msg) syntax...
      error(msg);
  end

%% Error handling routine
function handleError
      v = version;
      if v(1)<='6'
          err.message = lasterr;  %#ok no lasterror function...
      else
          err = lasterror;  %#ok
      end
      try
          err.message = regexprep(err.message,'Error .* ==> [^\n]+\n','');
      catch
          try
              % Another approach, used in Matlab 6 (where regexprep is unavailable)
              startIdx = findstr(err.message,'Error using ==> ');
              stopIdx = findstr(err.message,char(10));
              for idx = length(startIdx) : -1 : 1
                  idx2 = min(find(stopIdx > startIdx(idx)));  %#ok ML6
                  err.message(startIdx(idx):stopIdx(idx2)) = [];
              end
          catch
              % never mind...
          end
      end
      if isempty(findstr(mfilename,err.message))
          % Indicate error origin, if not already stated within the error message
          err.message = [mfilename ': ' err.message];
      end
      if v(1)<='6'
          while err.message(end)==char(10)
              err.message(end) = [];  % strip excessive Matlab 6 newlines
          end
          error(err.message);
      else
          rethrow(err);
      end

%% Main keystroke callback function
function instrumentDocument(jObject,jEventData,jDocPane,jEditor,appdata)  %#ok jObject is unused
  try
      if isempty(jDocPane)
          % This happens when we get here via the jEditor's ComponentAddedCallback
          % (when adding a new document pane)
          try
              % Matlab 7
              jDocPane = jEventData.getChild;
          catch
              % Matlab 6
              eventData = get(jObject,'ComponentAddedCallbackData');
              jDocPane = eventData.child;
          end
      end
      try
          % Matlab 7   TODO: good for ML 7.1-7.7: need to check other versions
          jSyntaxTextPaneView = getDescendent(jDocPane,[0,0,1,0,0,0,0]);
          if isa(jSyntaxTextPaneView,'com.mathworks.widgets.SyntaxTextPaneMultiView$1')
              hEditorPane(1) = handle(getDescendent(jSyntaxTextPaneView.getComponent(1),[1,0,0]),'CallbackProperties');
              hEditorPane(2) = handle(getDescendent(jSyntaxTextPaneView.getComponent(2),[1,0,0]),'CallbackProperties');
          else
              jEditorPane = getDescendent(jSyntaxTextPaneView,[1,0,0]);
              hEditorPane = handle(jEditorPane,'CallbackProperties');
          end
      catch
          % Matlab 6
          hEditorPane = getDescendent(jDocPane,[0,0,0,0]);
      end

      % Note: KeyTypedCallback is called less frequently (i.e. better),
      % ^^^^  but unfortunately it does not catch alt/ctrl combinations...
      %set(hEditorPane, 'KeyTypedCallback', {@keyPressedCallback,jEditor,appdata,hEditorPane});
      set(hEditorPane, 'KeyPressedCallback', {@keyPressedCallback,jEditor,appdata,hEditorPane});
      pause(0.01);  % needed in Matlab 6...
  catch
      % never mind - might be Matlab 6...
  end

%% Recursively get the specified children
function child = getDescendent(child,listOfChildrenIdx)
  if ~isempty(listOfChildrenIdx)
      child = getDescendent(child.getComponent(listOfChildrenIdx(1)),listOfChildrenIdx(2:end));
  end

%% Update the bindings list
function appdata = updateBindings(appdata,keystroke,macro,macroType)
  keystroke = normalizeKeyStroke(keystroke);
  %appdata.put(keystroke,macro);  %using java.util.Hashtable is better but can't extract {@function}...
  try
      appdata(strmatch(keystroke,appdata(:,1),'exact'),:) = [];  % clear any possible old binding
  catch
      % ignore - probably empty appdata
  end
  try
      if ~isempty(macro)

          % Normalize the requested macro (if it's a string): '\n', ...
          if ischar(macro)
              macro = sprintf(strrep(macro,'%','%%'));
          end

          % Check & normalize the requested macroType
          if ~ischar(macroType)
              myError('YMA:EditorMacro:badMacroType','bad MACROTYPE input argument - must be a ''string''');
          elseif isempty(macroType) | ~any(lower(macroType(1))=='rt')  %#ok for Matlab6 compatibility
              myError('YMA:EditorMacro:badMacroType','bad MACROTYPE input argument - must be ''text'' or ''run''');
          elseif lower(macroType(1)) == 'r'
              macroType = 'run';
          else
              macroType = 'text';
          end

          % Store the new/updated key-binding in the bindings list
          [appdata(end+1,:)] = {keystroke,macro,macroType};
      end
  catch
      myError('YMA:EditorMacro:badMacro','bad MACRO or MACROTYPE input argument - read the help section');
  end

%% Normalize the keystroke string to a standard format
function keystroke = normalizeKeyStroke(keystroke)
  try
      if ~ischar(keystroke)
          myError('YMA:EditorMacro:badKeystroke','bad KEYSTROKE input argument - must be a ''string''');
      end
      keystroke = strrep(keystroke,',',' ');  % ',' => space (extra spaces are allowed)
      keystroke = strrep(keystroke,'-',' ');  % '-' => space (extra spaces are allowed)
      keystroke = strrep(keystroke,'+',' ');  % '+' => space (extra spaces are allowed)
      [flippedKeyChar,flippedMods] = strtok(fliplr(keystroke));
      keyChar   = upper(fliplr(flippedKeyChar));
      modifiers = lower(fliplr(flippedMods));

      keystroke = sprintf('%s %s', modifiers, keyChar);  % PRESSED: the character needs to be UPPERCASE, all modifiers lowercase
      %keystroke = sprintf('%s typed %s',   modifiers, keyChar);  % TYPED: in runtime, the callback is for Typed, not Pressed

      keystroke = javax.swing.KeyStroke.getKeyStroke(keystroke);  % normalize & check format validity
      keystroke = char(keystroke.toString);  % javax.swing.KeyStroke => Matlab string
      %keystroke = strrep(keystroke, 'pressed', 'released');  % in runtime, the callback is for Typed, not Pressed
      %keystroke = strrep(keystroke, '-P', '-R');  % a different format in Matlab 6 (=Java 1.1.8)...
      if isempty(keystroke)
          myError('YMA:EditorMacro:badKeystroke','bad KEYSTROKE input argument');
      end
  catch
      myError('YMA:EditorMacro:badKeystroke','bad KEYSTROKE input argument - see help section');
  end

%% Main keystroke callback function
function keyPressedCallback(jEditorPane,jEventData,jEditor,appdata,hEditorPane,varargin)
  try
      try
          appdata = getappdata(jEditor,'EditorMacro');
      catch
          % gettappdata() might fail on Matlab 6 so it will fallback to the supplied appdata input arg
      end

      % Normalize keystroke string
      try
          keystroke = javax.swing.KeyStroke.getKeyStrokeForEvent(jEventData);
      catch
          % Matlab 6 - for some reason, all Fn keys don't work with KeyReleasedCallback, but some of them work ok with KeyPressedCallback...
          jEventData = get(jEditorPane,'KeyPressedCallbackData');
          keystroke = javax.swing.KeyStroke.getKeyStroke(jEventData.keyCode, jEventData.modifiers);
          keystroke = char(keystroke.toString);  % no automatic type-casting in Matlab 6...
          jEditorPane = hEditorPane;  % bypass Matlab 6 quirk...
      end

      % If this keystroke was bound to a macro
      macroIdx = strmatch(keystroke,appdata(:,1),'exact');
      if ~isempty(macroIdx)

          % Dispatch the defined macro
          macro = appdata{macroIdx,2};
          macroType = appdata{macroIdx,3};

          switch lower(macroType(1))

              case 't'  % Text
                  if ischar(macro)
                      % Simple string - insert as-is
                  elseif iscell(macro)
                      % feval this cell
                      macro = feval(macro{1}, jEditorPane, jEventData, macro{2:end});
                  else  % assume @FunctionHandle
                      % feval this @FunctionHandle
                      macro = feval(macro, jEditorPane, jEventData);
                  end

                  % Now insert the resulting string into the jEditorPane caret position or replace selection
                  %caretPosition = jEditorPane.getCaretPosition;
                  try
                      % Matlab 7
                      %jEditorPane.insert(caretPosition, macro);  % better to use replaceSelection() than insert()
                      jEditorPane.replaceSelection(macro);
                  catch
                      % Matlab 6
                      %jEditorPane.insert(macro, caretPosition);  % note the reverse order of input args vs. matlab 7...
                      jEditorPane.replaceRange(macro, jEditorPane.getSelStart, jEditorPane.getSelEnd);
                  end
                  
              case 'r'  % Run
                  if ischar(macro)
                      % Simple string - evaluate in the base
                      evalin('base', macro);
                  elseif iscell(macro)
                      % feval this cell
                      feval(macro{1}, jEditorPane, jEventData, macro{2:end});
                  else  % assume @FunctionHandle
                      % feval this @FunctionHandle
                      feval(macro, jEditorPane, jEventData);
                  end
          end
      end
  catch
      % never mind... - ignore error
  end
