function xyzp=intershapes(xyzs, shns, dl)
  np=0;
  xyzp=[];
  for s=unique(shns)'
    xyz=xyzs(shns==s,:);
    xya=xyz(1,:);
    np=np+1;
    xyzp(np,:)=xya;
    for n=2:size(xyz,1)
      if( isnan(xyz(n,1)) )
        if( n+1<size(xyz,1) )
          xya=xyz(n+1,:);
        endif
        continue
      endif       
      dxy=xyz(n,1:2)-xya(1:2);
      mm=round(norm(dxy)/dl);
      for m=1:mm
        np=np+1;
        xyzp(np,:)=(xyz(n,:)*m+xya*(mm-m))/mm;
      endfor
      xya=xyz(n,:);
    endfor
  endfor
  
endfunction
