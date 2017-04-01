%ret=gmmenu(title, ...)
%version of menu with support for stored input
%receives the same arguments as menu and behaves much like it
%returns the number of the selected menu option
function ret=gmmenu(title, varargin)
global GMMENU_INPUT;

 ret=0;
 
 while( ~( 0<ret && ret<=length(varargin) ) )

  disp(title);

  for n=1:length(varargin)
   disp( [ '[', num2str(n), ']  ', varargin{n} ] );
  endfor

  if( length(GMMENU_INPUT) > 0 )
   ret=GMMENU_INPUT{1};
   GMMENU_INPUT=GMMENU_INPUT(2:length(GMMENU_INPUT));
  else
   ret=input('Select an option: ');

   if( strcmp( class(ret), 'cell' ) )
    GMMENU_INPUT=ret;
    ret=GMMENU_INPUT{1};
    GMMENU_INPUT=GMMENU_INPUT(2:length(GMMENU_INPUT));
   endif

   if( ~( 0<ret && ret<=length(varargin) ) )
    disp( 'Invalid option; try again.' );
    GMMENU_INPUT={};
   endif
  endif
 
 endwhile

endfunction

