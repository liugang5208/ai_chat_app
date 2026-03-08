from PIL import Image

img = Image.open('ui-images/knowledge.jpg')

# Manual crop based on knowledge.jpg layout analysis
# Each list item is about 110-120 pixels high
# 文件夹 icon center is around 128, 583
# Then the next ones are below it

centers = [
    (128, 583), # 文件夹
    (128, 703), # 标签
    (128, 823)  # 文件预览
]

names = ['knowledge_folder_icon.png', 'knowledge_tag_icon.png', 'knowledge_preview_icon.png']
r = 44

for i, (cx, cy) in enumerate(centers):
    icon = img.crop((cx-r, cy-r, cx+r, cy+r))
    icon.save(f'assets/{names[i]}')
    print(f"Saved {names[i]} at center ({cx}, {cy})")

