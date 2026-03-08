from PIL import Image

img = Image.open('ui-images/knowledge.jpg')

# The centers and size should be:
# centers_y = [409, 584, 759]
# Size is 109x109, so radius should be 55.

centers_y = [409, 584, 759]
cx = 128
r = 55 # 110x110 box to capture the full circular background

names = ['knowledge_folder_icon.png', 'knowledge_tag_icon.png', 'knowledge_preview_icon.png']

for i, cy in enumerate(centers_y):
    # Center cx=128
    icon = img.crop((cx-r, cy-r, cx+r, cy+r))
    icon.save(f'assets/{names[i]}')
    print(f"Saved {names[i]} at center ({cx}, {cy}) with r={r}")

