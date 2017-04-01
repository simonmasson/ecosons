%Computes the weighted mean value of a vector using as weigths the Fisher scores (ML estimator assuming Gaussian distribution)
% [xm,w]=wmean(x)
% Weights used are returned as the second argument
% If x is a matrix, the average value is computed column by column, and the weigths are computed using the sum of variances along the rows
function [xm,w]=wmean(x)

w=ones(1,size(x,1));

n=10;
do

 w=w/sum(w);
 xm=w*x;

 bb=ones(size(x,1),1)*xm;
  
 wb=sum(power((x-bb)',2));
 ww=sum(wb)/size(x,2);
 
 if(ww>0)
  w=1./(ww+wb);
 else
  w=ones(1,size(x,1));
 endif

n=n-1;
until (n==0);

w=w/sum(w);

endfunction

