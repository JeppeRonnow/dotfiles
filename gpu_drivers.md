# RTX 5060 Ti Setup Summary

## What We Did

**1. Installed the correct Nvidia drivers:**
- Your RTX 5060 Ti **requires** the open-source kernel modules
- Installed: `nvidia-open` and `nvidia-utils`
- The old proprietary `nvidia` driver doesn't work with 50-series cards

**2. Configured Hyprland to use the Nvidia GPU:**

In `~/.config/hypr/hyprland.conf` (or wherever you source configs from):
```bash
env = WLR_DRM_DEVICES,/dev/dri/card1
```

This tells Hyprland to use card1 (Nvidia GPU) instead of card0 (framebuffer).

**3. Monitor configuration:**

In `~/.config/hypr/monitors.conf`:
```bash
monitor = DP-1, 1920x1080@144, 0x0, 1
monitor = HDMI-A-1, 1920x1080@60, 1920x0, 1
```

Note: Monitor names are `DP-1` and `HDMI-A-1` (not DP-2/HDMI-A-2).

---

## How to Update Nvidia Drivers in the Future

**Simple update (recommended):**
```bash
sudo pacman -Syu
```
This updates everything including nvidia-open.

**After driver updates, rebuild initramfs:**
```bash
sudo mkinitcpio -P
reboot
```

---

## How to Verify GPU is Working Correctly

**1. Check if GPU is detected:**
```bash
nvidia-smi
```
Should show your RTX 5060 Ti with temperature, memory usage, etc.

**2. Check which card Hyprland is using:**
```bash
hyprctl monitors all
```
Should show DP-1 and HDMI-A-1 (both monitors working).

**3. Check DRM devices:**
```bash
ls /sys/class/drm/
```
Should show both card0 and card1 (with card1 having your monitors).

**4. Verify Nvidia modules are loaded:**
```bash
lsmod | grep nvidia
```
Should show: `nvidia_drm`, `nvidia_modeset`, `nvidia_uvm`, `nvidia`

**5. Test GPU rendering:**
```bash
glxinfo | grep "OpenGL renderer"
```
Should say "NVIDIA GeForce RTX 5060 Ti" (not llvmpipe or software rendering).

**6. Run a GPU benchmark (optional):**
```bash
sudo pacman -S glmark2
glmark2
```

---

## Important Notes

- **Always use `nvidia-open`** for RTX 50-series cards, not the proprietary `nvidia` package
- If monitors stop working after an update, check that `WLR_DRM_DEVICES=/dev/dri/card1` is still set
- For the YouTube flickering issue: that's a separate problem with Firefox/Wayland that we didn't fix yet (we can tackle that once everything else is stable)

---

**Your system should now be working with both monitors! Test it out and let me know if you need help with anything else.** 🎉
