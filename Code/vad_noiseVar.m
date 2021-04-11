
function [noise_mu2] = vad_noiseVar(frame,Xk_prev,noise_mu_prev)

%x = get_ola(s_frames,shift);


Nframes = size(s_frames,2);
nFFT = size(s_frames,1);
len = nFFT;
win=hamming(len);  

noise_mean=zeros(nFFT,1);
j=1;
for m=1:6  %%%%----------- FIX THIS ------------
    noise_mean=noise_mean+abs(fft(win.*x(j:j+len-1),nFFT));
    %noise_mean=noise_mean+abs(fft(x(j:j+len-1),nFFT));
    j=j+len;
end
noise_mu=noise_mean/6;
noise_mu2=noise_mu.^2;


k=1;
aa=0.98;
mu=0.98;
eta=0.15; 

ksi_min=10^(-25/10);

for n=1:Nframes

    %insign=win.*x(k:k+len-1);
    %insign=x(k:k+len-1);
    insign = frame;

    spec=fft(insign,nFFT);
    sig=abs(spec); % compute the magnitude
    sig2=sig.^2;

    gammak=min(sig2./noise_mu2,40);  % limit post SNR to avoid overflows
    if n==1
        ksi=aa+(1-aa)*max(gammak-1,0);
    else
        ksi=aa*Xk_prev./noise_mu2 + (1-aa)*max(gammak-1,0);     % a priori SNR
        ksi=max(ksi_min,ksi);  % limit ksi to -25 dB
    end

    log_sigma_k= gammak.* ksi./ (1+ ksi)- log(1+ ksi);    
    vad_decision= sum(log_sigma_k)/ len;    
    if (vad_decision< eta) 
        % noise only frame found
        %noise_mu2= mu* noise_mu2+ (1- mu)* sig2;
        noise_mu2= mu* noise_mu_prev+ (1- mu)* sig2;
        
    else 
        noise_mu2 = noise_mu_prev;
    end
    
    Xk_prev=sig.^2;
    
    
end




end