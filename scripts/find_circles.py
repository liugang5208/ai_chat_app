from PIL import Image
import numpy as np

img = Image.open('ui-images/knowledge.jpg').convert('RGB')
arr = np.array(img)

# Let's look at the areas around the previously identified centers
centers_y = [409, 584, 759]
cx = 128

for i, cy in enumerate(centers_y):
    # Take a 120x120 area
    box = arr[cy-60:cy+60, cx-60:cx+60]
    # Find the average color to see if there's a background
    avg_color = np.mean(box, axis=(0, 1))
    print(f"Icon {i+1} at {cy}: avg color {avg_color}")
    
    # Let's find the mask of pixels that are NOT white (threshold 250)
    mask = np.any(box < 250, axis=2)
    # Find the bounding box of this mask
    rows = np.any(mask, axis=1)
    cols = np.any(mask, axis=0)
    if np.any(rows) and np.any(cols):
        y1, y2 = np.where(rows)[0][0], np.where(rows)[0][-1]
        x1, x2 = np.where(cols)[0][0], np.where(cols)[0][-1]
        print(f"  Detected mask box: {x1, y1} to {x2, y2}, size {x2-x1}x{y2-y1}")
    else:
        print("  No non-white pixels found in 120x120 box")

