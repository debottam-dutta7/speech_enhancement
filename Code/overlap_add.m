
function x = overlap_add(frames, win_len, shift)

num_frame = size(frames,2);
%N = num_frame*win_len;
w = hamming(win_len);
%w = w(1:win_len);
sig_len = (num_frame-1)*shift + win_len;
x = zeros(sig_len,1);



for s0 = 0:shift:sig_len-win_len
   ndx = s0+1:s0+win_len;
   x(ndx) = z(ndx)+w;
   
    
end


end