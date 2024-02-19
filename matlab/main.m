close all
clear
clc

%%
fname = 'file2.raw';%../L0002-D20140719-T091658-EA400.raw';
[P,HS,PS,At,Al,W,filt] = fmt_simradRAW(fname);

ping = 20;
s = P{1}(ping,:);

info = HS{1}(ping);
sampleInterval = info.sampleInterval *10^-3;% in milliseconds from the manual
count = info.count;

t = linspace(0,count*sampleInterval, count);

figure();
plot(t, s);

id0 = 66;
[m,idm] = max(s(id0:end));

hold on;
xline(t(id0+idm-1));

t1 = t(id0+idm-1);
c = info.soundVelocity;
c*t1

f = linspace(1/sampleInterval,count);

% s2 = s(66:110);
% s3 = s(151:190);
% 
% S2 = fft(s2);
% f2 = linspace(0,1/sampleInterval,length(s2));
% figure();
% plot(f2,S2);
% 
% S3 = fft(s3);
% f3 = linspace(0,1/sampleInterval,length(s3));
% figure();
% plot(f3,S3);
