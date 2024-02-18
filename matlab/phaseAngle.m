%phase angle from Waveform for different beam types
% currently only beamtype 1 with 4 signals
function [paAt,paAl]=phaseAngle(W, bt)
sW=size(W);
L=prod(sW(1:end-1));
paAt=reshape(zeros(L,1), [1,sW(1:end-1)]);
paAl=reshape(zeros(L,1), [1,sW(1:end-1)]);
switch( bt )
    case 1 %Transducers having four sectors: Starboard Aft, Port Aft, Port Fore, Starboard Fore
        paAl(:)=arg( conj(W(:,1)+1*W(:,2)).*(W(:,3)+1*W(:,4)) );
        paAt(:)=arg( conj(W(:,2)+1*W(:,3)).*(W(:,1)+1*W(:,4)) );
    case 17 %Transducers having three sectors: Starboard Aft, Port Aft, Forward
        paAl(:)=( arg( conj(W(:,1)).*W(:,3) ) +1* arg( conj(W(:,2)).*W(:,3) ) )/sqrt(3);
        paAt(:)=( arg( conj(W(:,2)).*W(:,3) ) - arg( conj(W(:,1)).*W(:,3) ) );
    case {49,65,81} %Transducers having three sectors and a centre element: Starboard Aft, Port Aft, Forward, Centre
        paAl(:)=( arg( conj(W(:,1)+1*W(:,4)).*(W(:,3)+1*W(:,4)) ) +1* arg( conj(W(:,2)+1*W(:,4)).*(W(:,3)+1*W(:,4)) ) )/sqrt(3);
        paAt(:)=( arg( conj(W(:,2)+1*W(:,4)).*(W(:,3)+1*W(:,4)) ) - arg( conj(W(:,1)+1*W(:,4)).*(W(:,3)+1*W(:,4)) ) );
    case 97 %Transducers having four sectors: Fore Starboard, Aft Port, Aft starboard, Fore Port
        paAt(:)=arg( conj(W(:,2)).*W(:,1) );
        paAl(:)=arg( conj(W(:,4)).*W(:,3) );
end
end