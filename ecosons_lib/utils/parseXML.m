% [xmlout, tagC, tagE]=parseXML(txt, xmlin)
% Parses a text holding xml document
% txt: xml document or part of it
% xmlin: the tag holding the document (or an empty document)
% xmlout: octave struct holding the tag/document
%  xmlout._name: tag name
%  xmlout._prefix: tag prefix
%  xmlout._attribute: attribute
%  xmlout.child: child xml tag
%  xmlout.children(): same tag children list
% tagC: boolean indicating whether the tag has been closed
% tagE: position of txt where parsing has stopped (next character)
function [xmlout, tagC, tagE]=parseXML(txt, xmlin)
  
  if( ~exist('xmlin') )
    xmlout=struct;
    xmlout.__name='.';
  else
    xmlout=xmlin;
  endif
  
  %straighten the text out (no newlines)
  txt=strrep(strrep(txt, "\n", " "), "\r", "");

  p=1;
  while( p < length(txt) )
  
    %closing tag: return
    [S,E]=regexp(txt(p:end), ['^</' xmlout.__name '\s*>']);
    if( any(S) )
      tagC=true;
      tagE=p+E;
      break;
    endif

    %spaces: ignore
    [S,E]=regexp(txt(p:end), '^\s+');
    if( any(S) )
      p=p+E;
      continue;
    endif
    
    %initial XML declaration: ignore
    [S,E]=regexp(txt(p:end), '^<\?xml\s.+\?>');
    if( any(S) )
      p=p+E;
      continue;
    endif
    
    %tag
    [S,E]=regexp(txt(p:end), ['^<([a-zA-Z:]+)\s*(([a-zA-Z:]+)=("([^"]+)"|' "'" '([^' "'" ']+)' "'" ')\s*)+\s*/*>']);
    if( any(S) )

      [sxml,stagC,stagE]=parseXMLTag(txt(p+S-1:p+E-1));
      
      %if the tag was not autoclosed read the contents
      if( ~stagC )
        [sxml, stagC, stagE]=parseXML(txt(p+E:end), sxml);
        p=p+E+stagE;
      else
        p=p+E;
      endif
      
      %append field (if there was a previous one, add as a struct array)
      if( isfield(xmlout, sxml.__name) )
        f=getfield(xmlout, sxml.__name);
        f(end+1)=sxml;
        xmlout=setfield(xmlout, sxml.__name, f);
      else
        xmlout=setfield(xmlout, sxml.__name, sxml);
      endif
      
      continue
    endif
    
    %text in between: ignore?
    [S,E]=regexp(txt(p:end), '^[^<]+');
    if( any(S) )
      %!!! ignore?
      p=p+E;
      continue
    endif
    
    %spare <: ignore error
    if( txt(p) == '<' )
     p=p+1;
    endif
  
  endwhile
  
  tagE=p;
  
endfunction

%[xml, tagC, tagE]=parseXMLTag(txt)
function [xml, tagC, tagE]=parseXMLTag(txt)
  
  xml=struct;
  tagC=false;
  
  %tag name
  [S,E, TE]=regexp(txt, '^<(([a-zA-Z]+):)*([a-zA-Z]+)\s+');
  if( size(TE{1},1) > 1 )
    xml.__prefix=txt(TE{1}(2,1):TE{1}(2,2));
    xml.__name=txt(TE{1}(3,1):TE{1}(3,2));
  else
    xml.__name=txt(TE{1}(1,1):TE{1}(1,2));
  endif


  p=1+E;
  while( p < length(txt) )

    [S,E, TE]=regexp(txt(p:end), ['^([a-zA-Z]+)\s*=\s*("([^"]+)"|' "'" '([^' "'" ']+)' "'" ')\s*']);
    if( any(S) )
      xml=setfield(xml, [ '_' txt(p-1+[TE{1}(1,1):TE{1}(1,2)]) ], txt(p-1+[TE{1}(3,1):TE{1}(3,2)]));
      p=p+E;
      continue
    endif
    
    [S,E]=regexp(txt(p:end), '^/>');
    if( any(S) )
      tagC=true;
      tagE=p+E;
      return
    endif
    
    [S,E]=regexp(txt(p:end), '^>');
    if( any(S) )
      tagC=false;
      tagE=p+E;
      return
    endif
    
    %syntax error: skip one character
    p=p+1;
    
  endwhile

  tagE=p;
  
endfunction
