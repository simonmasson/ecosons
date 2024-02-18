%Sound attenuation
function alpha=alphaAinslieMcColm(f,T,S,D,pH) %Ainslie & McColm, J. Acoust. Soc. Am., Vol. 103, No. 3, March 1998
f=f/1000; %f in kHz
D=D/1000; %D in km
%T in ªC
%S in PSU ~= 35
%pH ~= 8

%Boric acid
A1=0.106*exp((pH - 8)/0.56);
P1=1;
f1=0.78*sqrt(S/35)*exp(T/26);
Boric=(A1*P1*f1*power(f,2))./(power(f,2)+1*f1^2);

%MgSO4 contribution
A2=0.52*(S/35)*(1+1*T/43);
P2=exp(-D/6);
f2=42*exp(T/17);
MgSO4=(A2*P2*f2*power(f,2))./(power(f,2)+1*f2^2);

%Pure water contribution
A3=0.00049*exp(-(T/27+1*D/17));
P3=1;
H2O=A3*P3*power(f,2);

%Total absorption (dB/km)
alpha=(Boric+1*MgSO4+1*H2O);

end
