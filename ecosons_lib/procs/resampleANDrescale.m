%Resamples an interval of a signal P to a given
% length also performing an intensity correction
% in order to keep energy constant
%rP=resampleANDrescale(P,nfr,nto,lgt, method)
% P: selected part of a ping to be resampled
% nfr, nto: from and to limits of the subsample
% lgt: length of the resampled data
% rP: resampled and rescaled version of P
%Note: only the simplest methods 'copy' and 'linear'
% are currently implemented
function rP=resampleANDrescale(P,nfr,nto,lgt,method)
 
 rP=nan*zeros(size(P,1),lgt); %create for faster memory initialization
 
 if( strcmp(method, 'copy') ) % plain copy method
 
  for n=1:size(P,1)
  
   % old equivalences for new positions
   rhit=floor( nfr(n)+[0:lgt-1]*(nto(n)-nfr(n)+1)/lgt );
   
   Pnfr=P(n, nfr(n):nto(n) );
   Pnfr=Pnfr( ~isnan(Pnfr) );
   Prhit=P(n, rhit         );
   Prhit=Prhit( ~isnan(Pnfr) );

   sP =nnsum( power(10, Pnfr/10) );   % old power sum
   ssP=nnsum( power(10, Prhit/10) );   % "new" power sum


   if( ssP~= 0 )
    %rP(n,:)=10*log10(sP/ssP)+P(n,rhit); %new renormalized power
    rP(n,:)=P(n,rhit);
   else
    rP(n,:)=P(n,rhit);
   endif

  
  endfor

 elseif( strcmp(method, 'linear') ) % linear interpolation
 
  for n=1:size(P,1)
  
   % old equivalences for new positions
   rhit=nfr(n)+[0:lgt-1]*(nto(n)-nfr(n)+1)/lgt;
   
   % previous and next prev
   nhit=min( floor(rhit), size(P,2));
   mhit=min(floor(rhit+1), size(P,2));

   % interpolating fractions
   whit=(mhit-rhit);

   Pnfr=P(n, nfr(n):nto(n) );
   
   sP =nnsum( power(10, Pnfr/10) );   % old power sum

   pwrn=   whit .*power(10, P(n,nhit)/10)+...
        (1-whit).*power(10, P(n,mhit)/10); %interpolated power (linear)

   ssP=nnsum( pwrn );   % "new" power sum

   if( ssP~= 0 )
    %rP(n,:)=10*log10( (sP/ssP)*pwrn );
    rP(n,:)=10*log10( pwrn );
   else
    rP(n,:)=10*log10( pwrn );
   endif
   
  endfor

 else
  rP=[];
 endif


endfunction

