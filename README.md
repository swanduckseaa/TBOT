# TBOT

Mobile-friendly triggerbot with a custom crosshair and toggle switch.

## Raw GitHub loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/swanduckseaa/TBOT/main/triggerbot.lua"))()
```

This loads the current script directly from the GitHub raw file in the repository.

## Notes

- The script is toggle-based: ON activates triggerbot behavior, OFF disables it.
- It detects targets under the crosshair for mobile using a screen-space raycast.
- If Onion is installed, it prefers an Onion toggle; otherwise it creates a simple on-screen switch.
- The crosshair is easily customized in the script by editing the `state.crosshair` values.