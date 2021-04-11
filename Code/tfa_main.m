
close all;

%---------- Global -----------
noise = 'street'; SNR_list = [0,5,10,15]; alpha = 0.1; %distn_measure = 'WE';
fs = 8e3; 
win_len = 40e-3*fs;
shift = 0.5*win_len;
%------------------------------
num_files = 30;
num_SNR = length(SNR_list);
stoi_score = zeros(num_files,9,num_SNR); % #columns for # estimators
segsnr_score = zeros(num_files,9,num_SNR); % #columns for # estimators

for k = 1:num_SNR
    SNR = SNR_list(k);
    SNR = 0;
    path = '..\Data\Noise\';
    path = [path noise '_' num2str(SNR) 'dB\' num2str(SNR) 'dB\'];
    
    file_list= dir([path '*.wav']);
    num_files = length(file_list);
    % stoi_val = zeros(num_files,1);
    % segsnr_val = zeros(num_files,1);
    
    % stoi_mse=zeros(num_files,1);stoi_log_mse=zeros(num_files,1);stoi_we=zeros(num_files,1);stoi_is=zeros(num_files,1);
    % stoi_is2=zeros(num_files,1);stoi_cosh=zeros(num_files,1);stoi_wcosh=zeros(num_files,1);
    % segsnr_mse=zeros(num_files,1);segsnr_log_mse=zeros(num_files,1);segsnr_we=zeros(num_files,1);segsnr_is=zeros(num_files,1);
    % segsnr_is2=zeros(num_files,1);segsnr_cosh=zeros(num_files,1);segsnr_wcosh=zeros(num_files,1);
    

    
    
    
    %----------------------------------
    
    cln_list = dir('C:\Users\dudebo_07\Documents\MATLAB\TFA Project\Data\clean\*.wav');
    cln_path = 'C:\Users\dudebo_07\Documents\MATLAB\TFA Project\Data\clean\';
    
    % for i = 1:1 % E
    %     cln_name = cln_list(i).name;
    %     [audio_s,fs] = audioread([cln_path cln_name]);
    %     s_frames = get_frames(audio_s,win_len,shift);
    %
    %     S_dct = dct(s_frames);
    %
    % end
    
    %% ----------- DCT frames ---------------
    
    for f_idx = 1:num_files
        
        % Load noisy audio and get DCT frames along columns
        filename = file_list(f_idx).name;
        [audio] = audioread([path filename]);
        audio_frames = get_frames(audio,win_len,shift);
        X_frames = dct(audio_frames);  % frames along columns
        
        % Load clean file and get DCT frames along columns
        cln_name = cln_list(f_idx).name;
        [audio_s,fs] = audioread([cln_path cln_name]);
        s_frames = get_frames(audio_s,win_len,shift);
        
        cln_dct_frames = dct(s_frames);
        
        
        % get re-estimated signals
        cln_hat_mse  = estimate_sig(X_frames,audio_frames,'MSE',win_len, shift,SNR,alpha);
        cln_hat_log_mse  = estimate_sig(X_frames,audio_frames,'log_MSE',win_len, shift,SNR,alpha);
        cln_hat_we  = estimate_sig(X_frames,audio_frames,'WE',win_len, shift,SNR,alpha);
        cln_hat_is  = estimate_sig(X_frames,audio_frames,'IS',win_len, shift,SNR,alpha);
        cln_hat_is2  = estimate_sig(X_frames,audio_frames,'IS2',win_len, shift,SNR,alpha);
        cln_hat_cosh  = estimate_sig(X_frames,audio_frames,'COSH',win_len, shift,SNR,alpha);
        cln_hat_wcosh  = estimate_sig(X_frames,audio_frames,'WCOSH',win_len, shift,SNR,alpha);
        
        
        % Benchmark methods
        %cln_hat_lsa = MMSESTSA85(audio,fs,0.25);
        cln_hat_lsa = logmmse(audio,fs);
        cln_hat_wfil = wiener_as(audio,fs);
        
        cln_hat_mse = cln_hat_mse(1:length(audio));
        cln_hat_log_mse = cln_hat_log_mse(1:length(audio));
        cln_hat_we = cln_hat_we(1:length(audio));
        cln_hat_is = cln_hat_is(1:length(audio));
        cln_hat_is2 = cln_hat_is2(1:length(audio));
        cln_hat_cosh = cln_hat_cosh(1:length(audio));
        cln_hat_wcosh = cln_hat_wcosh(1:length(audio));
        
        % Get STOI and SegSNR scores 
        stoi_score(f_idx,1,k) = stoi(audio_s,cln_hat_mse,fs);
        segsnr_score(f_idx,1,k) = segsnr_N(cln_hat_mse,audio,fs);
        
        stoi_score(f_idx,2,k) = stoi(audio_s,cln_hat_log_mse,fs);
        segsnr_score(f_idx,2,k) = segsnr_N(cln_hat_log_mse,audio,fs);
        
        stoi_score(f_idx,3,k) = stoi(audio_s,cln_hat_we,fs);
        segsnr_score(f_idx,3,k) = segsnr_N(cln_hat_we,audio,fs);
        
        stoi_score(f_idx,4,k) = stoi(audio_s,cln_hat_is,fs);
        segsnr_score(f_idx,4,k) = segsnr_N(cln_hat_is,audio,fs);
        stoi_score(f_idx,5,k) = stoi(audio_s,cln_hat_is2,fs);
        segsnr_score(f_idx,5,k) = segsnr_N(cln_hat_is2,audio,fs);
        
        stoi_score(f_idx,6,k) = stoi(audio_s,cln_hat_cosh,fs);
        segsnr_score(f_idx,6,k) = segsnr_N(cln_hat_cosh,audio,fs);
        
        stoi_score(f_idx,7,k) = stoi(audio_s,cln_hat_wcosh,fs);
        segsnr_score(f_idx,7,k) = segsnr_N(cln_hat_wcosh,audio,fs);
        
        stoi_score(f_idx,8,k) = stoi(audio_s(1:length(cln_hat_lsa)),cln_hat_lsa,fs);
        segsnr_score(f_idx,8,k) = segsnr_N(cln_hat_lsa,audio(1:length(cln_hat_lsa)),fs);
        
        stoi_score(f_idx,9,k) = stoi(audio_s(1:length(cln_hat_wfil)),cln_hat_wfil,fs);
        segsnr_score(f_idx,9,k) = segsnr_N(cln_hat_wfil,audio(1:length(cln_hat_wfil)),fs);
        
    end
    

end

% Take average of all 30 files
stoi_score_avg = mean(stoi_score,1);
segsnr_score_avg = mean(segsnr_score,1);
segsnr_score_avg = reshape(segsnr_score_avg,[num_SNR,9]);
stoi_score_avg = reshape(stoi_score_avg,[num_SNR,9]);
for i = 1:num_SNR
    SNR = SNR_list(i);
    fprintf(' SNR = %d \n',SNR);
    fprintf('------STOI---- \n');
    disp(stoi_score_avg(i,:));    
    fprintf('------SEGSNR---- \n');
    disp(segsnr_score_avg(i,:));
end

plot(0:5:15,segsnr_score_avg(:,1)); hold on;
plot(0:5:15,segsnr_score_avg(:,2)); hold on;
plot(0:5:15,segsnr_score_avg(:,3)); hold on;
plot(0:5:15,segsnr_score_avg(:,4)); hold on;
plot(0:5:15,segsnr_score_avg(:,5)); hold on;
plot(0:5:15,segsnr_score_avg(:,6)); hold on;
plot(0:5:15,segsnr_score_avg(:,7)); hold on;
plot(0:5:15,segsnr_score_avg(:,8)); hold on;
plot(0:5:15,segsnr_score_avg(:,9)); hold on;
legend('Location','best');
legend('IS2','COSH','WCOSH','LSA','WFIL'); %title('SSNR Gain');
ylim([ 0 8]); xlabel('SNR'); ylabel('SSNR Gain');

hold off;

