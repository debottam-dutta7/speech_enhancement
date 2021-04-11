


function [S_hat,a_IS,zeta_p] = IS(X,zeta_hat,alpha)
% operate on columns
X = reshape(X,[],1);
zeta = double(zeros(size(X)));
a_IS = double(zeros(size(X)));
S_hat = double(zeros(size(X)));

%zeta(:,1) = (X(:,1).^2)./n_var(:,1);  % a-posteriori SNR
zeta = zeta_hat;
zeta_p = zeta/alpha;      % parametrized shrinkage

a_IS(:,1) = (1 + 60./(zeta_p(:).^3) + 840./(zeta_p(:).^4)).^(-1);
S_hat(:,1) = a_IS(:,1).*X(:,1);



end