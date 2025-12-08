function sigma = sigma_close_p(b0, c0, E, nu)
% 非椭圆裂隙闭合应力P
    alpha0 = b0 / c0;
    sigma = 3 * alpha0 * E / (4 * (1 - nu^2));
end
