<p align="center">
  <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/LargeTransparentLogo.png" width="180">
</p>

<h1 align="center">Elite Zone</h1>

<p align="center">
  this is <b>Elite Zone</b>'s official github repository.
</p>

<p align="center">
  <a href="https://elite-zone.xyz">
    <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/website.png" width="32">
  </a>
  &nbsp;&nbsp;
  <a href="https://discord.gg/JGwx7yq6HQ">
    <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/discord.png" width="32">
  </a>
  &nbsp;&nbsp;
  <a href="https://www.youtube.com/@Elite-Zone-EZ">
    <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/youtube.png" width="32">
  </a>
</p>

Elite Zone is a **complete, independently developed script** with its own features, systems, architecture, and original code.

Elite Zone is **not a fork of Linoria or any other library**. The project only incorporates a substantially rewritten and independently maintained library, alongside its own original implementation.

## usage

To use Elite Zone, execute the following loadstring through your scripting utility:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/scripter-sm/EliteZone/refs/heads/main/Loader.lua", true))()
```

The loader retrieves and initializes the current Elite Zone software.

### requirements

Your scripting utility should properly support the functionality required by Elite Zone, including:

1. File system functions.
2. `hookmetamethod` and `hookfunction`.
3. Standard Lua/Luau behavior without heavily modified or incomplete implementations.
4. Consistent behavior across supported functions and environments.
5. Avoid using shit scripting utility like xeno.
   
Different scripting utilities may implement these functions differently. Unexpected behavior caused by incomplete, modified, or incompatible implementations may not be an Elite Zone issue.

## troubleshooting

If Elite Zone is not working correctly, first make sure your scripting utility meets the requirements above.

### utility issues

A significant number of issues can be caused by the scripting utility itself. If you experience crashes, missing functionality, unexpected errors, or broken UI behavior:

1. Try a different supported scripting utility.
2. Make sure your utility have good UNCs.
3. Ensure your utility is using proper Luau-compatible implementations rather than incomplete replacements.
4. Make sure the utility is running the latest version available to you.
5. Check that your utility is not modifying or blocking Elite Zone's required functionality.

### user issues

If the issue does not appear to be caused by the scripting utility, try the following:

1. Close the game completely.
2. Delete the **`Elite Zone`** folder from your utility's workspace/files directory.
3. Reopen the game and execute the loader again.
4. Make sure you have a stable internet connection.
5. Make sure the Elite Zone loader can be accessed successfully.
6. Disable other scripts temporarily to check for conflicts.

If the problem persists, provide the exact error message and information about the scripting utility being used when asking for support.

## proprietary software

Elite Zone's original code, systems, features, architecture, and other proprietary components remain the property of Elite Zone unless explicitly stated otherwise.

`Loader.lua` and the Elite Zone software loaded or executed through it are proprietary and may be distributed in protected or obfuscated form.

You may not deobfuscate, decrypt, dump, extract, reverse engineer for the purpose of recovering source code, redistribute, republish, or otherwise make available proprietary Elite Zone software or source code without explicit permission from Elite Zone.

## third-party code

Elite Zone uses a **substantially rewritten and independently maintained library component** derived from the MIT-licensed [Linoria](https://github.com/violin-suzutsuki/LinoriaLib) project.

The original Linoria codebase is **not the Elite Zone project**. Any portions that remain subject to the MIT License retain the rights and conditions provided by that license.

The relevant components include:

* `Sources/gui/`
* `Dependencies/libraries/gui_library.lua`
* `Deprecated/old_libraries/library.lua`

These components remain subject to their applicable third-party licenses where those licenses grant rights broader than the proprietary Elite Zone license.

## deprecated code

`Deprecated/old_sources/gui/` is released under **CC0 1.0 Universal** and remains subject to the terms of CC0 1.0.

Deprecated components are separate from the current Elite Zone implementation and should not be interpreted as representative of the project's current architecture.

## third-party fonts

The `Dependencies/fonts/` directory contains third-party fonts.

These fonts are not owned by Elite Zone and remain subject to their respective copyright and license terms.

The Elite Zone license does not grant additional rights to these fonts.

## old library

`old-library.bak` is **not part of the current Elite Zone implementation**.

It is an older fork of the MIT-licensed [Linoria](https://github.com/violin-suzutsuki/LinoriaLib) library and remains subject to its original license.

If you're looking for the older library that resembles UE's forked version of Linoria, it is preserved as `old-library.bak`.

For complete licensing information, see `LICENSE.md`.

---

<p align="center">
  <a href="https://elite-zone.xyz">
    <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/website.png" width="24">
  </a>
  <a href="https://discord.gg/JGwx7yq6HQ">
    <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/discord.png" width="24">
  </a>
  <a href="https://www.youtube.com/@Elite-Zone-EZ">
    <img src="https://raw.githubusercontent.com/scripter-sm/EliteZone/main/README/youtube.png" width="24">
  </a>
</p>

<p align="center">
  © <b>Elite Zone</b> · 2026
</p>
