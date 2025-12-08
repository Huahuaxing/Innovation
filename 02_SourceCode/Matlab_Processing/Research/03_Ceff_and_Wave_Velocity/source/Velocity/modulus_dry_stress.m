function [V_dry, C_eff] = modulus_dry_stress(c_1, sita, C, a1, a2, a3, p, density, B, c_density)
% 计算干燥状态下的模量和波速
% c_1: 弹性参数组合
% sita: 角度数组 (弧度)
% C: 某压力状态下的有效弹性矩阵 (6x6)
% density: 密度
% a1, a2, a3: 裂隙几何参数
% p: 裂隙孔隙度
% B: B参数数组
% c_density: 裂隙密度
% 返回 [V_dry, C_eff]

V_dry = zeros(3, numel(sita));

% 计算Z_N和Z_T
% [Z_N, Z_T] = shelby_tensor_cch(C, a1, a2, a3, p); % 可选高级调用
Z_N = 8 * B(4) * c_density / (3 * c_1 * (1 - (C(1, 3) / c_1)^2));
intermediate = B(3) + B(4) - 2 * C(4, 4) * B(4) / (c_1 + C(1, 3) + 2 * C(4, 4));
Z_T = 16 * c_density / (3 * C(4, 4) * intermediate);

% 计算delta_N和delta_T
delta_N = C(3, 3) * Z_N / (1 + C(3, 3) * Z_N);
delta_T = C(4, 4) * Z_T / (1 + C(4, 4) * Z_T);

% 初始化有效弹性矩阵 C_eff
C_eff = zeros(6, 6);

% 填充有效弹性矩阵
C_eff(1, 1) = C(1, 1) * (1 - ((C(1, 3) / c_1)^2) * delta_N);
C_eff(1, 2) = C(1, 2) * (1 - ((C(1, 3) / (C(1, 2) * C(3, 3)))^2) * delta_N);
C_eff(2, 1) = C_eff(1, 2);
C_eff(2, 2) = C_eff(1, 1);
C_eff(1, 3) = C(1, 3) * (1 - delta_N);
C_eff(3, 1) = C_eff(1, 3);
C_eff(2, 3) = C(1, 3) * (1 - delta_N);
C_eff(3, 2) = C_eff(2, 3);
C_eff(3, 3) = C(3, 3) * (1 - delta_N);
C_eff(4, 4) = C(4, 4) * (1 - delta_T);
C_eff(5, 5) = C(4, 4) * (1 - delta_T);
C_eff(6, 6) = C(6, 6);

% 计算每个角度的波速（循环sita的size）
for kk = 1:numel(sita)
    ssita = sin(sita(kk))^2;
    ccsita = cos(sita(kk))^2;
    
    M = (C_eff(2, 2) * ssita + C_eff(4, 4) * ccsita) * (C_eff(4, 4) * ssita + C_eff(3, 3) * ccsita) - ((C_eff(2, 3) + C_eff(4, 4))^2) * ssita * ccsita;
    inter_a = C_eff(4, 4) + C_eff(2, 2) * ssita + C_eff(3, 3) * ccsita;
    iner_b = sqrt(inter_a^2 - 4 * M);

    V_p = sqrt(inter_a + iner_b) * (1.0 / sqrt(2 * density));  % P波
    V_sv = sqrt(inter_a - iner_b) * (1.0 / sqrt(2 * density)); % SV
    V_sh = sqrt((C_eff(6, 6) * ssita + C_eff(5, 5) * ccsita) / density); % SH

    V_dry(1, kk) = V_p;
    V_dry(2, kk) = V_sv;
    V_dry(3, kk) = V_sh;
end
end
