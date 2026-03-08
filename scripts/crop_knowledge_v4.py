from PIL import Image
import os

img = Image.open('ui-images/knowledge.jpg')

# Based on segment analysis:
# Segment (385, 433), center y=409, color=[228 198 88] (Gold/Yellow -> Folder)
# Segment (555, 613), center y=584, color=[250 244 254] (Light Purple/Blue -> Tag)
# Segment (731, 788), center y=759, color=[233 252 255] (Light Blue/Cyan -> Preview)

# centers:
centers = [
    (128, 409), # Folder
    (128, 584), # Tag
    (128, 759)  # Preview
]

# The radius should be around 44 as before, but let's make sure we capture the circle.
# Let's use r=50 to be safe.
r = 50

names = ['knowledge_folder_icon.png', 'knowledge_tag_icon.png', 'knowledge_preview_icon.png']

os.makedirs('assets', exist_ok=True)

for i, (cx, cy) in enumerate(centers):
    icon = img.crop((cx-r, cy-r, cx+r, cy+r))
    icon.save(f'assets/{names[i]}')
    print(f"Saved {names[i]} at center ({cx}, {cy})")

