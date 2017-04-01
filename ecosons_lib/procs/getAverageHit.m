%Gets the first hits of an array of pings in a
% per ping bases (no ping comparison is performed)
%[hit]=getFirstHit(P,Q, ndB, nndB)
% P: matrix holding one ping per row
% Q: acquisition data corresponding to the pings in P
% ndB: boundary limit of the main lobe (below 5 m depth)
% nndB: background noise limit
% Note: ndB~30dB, according to the directivity function
%  main/secondary lobe criterium; nndB~60dB (¿?)
function [hit]=getAverageHit(P,Q, nearF)

 %threshold index (no depth shallower)
 knf=2*floor( nearF/(Q(1).soundVelocity*Q(1).sampleInterval) );

 %first guess
 lgt=size(P,2);
 
 hit=NaN*zeros(1,size(P,1));
 for k=1:size(P,1)
  pPk=power(10, P(k,knf:lgt)/10);
  pPkr=pPk.*[1:lgt-knf+1];
  hit(k)=nnsum(pPkr)/nnsum(pPk);
  if( isnan(hit(k)) )
   hit(k)=0;
  endif
 endfor

 %refinement
 for k=1:size(P,1)
  pPk=power(10, P(k,knf:lgt)/10);
  lk=min(round(1.5*hit(k)), size(pPk,2));
  llk=max(knf, floor(0.5*hit(k)));
  if( lk>0 )
   pPkr=pPk(1:lk).*[1:lk];
   hit(k)=nnsum(pPkr)/nnsum(pPk);
   if( isnan(hit(k)) )
    hit(k)=0;
   endif
  endif
 endfor
 
 hit=hit+knf-1;
 
 hit=round(hit);

endfunction

