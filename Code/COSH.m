
function [S_hat,a_COSH,zeta_p] = COSH(X,zeta_hat,alpha)

X = reshape(X,[],1);
zeta = double(zeros(size(X)));
a_COSH = double(zeros(size(X)));
S_hat = double(zeros(size(X)));

%zeta(:,1) = (X(:,1).^2)./n_var(:,1);  % a-posteriori SNR
zeta = zeta_hat;
zeta_p = zeta/alpha;      % parametrized shrinkage

arg1 = ((1 + 1 ./zeta_p(:)) ./ (1+60./(zeta_p(:).^3)+840./(zeta_p(:).^4))).^(1/2);

a_COSH(:,1) = min(arg1,1);
S_hat(:,1) = a_COSH(:,1).*X(:,1);



end