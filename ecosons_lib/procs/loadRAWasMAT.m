%Loads the MAT version of a RAW echosounder file
% loadRAWasMAT(fn, ch)
% fn: file name (without extension)
% ch: echosounder signal channel to be loaded
function [P,Q,G]=loadRAWasMAT(fn, ch)

 if( ch==1 )
  load([fn, '.mat'], "P1", "Q1", "G");
  P=P1;
  Q=Q1;
 elseif( ch==2 )
  load([fn, '.mat'], "P2", "Q2", "G")
  P=P2;
  Q=Q2;
 endif

endfunction

