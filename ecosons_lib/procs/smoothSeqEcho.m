%[sP,m,snr] = smoothSeqEcho (P, n, mmax, snrObj)
%Compute a smoothed version of the n-th echo by averaging (actually
% computes the median) an interval of echoes so that the bin-to-bin
% variability is below a signal-to-noise-ratio objective (data are
% assumed in dB). The smoothed version is returned as well as the number
% of echoes averaged and the SNR attained.
%P: matrix with one echo per row
%n: number of the echo to start smoothing from
%mmax: maximum number of echoes to use in smoothing
%snrObj: SNR objective computed from bin-to-bin differences in the echo
%sP: smoothed echo
%m: number of echoes used in smoothing
%snr: bin-to-bin mean differences (SNR) attained
function [sP,m,snr] = smoothSeqEcho (P, n, mmax, snrObj)
  m=0;
  na=nb=n;
  sP=P(n,:);
  snr=mean( abs(diff(sP(~isnan(sP)))) );
  while(snr>snrObj && m<mmax)
    m=m+1;
    na=max(1,n-m);
    nb=min(size(P,1),n+m);
    sP=median(P(na:nb,:));
    snr=mean( abs(diff(sP(~isnan(sP)))) );
  endwhile
  
  m=nb-na+1;
  
endfunction
