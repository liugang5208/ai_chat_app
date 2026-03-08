from PIL import Image
import numpy as np
import os

def crop_icons():
    img_path = 'ui-images/knowledge.jpg'
    if not os.path.exists(img_path):
        print(f"Error: {img_path} not found")
        return

    img = Image.open(img_path).convert('RGB')
    arr = np.array(img)
    height, width, _ = arr.shape

    # Focus on the list area where icons are usually located (left side)
    # Based on main.jpg experience, icons are around x=50-150
    left_strip = arr[:, 40:180]
    
    # Threshold to find non-white regions
    is_not_white = np.any(left_strip < 240, axis=2)
    
    from scipy.ndimage import label
    labeled, num_features = label(is_not_white)
    
    os.makedirs('assets', exist_ok=True)
    
    found_icons = []
    for i in range(1, num_features + 1):
        rows, cols = np.where(labeled == i)
        y1, y2 = rows.min(), rows.max()
        x1, x2 = cols.min() + 40, cols.max() + 40
        w, h = x2 - x1, y2 - y1
        
        # Look for circular/square background icons (usually around 80-100px)
        if 60 < w < 120 and 60 < h < 120:
            found_icons.append((x1, y1, x2, y2))

    # Sort by Y to match the order: 文件夹, 标签, 文件预览
    found_icons = sorted(found_icons, key=lambda x: x[1])

    names = ['knowledge_folder_icon.png', 'knowledge_tag_icon.png', 'knowledge_preview_icon.png']
    
    for i, box in enumerate(found_icons[:3]):
        x1, y1, x2, y2 = box
        # Add a little padding for better centering
        pad = 5
        icon = img.crop((x1-pad, y1-pad, x2+pad, y2+pad))
        icon.save(f'assets/{names[i]}')
        print(f"Saved {names[i]} from box {box}")

if __name__ == "__main__":
    crop_icons()
