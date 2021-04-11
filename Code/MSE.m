
function [S_hat,a_mse,zeta_p] = MSE(X,zeta_hat,alpha)

X = reshape(X,[],1);
zeta = double(zeros(size(X)));
a_mse = double(zeros(size(X)));
S_hat = double(zeros(size(X)));

%zeta(:,1) = (X(:,1).^2)./n_var(:,1);  % a-posteriori SNR
zeta = zeta_hat;
zeta_p = zeta/alpha;      % parametrized shrinkage

a_mse(:,1) = max(1-1./zeta_p(:,1),0);
S_hat(:,1) = a_mse(:,1).*X(:,1);



end