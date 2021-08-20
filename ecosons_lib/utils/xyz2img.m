function [I, x_min,x_max,y_min,y_max, dxy]=xyz2img(X,Y,Z, dxy, method, fr, pw)
	
	x_min=min(X);
	x_max=max(X);
	y_min=min(Y);
	y_max=max(Y);

	h=1+floor((y_max-y_min)/dxy);
		y_min=y_max-h*dxy;
	w=1+floor((x_max-x_min)/dxy);
		x_max=x_min+w*dxy;
		
	i=1+floor((y_max-Y)/dxy);
	j=1+floor((X-x_min)/dxy);
	
	dd=round(fr/dxy);
	[di,dj]=meshgrid([-dd:dd], [-dd:dd]);
	
	switch(tolower(method))
		case 'mean'
	
			BZ=zeros(h,w);
			BZc=zeros(h,w);
	
			%simple projection
			for n=1:length(X)
				in=i(n); jn=j(n);

				BZ(in,jn)=BZ(in,jn)+Z(n);
				BZc(in,jn)=BZc(in,jn)+1;

				endfor

			%mapa (kernel average) de profundidades: radio 10*dxy metros
			avK=double( sqrt(di.*di+dj.*dj) <= dd );
			BZ=conv2(avK,BZ);
			BZc=conv2(avK,BZc);
			m=(BZc>0);
			BZ(m)=BZ(m)./BZc(m);
			BZ(~m)=NaN;
			I=BZ(1+dd:end-dd,1+dd:end-dd);
			
			clear BZ BZc
			
		case 'idw'

			BZ=zeros(h,w);
			BZc=zeros(h,w);

			if( ~exist('pw') )
				pw=1.0;
			endif
			r=sqrt(di.*di+dj.*dj);
			m=double( (r <= dd) );
			r(dd+1,dd+1)=0.5; %0.25 remarca los transectos
			idw=power(r, -pw) - power(dd, -pw);
			idw(~m)=0;

			for n=1:length(X)
				in=i(n); jn=j(n);

				%producto y clip
				wZ=Z(n)*idw;
				iaa=in-dd; ia=max(1, iaa);
				ibb=in+dd; ib=min(h, ibb);
				jaa=jn-dd; ja=max(1, jaa);
				jbb=jn+dd; jb=min(w, jbb);
		
				%suma ponderada
				BZ(ia:ib, ja:jb) =BZ(ia:ib, ja:jb) +wZ(1+(ia-iaa):end-(ibb-ib), 1+(ja-jaa):end-(jbb-jb));
				BZc(ia:ib, ja:jb)=BZc(ia:ib, ja:jb)+idw(1+(ia-iaa):end-(ibb-ib), 1+(ja-jaa):end-(jbb-jb));
	
			endfor

			m=(BZc>0);
			BZ(m)=BZ(m)./BZc(m);
			BZ(~m)=NaN;
			I=BZ;
			
			clear BZ BZc
	
	endswitch
	
endfunction
