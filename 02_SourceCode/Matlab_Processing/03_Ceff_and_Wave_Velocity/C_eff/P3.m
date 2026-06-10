function T = P3(ang1, ang2, C11, C12, C13, C33, C44, a1, a2, a3, opt)
    % This function is used to calculate the integrand for the function
    % Eshelby_tensor_TI_different_radius
    % opt: the integrand

    C66 = (C11 - C12) / 2;
    n1 = sin(ang1) .* cos(ang2);
    n2 = sin(ang1) .* sin(ang2);
    n3 = cos(ang1);
    n = sqrt(n1.^2 + n2.^2);

    B11 = (C66 * n1.^2 + C11 * n2.^2 + C44 * n3.^2) .* (C44 * n.^2 + C33 * n3.^2) - (C13 + C44)^2 * (n2.^2) .* n3.^2;
    B22 = (C11 * n1.^2 + C66 * n2.^2 + C44 * n3.^2) .* (C44 * n.^2 + C33 * n3.^2) - (C13 + C44)^2 * (n1.^2) .* n3.^2;
    B33 = (C11 * n1.^2 + C66 * n2.^2 + C44 * n3.^2) .* (C66 * n1.^2 + C11 * n2.^2 + C44 * n3.^2) - (C11 - C66)^2 * (n1.^2) .* n2.^2;
    B12 = (C13 + C44)^2 * (n1 .* n2) .* n3.^2 - (C11 - C66) * (n1 .* n2) .* (C44 * n.^2 + C33 * n3.^2);
    B13 = (C11 - C66) * (C13 + C44) * (n1 .* n2.^2) .* n3 - (C13 + C44) * (n1 .* n3) .* (C66 * n1.^2 + C11 * n2.^2 + C44 * n3.^2);
    B23 = (C13 + C44) * (n2 .* n3) .* ((C11 - C66) * n1.^2 - (C11 * n1.^2 + C66 * n2.^2 + C44 * n3.^2));
    D = (C66 * n.^2 + C44 * n3.^2) .* ((C44 * n.^2 + C33 * n3.^2) .* (C11 * n.^2 + C44 * n3.^2) - (C13 + C44)^2 * (n.^2) .* n3.^2);
    L = ((a1 * n1).^2 + (a2 * n2).^2 + (a3 * n3).^2).^(-3/2);

    if (opt == 1) % H11
        H = 4 * B11 .* n1.^2;
    elseif (opt == 2) % H12
        H = 4 * (n1 .* n2) .* B12;
    elseif (opt == 3) % H13
        H = 4 * (n1 .* n3) .* B13;
    elseif (opt == 4) % H14
        H = 2 * (n1 .* n3) .* B12 + 2 * (n1 .* n2) .* B13;
    elseif (opt == 5) % H15
        H = 2 * (n1 .* n3) .* B11 + 2 * (n1.^2) .* B13;
    elseif (opt == 6) % H16
        H = 2 * (n1 .* n2) .* B11 + 2 * (n1.^2) .* B12;
    elseif (opt == 7) % H22
        H = 4 * B22 .* n2.^2;
    elseif (opt == 8) % H23
        H = 4 * (n2 .* n3) .* B23;
    elseif (opt == 9) % H24
        H = 2 * (n2 .* n3) .* B22 + 2 * (n2.^2) .* B23;
    elseif (opt == 10) % H25
        H = 2 * (n2 .* n3) .* B12 + 2 * (n1 .* n2) .* B23;
    elseif (opt == 11) % H26
        H = 2 * (n2.^2) .* B12 + 2 * (n1 .* n2) .* B22;
    elseif (opt == 12) % H33
        H = 4 * B33 .* n3.^2;
    elseif (opt == 13) % H34
        H = 2 * (n3.^2) .* B23 + 2 * (n2 .* n3) .* B33;
    elseif (opt == 14) % H35
        H = 2 * (n3.^2) .* B13 + 2 * (n1 .* n3) .* B33;
    elseif (opt == 15) % H36
        H = 2 * (n2 .* n3) .* B13 + 2 * (n1 .* n3) .* B23;
    elseif (opt == 16) % H44
        H = (n3.^2) .* B22 + 2 * (n2 .* n3) .* B23 + (n2.^2) .* B33;
    elseif (opt == 17) % H45
        H = (n3.^2) .* B12 + (n1 .* n3) .* B23 + (n2 .* n3) .* B13 + (n1 .* n2) .* B33;
    elseif (opt == 18) % H46
        H = (n2 .* n3) .* B12 + (n1 .* n3) .* B22 + (n2.^2) .* B13 + (n1 .* n2) .* B23;
    elseif (opt == 19) % H55
        H = (n3.^2) .* B11 + 2 * (n1 .* n3) .* B13 + (n1.^2) .* B33;
    elseif (opt == 20) % H56
        H = (n2 .* n3) .* B11 + (n1 .* n3) .* B12 + (n1 .* n2) .* B13 + (n1.^2) .* B23;
    elseif (opt == 21) % H66
        H = (n2.^2) .* B11 + 2 * (n1 .* n2) .* B12 + (n1.^2) .* B22;
    end

    T = ((H .* L) ./ D) .* sin(ang1);
end




