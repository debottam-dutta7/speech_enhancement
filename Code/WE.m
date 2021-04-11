

function [S_hat,a_WE,zeta_p] = WE(X,zeta_hat,alpha)
% operate on columns
X = reshape(X,[],1);
zeta = double(zeros(size(X)));
a_WE = double(zeros(size(X)));
S_hat = double(zeros(size(X)));

%zeta(:,1) = (X(:,1).^2)./n_var(:,1);  % a-posteriori SNR
zeta = zeta_hat;
zeta_p = zeta/alpha;      % parametrized shrinkage

a_WE(:,1) = (1+1./zeta_p(:) - 1./(zeta_p(:).^2) + 48./(zeta_p(:).^3) + 360./(zeta_p(:).^4)).^(-1);
%a_WE = min(a_WE,0.05);
S_hat(:,1) = a_WE(:,1).*X(:,1);



end