%ret=gminput(prompt)
%ret=gminput(prompt, 's')
%version of input with support for stored input
%receives the same arguments as input and behaves much like it
% in particular, option 's' returns the input as a character string
%returns the value of the input
function ret=gminput(prompt, varargin)
global GMMENU_INPUT;

 if( length(GMMENU_INPUT) > 0 )
  ret=GMMENU_INPUT{1};
  GMMENU_INPUT=GMMENU_INPUT(2:length(GMMENU_INPUT));
 else
  if( length(varargin)>0 && strcmp(varargin{1}, 's') )
   ret=input(prompt, 's');
  else
   ret=input(prompt);
  endif
  
  if( strcmp( class(ret), 'cell' ) )
   GMMENU_INPUT=ret;
   ret=GMMENU_INPUT{1};
   GMMENU_INPUT=GMMENU_INPUT(2:length(GMMENU_INPUT));
  endif
  
 endif

endfunction

