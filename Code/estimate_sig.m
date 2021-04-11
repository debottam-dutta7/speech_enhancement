
function cln_hat = estimate_sig(X_frames,audio_frames,distn_measure, win_len,shift,SNR,alpha)

%-------- Initialize --------------
num_frame = size(X_frames,2); beta = 0.98;
X_hat_frames = double(zeros(win_len,num_frame));

%--------------VAD Initialize----------------------
len = size(X_frames,1); 
%win = hamming(len); 
win = ones(len,1);
nFFT = len;
noise_mean = zeros(nFFT,1);

% noise variance for 1st frame
for m=1:10
    noise_mean=noise_mean+abs(dct(win.*audio_frames(:,m),nFFT)); 
end
noise_mu = noise_mean/10;
noise_mu2 = noise_mu.^2;

k = 1; aa = 0.98; mu = 0.98; eta = 0.15;
ksi_min = 10^(-25/10);
%------------------

% cln_pwr =(1/win_len)* sum(cln_dct_frames.^2);
% n_var = cln_pwr./(10^(SNR/10));

% VAD = voiceActivityDetector;
% [~,n_var] = VAD(audio_frames);
%n_var = dct(n_var);

for i = 1:num_frame
    
   frame = X_frames(:,i);
   
   
   %------------------ VAD ---------------------
   
    insign=win.*audio_frames(:,i);

    spec=dct(insign); %% changed from fft to dct
    sig=abs(spec); % compute the magnitude
    sig2=sig.^2;

    gammak=min(sig2./noise_mu2,40);  % limit post SNR to avoid overflows
    if i==1
        ksi=aa+(1-aa)*max(gammak-1,0);
    else
        ksi=aa*Xk_prev./noise_mu2 + (1-aa)*max(gammak-1,0);     % a priori SNR
        ksi=max(ksi_min,ksi);  % limit ksi to -25 dB
    end

    log_sigma_k= gammak.* ksi./ (1+ ksi)- log(1+ ksi);    
    vad_decision= sum(log_sigma_k)/ len;    
    if (vad_decision< eta) 
        % noise only frame found
        noise_mu2= mu* noise_mu2+ (1- mu)* sig2;
    end   
    A=ksi./(1+ksi);  % Log-MMSE estimator
    vk=A.*gammak;
    ei_vk=0.5*expint(vk);
    hw=A.*exp(ei_vk);

    sig=sig.*hw;
    Xk_prev=sig.^2;
    %Xk_prev=X_frames(:,i).^2;
 %-------------- End of VAD -----------

%    temp_arr = noise_mu2.^2./(frame.^2);
%    zeta_hat = 1./temp_arr;
   
   if i == 1
      temp_arr =  (noise_mu2./X_frames(:,i).^2); % beta = 1
      zeta_hat = 1./temp_arr;
       
   end
   
   if i >= 2
       
       temp_arr = beta.*(noise_mu2./X_frames(:,i).^2) + ...
         (1-beta)*max(1-X_hat_frames(:,i-1).^2./X_frames(:,i-1).^2 , 0);
       zeta_hat = 1./temp_arr;
   
   end   

   
   
   if strcmp(distn_measure, 'MSE')
       
      [frame_hat,a,zeta_prime] = MSE(frame,zeta_hat,alpha);
   
   
   elseif strcmp(distn_measure, 'WE')
       
      [frame_hat,a,zeta_prime] = WE(frame,zeta_hat,alpha);
   
   
   elseif strcmp(distn_measure,'log_MSE')
       
      [frame_hat,a,zeta_prime] = log_MSE(frame,zeta_hat,alpha);
   
   
   elseif strcmp(distn_measure,'IS')
       
      [frame_hat,a,zeta_prime] = IS(frame,zeta_hat,alpha);
   
   
   elseif strcmp(distn_measure, 'IS2')
       
      [frame_hat,a,zeta_prime] = IS2(frame,zeta_hat,alpha);
   
   
   elseif strcmp(distn_measure,'COSH')
       
      [frame_hat,a,zeta_prime] = COSH(frame,zeta_hat,alpha);
   
   
   elseif strcmp(distn_measure,'WCOSH')
       
      [frame_hat,a,zeta_prime] = WCOSH(frame,zeta_hat,alpha);
      
   
   end
   
   X_hat_frames(:,i) = frame_hat;
    
end

S_hat_frames = idct(X_hat_frames);
cln_hat = get_ola(S_hat_frames,shift);


end

