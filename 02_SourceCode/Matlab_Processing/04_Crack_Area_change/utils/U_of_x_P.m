function U = U_of_x_P(x, c, b0, c0)
% 应力P作用下的裂隙形态函数，输出x坐标上的裂隙开度U(x, P)
    U = zeros(size(x));
    mask = abs(x) <= c;
    if any(mask)
        z = 1.0 - (x(mask) ./ c).^2;
        z = max(z, 0.0);
        U(mask) = 2.0 * b0 * (c / c0)^3 * z.^(1.5);
    end
end
