
function [S_hat,a_WCOSH,zeta_p] = WCOSH(X,zeta_hat,alpha)

X = reshape(X,[],1);
zeta = double(zeros(size(X)));
a_WCOSH = double(zeros(size(X)));
S_hat = double(zeros(size(X)));

%zeta(:,1) = (X(:,1).^2)./n_var(:,1);  % a-posteriori SNR
zeta = zeta_hat;
zeta_p = zeta/alpha;      % parametrized shrinkage

arg1 = (1 - 1 ./zeta_p(:)+3./(zeta_p(:).^2)+420./(zeta_p(:).^3)+8400./(zeta_p(:).^4)).^(-1/2);

a_WCOSH(:,1) = min(arg1,1);
S_hat(:,1) = a_WCOSH(:,1).*X(:,1);

end