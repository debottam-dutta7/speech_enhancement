
function recon_sig = get_ola(frames,shift)

[win_len,n_frame] = size(frames);
sig_len = (n_frame-1)*shift + win_len;
recon_sig = zeros(sig_len,1);
%ift_frames = real(ifft(stft));
%ift_frames = ift_frames./hamming(win_len);
for i = 1:n_frame
   
    inl = (i-1)*shift + 1;
    fin = (i-1)*shift + win_len;
    recon_sig(inl:fin) = recon_sig(inl:fin) + frames(:,i);
    
end

end