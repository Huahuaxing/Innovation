function c = c_of_P(P, b0, c0, nu, mu0)
% 计算应力P下的裂隙最大开度c
    beta = 2*(1-nu)*c0 / (3*mu0*b0);
    c = c0 * (1 - beta * P).^(-0.5);
end
