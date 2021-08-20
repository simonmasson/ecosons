%cs=velocityUNESCO(f,T,S,D,pH)
%Returns the speed of sound in sea water (m/s) according to UNESCO equation
%Ref: G.S.K. Wong and S Zhu, Speed of sound in seawater as a function of salinity, temperature and pressure (1995) J. Acoust. Soc. Am. 97(3) pp 1732-1736
% f: frequency in Hz (independent!)
% T: temperature in Celsius
% S: salinity in PSU
% D: depth (as a proxy to pressure in m)
% pH (independent!)
% cs: speed of sound in m/s
%Date: 2021/06/24; Status: Pre-Testing
function cs=velocityUNESCO(f,T,S,D,pH)
 %!f=f/1000; %f in kHz
 P=1.013 + 1e-5*(1023.6*9.80665*D); %pressure in bar
 %T in ºC
 %S in PSU ~= 35
 %pH ~= 8
 
  C00=1402.388;  C01=5.03830;  C02=-5.81090E-2;  C03=3.3432E-4;  C04=-1.47797E-6;  C05=3.1419E-9;
  C10=0.153563;  C11=6.8999E-4;  C12=-8.1829E-6;  C13=1.3632E-7;  C14=-6.1260E-10;
  C20=3.1260E-5;  C21=-1.7111E-6;  C22=2.5986E-8;  C23=-2.5353E-10;  C24=1.0415E-12;
  C30=-9.7729E-9;  C31=3.8513E-10;  C32=-2.3654E-12;
  A00=1.389;  A01=-1.262E-2;  A02=7.166E-5;  A03=2.008E-6;  A04=-3.21E-8;
  A10=9.4742E-5;  A11=-1.2583E-5;  A12=-6.4928E-8;  A13=1.0515E-8;  A14=-2.0142E-10;
  A20=-3.9064E-7;  A21=9.1061E-9;  A22=-1.6009E-10;  A23=7.994E-12;
  A30=1.100E-10;  A31=6.651E-12;  A32=-3.391E-13;
  B00=-1.922E-2;  B01=-4.42E-5;
  B10=7.3637E-5;  B11=1.7950E-7;
  D00=1.727E-3;  D10=-7.9836E-6;
 
 Cw=(C00 + C01*T + C02*power(T,2) + C03*power(T,3) + C04*power(T,4) + C05*power(T,5)) + ...
    (C10 + C11*T + C12*power(T,2) + C13*power(T,3) + C14*power(T,4)).*P + ...
    (C20 + C21*T + C22*power(T,2) + C23*power(T,3) + C24*power(T,4)).*power(P,2) + ...
    (C30 + C31*T + C32*power(T,2)).*P3;
 A =(A00 + A01*T + A02*power(T,2) + A03*power(T,3) + A04*power(T,4)) + ...
    (A10 + A11*T + A12*power(T,2) + A13*power(T,3) + A14*power(T,4)).*P + ...
    (A20 + A21*T + A22*power(T,2) + A23*power(T,3)).*power(P,2) + ...
    (A30 + A31*T + A32*power(T,2)).*power(P,3);
 B = B00 + B01*T + (B10 + B11*T).*P;
 D = D00 + D10*P;
 
 %sound speed
 cs=Cw+A.*S+B.*power(S,1.5)+D.*power(S,2);

endfunction

