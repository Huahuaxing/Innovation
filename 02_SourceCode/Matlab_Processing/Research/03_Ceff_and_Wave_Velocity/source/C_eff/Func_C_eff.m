function C_eff = Func_C_eff(C, n, radius_record, aperture_record, dimention, density, sita)
% calc_C_eff 计算有效弹性矩阵
%   C                   : 6x6基质弹性常数矩阵
%   n                   : 裂隙个数
%   radius_record       : (5，20，200，6) 半长轴数组
%   aperture_record     : (5，20，200，6) 短轴数组
%   dimention           : 2为2D，3为3D有效介质理论
%   density             : 基质密度
%   sita                : 波速角度数组
%   返回值               : 单轴应力下等效刚度矩阵C_eff (Stress, subModel, 6, 6, groupModel)

C_eff = zeros(200, 5, 6, 6, 6); % 按实际需求和输入决定size

for groupNum = 1:6
    for stressNum = 1:200
        for subNum = 1:5
            Z_intermediate = zeros(6,6);                                % 中间计算矩阵
            for crackNum = 1:20
                a1 = 1;                                             % 固定值
                a2 = radius_record(subNum, crackNum, stressNum, groupNum);
                a3 = aperture_record(subNum, crackNum, stressNum, groupNum) / 2;
                crackAspectRatio = a3 / a2;                             % 裂隙纵横比
                angle = 0;                                              % 裂隙角度
                S_mian = 20 * 20 * 1e-4;                                % 单元面积或体积，单位m^2
                
                if dimention == 2
                    c_density = n *(a2^2) / S_mian;                     % 裂隙密度
                    p = n * pi * a2 * a3 / S_mian;                      % 裂隙孔隙率
                else % dimention==3
                    c_density = n *(a2^3) / S_mian;
                    p = 4 * pi * c_density * crackAspectRatio / 3.0;
                end
                
                c_1 = sqrt(C(1,1) * C(3,3));
                B = zeros(1,5);
                B(3) = sqrt(C(6,6) / C(4,4));
                B(4) = sqrt((c_1-C(1,3))*(c_1+C(1,3)+2*C(4,4)) / (C(3,3)*C(4,4)));
                B(5) = sqrt((c_1+C(1,3))*(c_1-C(1,3)-2*C(4,4)) / (C(3,3)*C(4,4)));
                B(1) = 0.5 * (B(4) + B(5));
                B(2) = 0.5 * (B(4) - B(5));
                
                % 裂隙贡献Z矩阵（需要用户具备modulus_dry_inclined函数）
                Z = modulus_dry_inclined(c_density, B, c_1, C, a1, a2, a3, p, angle, density, sita);
                Z_intermediate = Z_intermediate + Z;
            end
            S = inv(C) + Z_intermediate;
            C_eff(stressNum, subNum, :, :, groupNum) = inv(S);
        end
    end
end
end
