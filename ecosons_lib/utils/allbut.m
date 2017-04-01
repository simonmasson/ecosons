function x_sel=allbut(x_all, x_but)

 msk=1;
 for n=x_but

  msk=msk & (x_all~=n);

 endfor

 x_sel=x_all(msk);
 
endfunction

