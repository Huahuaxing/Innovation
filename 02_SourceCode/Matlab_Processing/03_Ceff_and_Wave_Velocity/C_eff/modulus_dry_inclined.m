function [Z, V_dry_oblique] = modulus_dry_inclined(c_density, B, c_1, C, a1, a2, a3, p, angle, density, sita)
    V_dry_oblique = zeros(3, numel(sita));
    % [Z_N, Z_T] = shelby_tensor_cch(C, a1, a2, a3, p);

    Z = zeros(6, 6);
    Z_N = 8 * B(4) * c_density / (3 * c_1 * (1 - (C(1, 3) / c_1)^2));
    intermediate = B(3) + B(4) - 2 * C(4, 4) * B(4) / (c_1 + C(1, 3) + 2 * C(4, 4));
    Z_T = 16 * c_density / (3 * C(4, 4) * intermediate);

    % delta_N = C(3, 3) * Z_N / (1 + C(3, 3) * Z_N);
    % delta_T = C(4, 4) * Z_T / (1 + C(4, 4) * Z_T);

    %% 这部分是为了获得干燥情况下倾斜裂隙下有效模量
    ssita = sin(angle) ^ 2;
    scsita = sin(angle) * cos(angle);
    ccsita = cos(angle) ^ 2;

    Z(2, 2) = Z_T * ssita;
    Z(3, 3) = Z_N * ccsita;
    Z(4, 4) = Z_N * ssita + Z_T * ccsita;
    Z(5, 5) = Z_T * ccsita;
    Z(6, 6) = Z_T * ssita;
    Z(5, 6) = -Z_T * scsita;
    Z(6, 5) = Z(5, 6);
    Z(2, 4) = Z(5, 6);
    Z(4, 2) = Z(2, 4);
    Z(3, 4) = -Z_N * scsita;
    Z(4, 3) = Z(3, 4);

    S = inv(C) + Z;
    C_eff = inv(S);

    for kk = 1:numel(sita)
        ssita = sin(sita(kk)) ^ 2;
        ccsita = cos(sita(kk)) ^ 2;

        M = (C_eff(2, 2) * ssita + C_eff(4, 4) * ccsita) * (C_eff(4, 4) * ssita + C_eff(3, 3) * ccsita) - ((C_eff(2, 3) + C_eff(4, 4)) ^ 2) * ssita * ccsita;
        inter_a = C_eff(4, 4) + C_eff(2, 2) * ssita + C_eff(3, 3) * ccsita;
        iner_b = sqrt(inter_a ^ 2 - 4 * M);

        V_p = sqrt(inter_a + iner_b) * (1.0 / sqrt(2 * density));
        V_sv = sqrt(inter_a - iner_b) * (1.0 / sqrt(2 * density));
        V_sh = sqrt((C_eff(6, 6) * ssita + C_eff(5, 5) * ccsita) / density);

        V_dry_oblique(1, kk) = V_p;
        V_dry_oblique(2, kk) = V_sv;
        V_dry_oblique(3, kk) = V_sh;
    end
end


