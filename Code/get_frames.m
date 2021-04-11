
function frames = get_frames(x,win_len,shift)

x = reshape(x,[],1);
%N = length(x);
num_win = length(1:shift:length(x));
frames = zeros(win_len,num_win);
k = 1;
for i = 1:shift:length(x)
if i+win_len-1 <= length(x)
    clip = x(i:i+win_len-1);

else
    clip = x(i:end);
    
end

%w_clip = clip.*hamming(length(clip));
w_clip = clip.*ones(length(clip),1);    %%% Change to hamming
w_clip = [w_clip;zeros(win_len-length(w_clip),1)];
frames(:,k) = w_clip;
k = k+1;
end
end