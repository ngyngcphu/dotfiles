#!/usr/bin/env bash
# iTerm2 app-wide settings (the profile itself lives in profile.json as a Dynamic Profile).
# Run by install.sh. iTerm2 reads most of these at launch, so restart it after running.
set -euo pipefail

w() { defaults write com.googlecode.iterm2 "$@"; }

# Use the "dotfiles" Dynamic Profile (profile.json) for new windows
w "Default Bookmark Guid" -string "dotfiles-default"

# Clipboard: let terminal apps copy (tmux uses OSC 52); don't nag when access is denied
w AllowClipboardAccess -bool true
w NoSyncSuppressClipboardAccessDeniedWarning -bool true

# Paste without confirmation (multi-line, or one line ending in a newline at a shell prompt)
w NoSyncDoNotWarnBeforeMultilinePaste -bool true
w NoSyncDoNotWarnBeforeMultilinePaste_selection -int 0
w NoSyncDoNotWarnBeforePastingOneLineEndingInNewlineAtShellPrompt -bool true
w NoSyncDoNotWarnBeforePastingOneLineEndingInNewlineAtShellPrompt_selection -int 0

# Never drop mouse reporting when the reported host changes; otherwise the mouse wheel can
# start scrolling iTerm2's own history instead of reaching tmux/Neovim
w NoSyncTurnOffMouseReportingOnHostChange -bool false

# Allow escape sequences (e.g. `clear`) to clear scrollback
w PreventEscapeSequenceFromClearingHistory -bool false

# Windows: don't restore previous windows at launch, ignore macOS window restoration
w NoSyncWindowRestoresWorkspaceAtLaunch -bool false
w NoSyncIgnoreSystemWindowRestoration -bool true
w NoSyncSuppressPromptToEnableResizing -bool true

# Tabs: automatic tab style, no tab bar in full screen, manual macOS window tabbing
w TabStyleWithAutomaticOption -int 4
w ShowFullScreenTabBar -bool false
w AppleWindowTabbingMode -string manual

# Esc key: no sound, haptic feedback or visual indicator
w SoundForEsc -bool false
w HapticFeedbackForEsc -bool false
w VisualIndicatorForEsc -bool false

# Typing and rendering: key repeat instead of the accent popup, no scroll animation
w ApplePressAndHoldEnabled -bool false
w AppleScrollAnimationEnabled -int 0
w AppleSmoothFixedFontsSizeThreshold -int 1

# Updates: check automatically, don't send system profile
w SUEnableAutomaticChecks -bool true
w SUSendProfileInfo -bool false

if pgrep -xq iTerm2; then
	echo "iTerm2 settings written; restart iTerm2 (Cmd-Q, reopen) to apply them."
fi
