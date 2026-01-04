# Golden Axe Warrior Map

Interactive map for Golden Axe Warrior screenshots and per-screen notes.

## Usage

- Open [image-grid.html](image-grid.html) in your browser to view the map.
- Hover over a coordinate badge to see notes for that screen.
- Edit [notes.js](notes.js) to add or modify notes.

## Adding a screen

0. Set Windowed Scale to 1x, 4x or any other even scaling value.
1. Take a screenshot in RetroArch. Press F8.
2. Run the helper script to add the image:

```sh
sh addimg.sh 11_12
```

3. Add any notes to [notes.js](notes.js).
