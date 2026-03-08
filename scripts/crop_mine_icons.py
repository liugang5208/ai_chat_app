from PIL import Image
import numpy as np
import os

img = Image.open('ui-images/mine.jpg').convert('RGB')
arr = np.array(img)
h, w, _ = arr.shape

# 1. User avatar/icon area (large circle in the middle top)
# Let's search for non-white regions in the upper middle
upper_mid = arr[200:600, 200:600]
is_not_white = np.any(upper_mid < 250, axis=2)
from scipy.ndimage import label
labeled, num_features = label(is_not_white)
if num_features > 0:
    # Find the largest feature which should be the avatar
    sizes = [np.sum(labeled == i) for i in range(1, num_features + 1)]
    idx = np.argmax(sizes) + 1
    rows, cols = np.where(labeled == idx)
    y1, y2 = rows.min() + 200, rows.max() + 200
    x1, x2 = cols.min() + 200, cols.max() + 200
    cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
    r = 75 # Radius for avatar
    img.crop((cx-r, cy-r, cx+r, cy+r)).save('assets/mine_user_avatar.png')
    print(f"Saved mine_user_avatar.png at center ({cx}, {cy})")

# 2. Settings icon (top right)
top_right = arr[50:150, 650:800]
is_not_white_s = np.any(top_right < 200, axis=2)
labeled_s, num_s = label(is_not_white_s)
if num_s > 0:
    rows, cols = np.where(labeled_s == 1)
    y1, y2 = rows.min() + 50, rows.max() + 50
    x1, x2 = cols.min() + 650, cols.max() + 650
    cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
    r = 25
    img.crop((cx-r, cy-r, cx+r, cy+r)).save('assets/mine_settings_icon.png')
    print(f"Saved mine_settings_icon.png at center ({cx}, {cy})")

# 3. Favorite icon (in the list)
# List starts around y=700. Strip x=[50, 150]
list_strip = arr[700:1000, 50:150]
is_not_white_f = np.any(list_strip < 240, axis=2)
labeled_f, num_f = label(is_not_white_f)
if num_f > 0:
    rows, cols = np.where(labeled_f == 1)
    y1, y2 = rows.min() + 700, rows.max() + 700
    x1, x2 = cols.min() + 50, cols.max() + 50
    cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
    r = 30
    img.crop((cx-r, cy-r, cx+r, cy+r)).save('assets/mine_favorite_icon.png')
    print(f"Saved mine_favorite_icon.png at center ({cx}, {cy})")
