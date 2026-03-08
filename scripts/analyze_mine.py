from PIL import Image
import numpy as np

img = Image.open('ui-images/mine.jpg').convert('RGB')
arr = np.array(img)
h, w, _ = arr.shape
print(f"Image size: {w}x{h}")

# 1. Top right settings icon
# Search in top-right corner
tr_area = arr[50:200, w-150:w-20]
is_not_white_tr = np.any(tr_area < 240, axis=2)
if np.any(is_not_white_tr):
    rows, cols = np.where(is_not_white_tr)
    y1, y2 = rows.min() + 50, rows.max() + 50
    x1, x2 = cols.min() + (w-150), cols.max() + (w-150)
    print(f"Settings icon area: x={x1}-{x2}, y={y1}-{y2}, center={(x1+x2)/2, (y1+y2)/2}")

# 2. Avatar
# Search in top middle
tm_area = arr[200:600, w//2-150:w//2+150]
is_not_white_tm = np.any(tm_area < 250, axis=2)
if np.any(is_not_white_tm):
    rows, cols = np.where(is_not_white_tm)
    y1, y2 = rows.min() + 200, rows.max() + 200
    x1, x2 = cols.min() + (w//2-150), cols.max() + (w//2-150)
    print(f"Avatar area: x={x1}-{x2}, y={y1}-{y2}, center={(x1+x2)/2, (y1+y2)/2}")

# 3. Favorite icon
# Search in left strip
ls_area = arr[600:1000, 50:200]
is_not_white_ls = np.any(ls_area < 240, axis=2)
if np.any(is_not_white_ls):
    from scipy.ndimage import label
    labeled, num = label(is_not_white_ls)
    for i in range(1, num + 1):
        rows, cols = np.where(labeled == i)
        y1, y2 = rows.min() + 600, rows.max() + 600
        x1, x2 = cols.min() + 50, cols.max() + 50
        if (y2-y1) > 40:
            print(f"Favorite icon area {i}: x={x1}-{x2}, y={y1}-{y2}, center={(x1+x2)/2, (y1+y2)/2}")
