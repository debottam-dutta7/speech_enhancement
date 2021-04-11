function ssnr = segsnr_N( target, masked, fs )
% SEGSNR Computes segmental signal-to-noise ratio.
%
%   SEGSNR(TARGET,MASKED,FS) returns segmental signal-to-noise 
%   ratio (SegSNR) given target and masked speech signals along
%   with the sampling frequency.
%   
%   Inputs
%           TARGET is a target signal as vector.
%
%           MASKED is a target+masker signal as vector.
%
%           FS is the sampling frequency for the input vectors (Hz).
%
%   Outputs 
%           SSNR is the segmental SNR (dB).
%
%   Example
%           % read target and masker signals from wav files
%           [ target, fs ] = wavread( 'sp10.wav' );
%           [ masker, fs ] = wavread( 'ssn.wav' );
%
%           % desired SNR level (dB)
%           snr = 5; 
%
%           % generate mixture signal: noisy = signal + noise
%           [ masked, masker ] = addnoise( target, masker, snr ); 
%
%           % compute segmental SNR (dB)
%           ssnr = segsnr( target, masked, fs );
%
%           % display the result 
%           fprintf( 'SegSNR: %0.2f dB\n', ssnr );
%
%   See also ADDNOISE, SNR.
%   Author: Kamil Wojcicki, October 2011
    % ensure masker is the same length as the target
    if( length(target)~=length(masked) ), error( 'Error: length(target)~=length(masked)' ); end;
    masker = masked(:) - target(:); % compute the masker (assumes additive noise model)
    Tw = 32;                        % analysis frame duration (ms)
    Ts = Tw/4;                      % analysis frame shift (ms)
    Nw = round( Tw*1E-3*fs );       % analysis frame duration (samples)
    Ns = round( Ts*1E-3*fs );       % analysis frame shift (samples)
    ssnr_min = -10;                 % segment SNR floor (dB)
    ssnr_max =  35;                 % segment SNR ceil (dB)
    % divide target and masker signals into overlapped frames
    frames_target = vec2frames( target, Nw, Ns);
    frames_masker = vec2frames( masker, Nw, Ns);
    % compute target and masker frame energies
    energy_target = sum( frames_target.^2, 1 );
    energy_masker = sum( frames_masker.^2, 1 ) + eps;
    % compute frame signal-to-noise ratios (dB)
    ssnr = 10*log10( energy_target ./ energy_masker + eps );
    % apply limiting to segment SNRs
    ssnr = min( ssnr, ssnr_max );
    ssnr = max( ssnr, ssnr_min );
    % compute mean segmental SNR
    ssnr = mean( ssnr );
    end
% EOF


%% ----------my edit
function frames = vec2frames(vec,Nw,Ns)

x = reshape(vec,[],1);
%N = length(x);
win_len = Nw; shift = Ns;
num_win = length(1:shift:length(x));
frames = zeros(win_len,num_win);
k = 1;
for i = 1:shift:length(x)
    if i+win_len-1 <= length(x)
        clip = x(i:i+win_len-1);
        
    else
        clip = x(i:end);
        
    end
    
    w_clip = clip.*hanning(length(clip));
    %w_clip = clip.*ones(length(clip),1);    %%% Change to hamming
    w_clip = [w_clip;zeros(win_len-length(w_clip),1)];
    frames(:,k) = w_clip;
    k = k+1;
end
end




