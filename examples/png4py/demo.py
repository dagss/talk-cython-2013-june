from __future__ import division

import png4py

import numpy as np

H = 100
W = 200

y, x = np.mgrid[0:H,0:W]

# Generate picture
img = np.sin(3 * x * 2 * np.pi / W) + np.cos(y * 2 * np.pi / H)

# Rescale to range [0, 255] and convert to uint8
img -= img.min()
img *= 255 / np.max(img)
img = img.astype(np.uint8)

png4py.write_grayscale_image_to_png("test.png", img)


if 0:
    from matplotlib import pyplot as plt
    plt.clf()
    plt.imshow(img, interpolation='none')
    plt.colorbar()
    plt.show()
