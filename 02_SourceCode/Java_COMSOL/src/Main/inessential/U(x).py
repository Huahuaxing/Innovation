import numpy as np
import matplotlib.pyplot as plt

def U(x, b0, c0):
    return 2 * b0 * (1 - (x / c0) ** 2) ** (3 / 2)

b0 = 0.0001
c0 = 0.018

x = np.linspace(-c0, c0, 21)

plt.xlim(-c0, c0)
plt.plot(x, U(x, b0, c0))
plt.show()