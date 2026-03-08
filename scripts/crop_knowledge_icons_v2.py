from PIL import Image
import numpy as np
import os

img = Image.open('ui-images/knowledge.jpg').convert('RGB')
arr = np.array(img)
height, width, _ = arr.shape

# The list starts after search bar, search bar is roughly at y=150 to 250
# Let's check the strip for the three buttons
# We know the approximate centers based on common UI patterns
# Let's find the non-white regions again but in a specific area

strip = arr[250:800, 60:180]
is_not_white = np.any(strip < 240, axis=2)

from scipy.ndimage import label
labeled, num_features = label(is_not_white)

found = []
for i in range(1, num_features + 1):
    rows, cols = np.where(labeled == i)
    y1, y2 = rows.min() + 250, rows.max() + 250
    x1, x2 = cols.min() + 60, cols.max() + 60
    w, h = x2 - x1, y2 - y1
    if 50 < w < 120 and 50 < h < 120:
        found.append((x1, y1, x2, y2, w, h))

found = sorted(found, key=lambda f: f[1])
print(f"Found {len(found)} candidate boxes")

os.makedirs('assets', exist_ok=True)
names = ['knowledge_folder_icon.png', 'knowledge_tag_icon.png', 'knowledge_preview_icon.png']
for i, f in enumerate(found[:3]):
    x1, y1, x2, y2, w, h = f
    # Crop it square based on center
    cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
    r = 44 # radius
    crop = img.crop((cx-r, cy-r, cx+r, cy+r))
    crop.save(f'assets/{names[i]}')
    print(f"Saved {names[i]} (center {cx}, {cy})")

