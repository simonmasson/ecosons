fname = '../L0002-D20140719-T091658-EA400.raw';
[P,HS,PS,At,Al,W,filt] = fmt_simradRAW(fname);

ping = 20;
s = P{1}(ping,:);

sampleInterval = HS{1}(ping).sampleInterval *10^-3;% in milliseconds from the manual
count = HS{1}(ping).count;

t = linspace(0,count*sampleInterval, count);

figure();
plot(t, s);

s2 = s(66:110);
s3 = s(151:190);

S2 = fft(s2);
f2 = linspace(0,1/sampleInterval,length(s2));
figure();
plot(f2,S2);

S3 = fft(s3);
f3 = linspace(0,1/sampleInterval,length(s3));
figure();
plot(f3,S3);
