from PIL import Image
import numpy as np

img = Image.open('ui-images/knowledge.jpg').convert('RGB')
arr = np.array(img)
h, w, _ = arr.shape
print(f"Image size: {w}x{h}")

# The list items are on the left. Let's look at a vertical strip x=[80, 180]
strip = arr[:, 80:180]
# Find where it's NOT white
is_not_white = np.any(strip < 240, axis=2)

# Find vertical segments
segments = []
start = -1
for y in range(h):
    if np.any(is_not_white[y]):
        if start == -1:
            start = y
    else:
        if start != -1:
            if y - start > 40: # Ignore small things
                segments.append((start, y))
            start = -1
if start != -1:
    segments.append((start, h))

print("Vertical segments found in strip:")
for s in segments:
    y_mid = (s[0] + s[1]) // 2
    # Sample the color at the middle
    color = arr[y_mid, 130] # center of strip
    print(f"Segment {s}, center y={y_mid}, color={color}")

