#!/usr/bin/env bats

# Test suite for addimg.sh

setup() {
  # Create temporary test environment
  export TEST_TMPDIR=$(mktemp -d)
  export ORIGINAL_HOME="$HOME"
  export HOME="$TEST_TMPDIR"
  
  # Create required directories
  mkdir -p "$TEST_TMPDIR/Documents/RetroArch/screenshots"
  mkdir -p "$TEST_TMPDIR/Documents/GAW/imgs"
  
  # Create bin directory for mock executables
  mkdir -p "$TEST_TMPDIR/bin"
  export PATH="$TEST_TMPDIR/bin:$PATH"
  
  # Create mock magick command
  cat > "$TEST_TMPDIR/bin/magick" << 'MOCK_MAGICK'
#!/bin/bash
# Mock ImageMagick magick command
# Just creates output.png instead of actually processing
touch output.png
MOCK_MAGICK
  chmod +x "$TEST_TMPDIR/bin/magick"
  
  # Source the script to get access to variables
  cd "$TEST_TMPDIR/Documents/GAW"
}

teardown() {
  cd /
  rm -rf "$TEST_TMPDIR"
  export HOME="$ORIGINAL_HOME"
}

# Helper to run addimg.sh from the actual repo
run_addimg() {
  bash /Users/chrismiller/Documents/GAW/addimg.sh "$@"
}

# ========== ARGUMENT PARSING TESTS ==========

@test "shows usage when no arguments provided" {
  run run_addimg
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "shows help with -h flag" {
  run run_addimg -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "shows help with --help flag" {
  run run_addimg --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "rejects unknown options" {
  run run_addimg --invalid
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unknown option" ]]
}

@test "stops parsing options at -- and treats next arg as coordinate" {
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg -- 5,A
  [ "$status" -eq 0 ]
  [ -f "$HOME/Documents/GAW/imgs/5_A.png" ]
}

# ========== COORDINATE VALIDATION TESTS ==========

@test "requires coordinates argument" {
  run run_addimg
  [ "$status" -eq 1 ]
}

@test "rejects coordinates with missing row" {
  run run_addimg ",A"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Invalid coordinate format" ]]
}

@test "rejects coordinates with missing column" {
  run run_addimg "5,"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Invalid coordinate format" ]]
}

@test "accepts coordinates without comma (cut behavior quirk)" {
  # Note: Due to how cut works, "5A" without comma parses as row="5A", col="5A"
  # This is a quirk that could be addressed with better validation
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg 5A
  [ "$status" -eq 0 ]
  [ -f "$HOME/Documents/GAW/imgs/5A_5A.png" ]
}

@test "accepts valid numeric row and letter column" {
  # Create a mock screenshot so the script gets past filename check
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg 5,A
  [ "$status" -eq 0 ]
}

@test "accepts valid coordinates with grayscale flag before coords" {
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg -g 5,A
  [ "$status" -eq 0 ]
}

@test "accepts valid coordinates with --grayscale before coords" {
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg --grayscale 5,A
  [ "$status" -eq 0 ]
}

# ========== DIRECTORY & FILE VALIDATION TESTS ==========

@test "exits when screenshot directory doesn't exist" {
  rm -rf "$HOME/Documents/RetroArch/screenshots"
  
  run run_addimg 5,A
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Screenshot directory not found" ]]
}

@test "exits when no Golden Axe Warrior screenshots exist" {
  run run_addimg 5,A
  [ "$status" -eq 1 ]
  [[ "$output" =~ "No Golden Axe Warrior" ]]
}

@test "finds the latest screenshot when multiple exist" {
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior002.png"
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior003.png"
  
  run run_addimg 5,A
  [ "$status" -eq 0 ]
  
  # The latest file (003) should be deleted
  [ ! -f "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior003.png" ]
}

# ========== FILE OPERATION TESTS ==========

@test "creates output file with correct naming convention" {
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg 7,F
  [ "$status" -eq 0 ]
  
  [ -f "$HOME/Documents/GAW/imgs/7_F.png" ]
}

@test "deletes the original screenshot after processing" {
  screenshot="$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  touch "$screenshot"
  
  run run_addimg 3,B
  [ "$status" -eq 0 ]
  
  [ ! -f "$screenshot" ]
}

@test "handles grayscale flag without affecting output location" {
  touch "$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  
  run run_addimg -g 10,Z
  [ "$status" -eq 0 ]
  
  [ -f "$HOME/Documents/GAW/imgs/10_Z.png" ]
}

# ========== INTEGRATION TESTS ==========

@test "full workflow: parse args, find file, process, move, delete" {
  screenshot="$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  touch "$screenshot"
  
  run run_addimg 4,C
  [ "$status" -eq 0 ]
  
  # Verify all steps completed
  [ -f "$HOME/Documents/GAW/imgs/4_C.png" ]
  [ ! -f "$screenshot" ]
}

@test "full workflow with grayscale option" {
  screenshot="$HOME/Documents/RetroArch/screenshots/Golden Axe Warrior001.png"
  touch "$screenshot"
  
  run run_addimg --grayscale 6,D
  [ "$status" -eq 0 ]
  
  [ -f "$HOME/Documents/GAW/imgs/6_D.png" ]
  [ ! -f "$screenshot" ]
}
