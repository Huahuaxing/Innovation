function sigma = sigma_close_e(b0, c0, E, nu)
% 椭圆裂隙闭合应力P
    alpha0 = b0 / c0;
    sigma = alpha0 * E / (2 * (1 - nu^2));
end
