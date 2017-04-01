%Writes a matrix to a PPM image
function matrix2PPM(M, imgF, min_v, max_v)

 %This limit can be changed according to the PNM standard
 % not too portable though
 maxGray=255;

 %colormap
 mg4=floor((maxGray)/4);
 mg2=floor((maxGray)/2);
 cmR=[0, 0*[mg2:-1:1], 2*[1:maxGray-mg2] ];
 cmG=[0, 0*[1:mg4], 4*[1:mg4], 4*[maxGray-3*mg4:-1:1], 0*[1:mg4]];
 cmB=[0, 2*[mg2:-1:1], 0*[1:maxGray-mg2]];

 %fix bug in previous calculation
 cmR(cmR>maxGray)=maxGray;
 cmG(cmG>maxGray)=maxGray;
 cmB(cmB>maxGray)=maxGray;

 imgF=fopen(imgF, 'w');

 %PNM header: graymap
 fprintf(imgF, 'P6\n');
 fprintf(imgF, '#min_v=%g -> 1, max_v=%g -> %d, NaN set to 0\n', min_v, max_v, maxGray);
 fprintf(imgF, '%d %d\n', size(M,2), size(M,1));
 fprintf(imgF, '%d\n', maxGray);

 pnmArray=zeros(3,length(M(:)));
 if( maxGray<256 )
  pfmt='uint8';
 else
  pfmt='uint16';
 endif

 %crop and transpose to fit memory representation
 M( M(:)<min_v ) = min_v;
 M( M(:)>max_v ) = max_v;
 M=M';
 mnan=isnan(M(:));

 pnmArray(1, ~mnan )=cmR( floor(1+(maxGray-1)*(M(~mnan)-min_v)/(max_v-min_v)) );
 pnmArray(1, mnan )=0;
 pnmArray(2, ~mnan )=cmG( floor(1+(maxGray-1)*(M(~mnan)-min_v)/(max_v-min_v)) );
 pnmArray(2, mnan )=0;
 pnmArray(3, ~mnan )=cmB( floor(1+(maxGray-1)*(M(~mnan)-min_v)/(max_v-min_v)) );
 pnmArray(3, mnan )=0;

 fwrite(imgF, pnmArray(:), pfmt, 0, 'ieee-le');

 fclose(imgF);

endfunction
