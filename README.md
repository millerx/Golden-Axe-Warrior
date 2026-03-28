# Golden Axe Warrior Map

Interactive map for Golden Axe Warrior screenshots and per-screen notes.

## Setup

1. Install imagemagick:

```sh
brew install imagemagick
```

2. Copy `addimg.sh` to `~/Documents/RetroArch/screenshots`:

```sh
cp addimg.sh ~/Documents/RetroArch/screenshots/
```

## Usage

- Open [image-grid.html](image-grid.html) in your browser to view the map.
- Hover over a coordinate badge to see notes for that screen.
- Edit [notes.js](notes.js) to add or modify notes.
- Enable or disable tunnels overlay. Add tunnels in [notes.js](notes.js).

## Adding a screen

1. Set Windowed Scale to 1x, 4x or any other even scaling value.
2. Take a screenshot in RetroArch. Press F8.
3. Run the helper script to add the image:

```sh
cd ~/Documents/RetroArch/screenshots/
sh addimg.sh 11_12
```

## Notes

Add any notes to [notes.js](notes.js).

The game has tunnels between certain screens. Add any tunnels found to the `TUNNELS` variable in [notes.js](notes.js).

## Dungeons

Map your way through a dungeon with `dungeon_map.txt` as a template.
I chose not commit dungeon maps.

```sh
cat dungeon_map.txt | pbcopy
```
