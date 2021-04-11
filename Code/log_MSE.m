
function [S_hat,a_logmse,zeta_p] = log_MSE(X,zeta_hat,alpha)

X = reshape(X,[],1);
zeta = double(zeros(size(X)));
a_logmse = double(zeros(size(X)));
S_hat = double(zeros(size(X)));

%zeta(:,1) = (X(:,1).^2)./n_var(:,1);  % a-posteriori SNR
zeta = zeta_hat;
zeta_p = zeta/alpha;      % parametrized shrinkage

arg1 = exp(0.5 ./zeta_p(:)-0.75./(zeta_p(:).^2)-10./(zeta_p(:).^3)-210./(zeta_p(:).^4));

a_logmse(:,1) = min(arg1,1);
%a_logmse = max(a_logmse,0.05);
S_hat(:,1) = a_logmse(:,1).*X(:,1);



end