%Reduce classification using nearest neighbours and then global comparison:
% [CmxL, CCmx, Cmx]=classNNg(Pmx, Nclass, wVar, wNN, gClass)
%Pmx: input features (rows: features; columns: values)
%Nclass: number of classes
%wVar: take into account class variances (0: no, 1: yes, 2: only; otherwise: only consider absolute distances)
%wNN: take into account class sizes
%gClass: perform global classification when gClass classes are found
%CmxL: class labels of the pixels
%CCmx: class label list
%Cmx: class and subclass labels of the pixels (to build a dendrogram)
function [CmxL, CCmx, Cmx]=classMNNg(Pmx, Nclass, wVar, wNN, gClass)

 %classify
 Pvr0=var(Pmx')/size(Pmx,2);
 N=[1:size(Pmx,2)]; %ping enumeration
 Cmx=N;    %ping classification
 CmxL=N;   %ping labels
 CCmx=Cmx; %current label list
 Pnn=ones(1,length(N)); %ping count
 Pmm=Pmx;  %ping mean
 Pvr=zeros(size(Pmx)); %ping feature variances
 Pvv=zeros(size(Pmx)); %ping feature variance variances

 %decimate
 Cmx=1+10*floor(N/10); %ping classification
 CmxL=1+10*floor(N/10); %ping labels
 CCmx=Cmx(1:10:end); %current label list 
 for n=CCmx
  Pnn(n)=sum(CmxL==n);
  Pmm(:,n)=mean(Pmx(:,CmxL==n)');
  Pvr(:,n)=var(Pmx(:,CmxL==n)');
 endfor

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
    yy=(Pnn(n).*Pmm(:,n)+Pnn(n).*Pmm(:,n))./(Pnn(n)+Pnn(m));
    ss=( Pnn(n).*(Pvr(:,n)+power(Pmm(:,n)-yy,2))+...
         Pnn(m).*(Pvr(:,m)+power(Pmm(:,m)-yy,2)) )./(Pnn(n)+Pnn(m));
    switch(wVar)
     case 0
      dd=(power(Pmm(:,n)-yy,2)+power(Pmm(:,m)-yy,2))./ss;
     case 1
      dd=power(Pmm(:,n)-Pmm(:,m),2)./ss;
     case 2
      dd=power(Pmm(:,n)-Pmm(:,m),2)./ss;
     otherwise
      dd=power(Pmm(:,n)-Pmm(:,m),2)./ss;
    endswitch
    d=sum(dd);
    
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
 
    Pmmp=(Pnn(n)*Pmm(:,n)+Pnn(m)*Pmm(:,m))./(Pnn(n)+Pnn(m));
    Pvrp=( Pnn(n)*(Pvr(:,n)+power(Pmm(:,n)-Pmmp,2)) ...
           + Pnn(m)*(Pvr(:,m)+power(Pmm(:,m)-Pmmp,2)) )/(Pnn(n)+Pnn(m));
    Pvv(:,n)=( Pnn(n)*(Pvv(:,n)+power(Pvr(:,n)-Pvrp,2)) ...
           + Pnn(m)*(Pvv(:,m)+power(Pvr(:,m)-Pvrp,2)) )/(Pnn(n)+Pnn(m));
    Pmm(:,n)=Pmmp;
    Pvr(:,n)=Pvrp;
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

