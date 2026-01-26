function V_dry = Func_Velocity(C_eff, c_1, sita, density, B, aperture_record, radius_record, dimention, n)
% 根据等效弹性矩阵计算波速
C_intermediate = squeeze(mean(C_eff, 2));
V_dry = zeros(200,3,31,6);      % 200个单轴应力状态，3种波速（vp，vsh，vsv），31个波速传播角度（0度表示竖直向下，索引16表示90度），6组模型

for groupNum=1:6
    C_stress = squeeze(C_intermediate(:,:,:,groupNum));
    for stressNum=1:200
        for subNum = 1:5
            for crackNum = 1:20
                a1 = 1;                                             % 固定值
                a2 = radius_record(subNum, crackNum, stressNum, groupNum);
                a3 = aperture_record(subNum, crackNum, stressNum, groupNum) / 2;
                crackAspectRatio = a3 / a2;                             % 裂隙纵横比
                S_mian = 20 * 20 * 1e-4;                                % 单元面积或体积，单位m^2
                
                if dimention == 2
                    c_density = n *(a2^2) / S_mian;                     % 裂隙密度
                    p = n * pi * a2 * a3 / S_mian;                      % 裂隙孔隙率
                else % dimention==3
                    c_density = n *(a2^3) / S_mian;
                    p = 4 * pi * c_density * crackAspectRatio / 3.0;
                end
                C = squeeze(C_stress(stressNum, :, :));
                V_dry(stressNum, :, :, groupNum) = modulus_dry_stress(c_1, sita, C, a1, a2, a3, p, density, B, c_density);
            end
        end
    end
end
end