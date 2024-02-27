function varargout = parseSoapResponse(response)
%parseSoapResponse Convert the response from a SOAP server into MATLAB types.
%   parseSoapResponse(RESPONSE) converts RESPONSE, a string returned by a SOAP
%   server, into a cell array of appropriate MATLAB datatypes.
%
%   Example:
%
%   message = createSoapMessage( ...
%       'urn:xmethods-delayed-quotes', ...
%       'getQuote', ...
%       {'GOOG'}, ...
%       {'symbol'}, ...
%       {'{http://www.w3.org/2001/XMLSchema}string'}, ...
%       'rpc');
%   response = callSoapService( ...
%       'http://64.124.140.30:9090/soap', ...
%       'urn:xmethods-delayed-quotes#getQuote', ...
%       message);
%   price = parseSoapResponse(response)
%
%   See also createClassFromWsdl, createSoapMessage, callSoapService.

% Matthew J. Simoneau, June 2003
% $Revision: 8189 $  $Date: 2013-02-26 19:52:21 +0800 (Tue, 26 Feb 2013) $
% Copyright 1984-2007 The MathWorks, Inc.

% Parse the text into a DOM.
d = org.apache.xerces.parsers.DOMParser;
try
    d.parse(org.xml.sax.InputSource(java.io.StringReader(response)));
catch
    error('MATLAB:parseSoapResponse:BadXml','The server''s response was not valid XML:\n\n%s',char(response));
end
response = d.getDocument;

% Extract the SOAP envelope.
envelope = getFirstChildElementNode(response);
if ~isequal(getLocalPart(char(envelope.getNodeName)),'Envelope')
    % Started with a header.  The envelope must be next.
    envelope = getNextSiblingElementNode(envelope);
end

% Extract the SOAP body.
soapBody = getFirstChildElementNode(envelope);
if ~isequal(getLocalPart(char(soapBody.getNodeName)),'Body')
    % Started with a header.  The body must be next.
    soapBody = getNextSiblingElementNode(soapBody);
end

% Pull the result node out of the SOAP Body.
resultNode = getFirstChildElementNode(soapBody);

% If the server returned a fault, turn it into an error.
if strcmp(char(resultNode.getLocalName),'Fault')
    faultstringNode = response.getElementsByTagName('faultstring').item(0);
    error('MATLAB:parseSoapResponse:SoapFault','SOAP Fault: %s',char(faultstringNode.getTextContent))
end

% Convert XML to a structure of appropriate MATLAB values.
results = convert(resultNode);
if isempty(results)
    varargout = {};
else
    varargout = struct2cell(results);
end

%===============================================================================
function s = convert(d)

nChildren = d.getChildNodes.getLength;
nextChild = d.getFirstChild;
if (nChildren == 0)
    href = d.getAttribute('href');
    if href.length == 0
        % Real data, but empty value.
        s = convertType(...
            '', ...
            char(d.getAttribute('xsi:type')));
    else
        % A reference to a node elsewhere.
        href = href.substring(1,href.length);
        n = getNodeById(d.getOwnerDocument.getDocumentElement,href);
        s = convert(n);
    end
elseif (nextChild.getNodeType == nextChild.TEXT_NODE) && (nChildren == 1)
    % We've reached real data.  Convert it.
    s = convertType(...
        char(nextChild.getNodeValue), ...
        char(d.getAttribute('xsi:type')));
else
    s = [];
    while ~isempty(nextChild)
        if (nextChild.getNodeType ~= nextChild.TEXT_NODE)

            name = char(nextChild.getNodeName);
            name = name(max([find(name == ':') 0])+1:end);
            name = genfieldname(name);
            value = convert(nextChild);

            attributes=[];
            if nextChild.hasAttributes
                theAttributes = nextChild.getAttributes;
                numAttributes = theAttributes.getLength;
                for count = 1:numAttributes
                    attrib = theAttributes.item(count-1);
                    attributes.(char(attrib.getName))=char(attrib.getValue);
                end
            end
            
            if isfield(s,name)
                s.(name)(nn+1).(name) = value;
            else
                s.(name).(name) = value;
            end
            nn=length(s.(name));
            if ~isempty(attributes)
                s.(name)(nn).(name).ATTRIBUTES = attributes;
            end
                      
        end
        nextChild = nextChild.getNextSibling;
    end
    % The CHAR below is to handle the empty case.
    if ~isempty(regexp(char(d.getAttribute('xsi:type')),':Array$'))
        if length(fieldnames(s)) == 1
            s = s.(name);
        else
            error('MATLAB:parseSoapResponse:NonUnique','Non-unique elements.')
        end
    end
end

%===============================================================================
function value = convertType(value,type)
% Convert each primitive type to a MATLAB-friendly type.

% TODO: Handle namespaces properly.
type = type(max([find(type == ':') 0])+1:end);

% If "type" is empty, make sure it is a CHAR.
type = char(type);
switch type
    case 'string'
        % Leave it alone.
    case 'boolean'
        switch value
            case 'false'
                value = false;
            case 'true'
                value = true;
            otherwise
                error('MATLAB:parseSoapResponse:BadBoolean','Boolean value is neither true nor false.');
        end
    case {'int','integer','decimal','double'}
        value = str2double(value);
    case 'float'
        value = single(str2double(value));
    case {'base64','base64Binary'}
        % switch from axis1 to axis2
        % was: value = org.apache.ws.commons.util.Base64.decode(value); 
        javaString = java.lang.String(value); 
        byteArray = javaString.getBytes();
        value = org.apache.commons.codec.binary.Base64.decodeBase64(byteArray);
    otherwise
        %disp(sprintf('Unknown type: "%s".',type))
end


%===============================================================================
function child = getFirstChildElementNode(node)
child = node.getFirstChild;
while ~isempty(child) && (child.getNodeType ~= child.ELEMENT_NODE)
    child = child.getNextSibling;
end

%===============================================================================
function sibling = getNextSiblingElementNode(node)
sibling = node.getNextSibling;
while ~isempty(sibling) && (sibling.getNodeType ~= sibling.ELEMENT_NODE)
    sibling = sibling.getNextSibling;
end

%===============================================================================
function s = getLocalPart(s)
s = regexprep(s,'.*[}:]','');

%===============================================================================
function s = genfieldname(s)
s = strrep(s,'-','_');

%===============================================================================
function n = getNodeById(next,id)
n = [];
while ~isempty(next) && isempty(n)
    if (next.getNodeType == next.ELEMENT_NODE)
        if strcmp(char(next.getAttribute('id')),id)
            n = next;
            break
        end
        n = getNodeById(next.getFirstChild,id);
    end
    next = next.getNextSibling;
end
