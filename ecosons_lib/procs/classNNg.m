%Reduce classification using nearest neighbours and then global comparison:
% [CmxL, CCmx, Cmx]=classNNg(Pmx, Nclass, wVar, wNN, gClass)
%Pmx: input feature
%Nclass: number of classes
%wVar: take into account class variances (0: no, 1: yes, 2: only; otherwise: only consider absolute distances)
%wNN: take into account class sizes
%gClass: perform global classification when gClass classes are found
%CmxL: class labels of the pixels
%CCmx: class label list
%Cmx: class and subclass labels of the pixels (to build a dendrogram)
function [CmxL, CCmx, Cmx]=classNNg(Pmx, Nclass, wVar, wNN, gClass)

 %classify
 Pvr0=var(Pmx)/length(Pmx);
 N=[1:length(Pmx)]; %ping enumeration
 Cmx=N;    %ping classification
 CmxL=N;   %ping labels
 CCmx=Cmx; %current label list
 Pnn=ones(1,length(N)); %ping count
 Pmm=Pmx;  %ping mean
 Pvr=zeros(1,length(N)); %ping variance
 Pvv=zeros(1,length(N)); %ping variance variance
 while( length(CCmx)>Nclass )

  length(CCmx)

  %find closest ping pairs
  ncls=floor( 1+length(CCmx)/sqrt(gClass) );
  nncls=0; %counter
  dmin=zeros(1,ncls);
  nmin=zeros(1,ncls);
  mmin=zeros(1,ncls);
  for n=CCmx(1:end-1)
   if( length(CCmx)>gClass )
    nNgh=(CCmx(CCmx>n))(1); %neighbourhood selection: next
   else
    nNgh=CCmx(CCmx>n); %neighbourhood selection: rest
   endif
   for m=nNgh
    switch(wVar)
     case 0
      d=( (Pmm(m)-Pmm(n))**2/(Pvr0+sqrt(Pvr(m)*Pvr(n))) );
     case 1
      d=( (Pmm(m)-Pmm(n))**2/(Pvr0+sqrt(Pvr(m)*Pvr(n))) )...
       +sqrt( (Pvr(m)-Pvr(n))**2/(Pvr0**2+sqrt(Pvv(m)*Pvv(n))) );
     case 2
      d=(Pvr(m)-Pvr(n))**2/(Pvr0**2+sqrt(Pvv(m)*Pvv(n)));
     otherwise
      d=abs(Pmm(m)-Pmm(n));
    endswitch
    if( wNN )
     d=d*(Pnn(m)*Pnn(n));
    endif
    dds=sum(dmin(1:nncls)<=d);
    if(dds<=nncls)
     dmin=[dmin(1:dds), d, dmin(dds+1:end-1)];
     nmin=[nmin(1:dds), n, nmin(dds+1:end-1)];
     mmin=[mmin(1:dds), m, mmin(dds+1:end-1)];
     nncls=nncls+(nncls<ncls);
    endif
   endfor
  endfor

  %compute new class
  for nncls=1:ncls
   n=nmin(nncls);
   m=mmin(nncls);
   if(Cmx(n)==n && Cmx(m)==m)
 
    Pmmp=(Pnn(n)*Pmm(n)+Pnn(m)*Pmm(m))/(Pnn(n)+Pnn(m));
    Pvrp=( Pnn(n)*(Pvr(n)+(Pmm(n)-Pmmp)**2) ...
           + Pnn(m)*(Pvr(m)+(Pmm(m)-Pmmp)**2) )/(Pnn(n)+Pnn(m));
    Pvv(n)=( Pnn(n)*(Pvv(n)+(Pvr(n)-Pvrp)**2) ...
           + Pnn(m)*(Pvv(m)+(Pvr(m)-Pvrp)**2) )/(Pnn(n)+Pnn(m));
    Pmm(n)=Pmmp;
    Pvr(n)=Pvrp;
    Pnn(n)=Pnn(n)+Pnn(m);

    %update labels
    Cmx(m)=n;
    CmxL(CmxL==m)=n;
 
    %label list
    CCmx=Cmx(Cmx==N);
 
   endif
  endfor

 endwhile

 %Order by frequency
 NCmx=[];
 for n=1:length(CCmx)
  NCmx(n)=sum(CmxL==CCmx(n));
 endfor
 [NCmx, sIdx]=sort(NCmx, 'descend');
 CCmx=CCmx(sIdx);

endfunction

