function [Zn, Zt] = shelby_tensor_cch(C, a1, a2, a3, p)
% shelby_tensor_cch 计算Eshelby张量相关的Zn及Zt（用于有效介质理论）

C = C * (1e-9);  % 转化为 MPa
C_0 = C;

% C分量提取
C11 = C(1, 1);
C12 = C(1, 2);
C13 = C(1, 3);
C33 = C(3, 3);
C44 = C(4, 4);

% 计算裂缝的 Eshelby 张量
% 该程序基于 Xu Song 的论文 (Acta Phys. Sin. 2015)
H = zeros(6, 6);
opt = 1;
for i = 1:6
    for j = i:6
        if (opt == 1 || opt == 2 || opt == 3 || opt == 7 || ...
            opt == 8 || opt == 12 || opt == 16 || ...
            opt == 19 || opt == 21)  % 其他分量为零
            H(i, j) = integral2(@(ang1, ang2) P3(ang1, ang2, ...
                C11, C12, C13, C33, C44, a1, a2, a3, opt), 0, pi, 0, 2 * pi);
        end
        opt = opt + 1;
    end
end

% 对称化 H 矩阵
for i = 1:6
    for j = 1:(i - 1)
        H(i, j) = H(j, i);
    end
end

% 补充构造矩阵
C66 = (C11 - C12) / 2;
Cmat = [C11, C12, C13, 0, 0, 0;
        C12, C11, C13, 0, 0, 0;
        C13, C13, C33, 0, 0, 0;
        0,   0,   0,   2*C44, 0, 0;
        0,   0,   0,   0, 2*C44, 0;
        0,   0,   0,   0, 0, 2*C66];
S = 0.25 * (a1 * a2 * a3) / (4 * pi) * H * Cmat;

% Q矩阵构造
E2 = eye(6);
E2(4,4) = 2; E2(5,5) = 2; E2(6,6) = 2;
E1 = eye(6);
Q = C_0 * (E1 - E2 * S);  % C 扩展为 MPa

E = eye(size(Q));
H1 = p * (Q \ E);

% 计算 Zn 和 Zt
Zn = H1(3, 3);
Zt = H1(5, 5);
Zn = Zn * 1e-9;  % 转换为 Pa
Zt = Zt * 1e-9;  % 转换为 Pa

end
