import numpy as np
import matplotlib.pyplot as plt
import acoustoelastic_matrix as am

P = am.P
vp = am.vp90

np.savetxt('.\\05_ProcessedData\\P\\P.csv', P, delimiter=',')


# # 绘制stress-velocity曲线
# def draw_stress_velocity(P, vp):
#     vp_ellipse = np.loadtxt('.\\05_ProcessedData\\velocity\\90_degree\\vp_ellipse.csv', delimiter=',')
#     # vp_polygonal = np.loadtxt('.\\05_ProcessedData\\velocity\\90_degree\\vp_polygonal.csv', delimiter=',')

#     fig, axes = plt.subplots(2, 3, figsize=(12, 8))
#     for i in range(2):
#         for j in range(3):
#             index = i * 3 + j
#             axes[i, j].plot(P, vp, label='ellipse', color='r')
#             # axes[i, j].plot(P, vp_polygonal[:, index], label='polygonal', color='b')
#             axes[i, j].set_title(f'{index}')
#             axes[i, j].legend()
    
#     plt.tight_layout()
#     plt.show()
    

# draw_stress_velocity(P, vp)





