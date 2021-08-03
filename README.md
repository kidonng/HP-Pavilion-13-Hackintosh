# 🍎 HP Pavilion 13 Hackintosh

**READ THE NOTES BEFORE USING THE EFI**

## Specs

- Device: [HP Pavilion 13-an0002tu](https://support.hp.com/us-en/document/c06145752)
- CPU: [i5-8265U](https://ark.intel.com/content/www/us/en/ark/products/149088/intel-core-i5-8265u-processor-6m-cache-up-to-3-90-ghz.html)
- Board: HP 84C5

## Status

OpenCore `0.7.2`, macOS `12.0 (21A5294g)`, BIOS `F.12`

- [x] Boot
- [x] GPU acceleration
- [x] Wi-Fi

  **Known issue:** Have trouble connecting to some hotspots, e.g. 2.4GHz or [iPhone](https://github.com/OpenIntelWireless/itlwm/issues/310).

- [x] Bluetooth

  **Known issue**: [Turning off bluetooth will make it stop working](https://github.com/acidanthera/BrcmPatchRAM/pull/12). Workaround: kill `bluetoothd`.

- [x] Keyboard
- [x] Touchpad & gestures

  **Known issue**: _Tap to click_ may not work at boot or after waking up. Work around: restarting or waking again may help.

- [x] Battery status
- [x] Sleep/wake
- [ ] Hibernate (untested)
- [x] Sound
- [x] Camera
- [x] Mic
- [x] USB
- [x] HDMI (thanks to [@samchan1995](https://github.com/samchan1995))
- [ ] Headphone Jack Combo (untested, possibly broken)
- [ ] Card reader (untested, possibly broken)
- [ ] ~~Fingerprint~~ (impossible)

## Screenshots

![Screenshot of about](Screenshots/about.png)

![Screenshot of neofetch](Screenshots/neofetch.png)

## Notes

- **Set `AppleXcpmCfgLock` to `true` if CFG lock is not unlocked**.

  Note that certain actions such as performing security reset in BIOS will reset CFG lock.

- **Use different `PlatformInfo` values (`Serial`, `ROM`, etc.)**
- If macOS installation stuck on messages beginning with `AirportI`, try force rebooting.

## Credits

- [Sound](https://github.com/insanelydeepak/cloverHDA-for-Mac-OS-Sierra-10.12/issues/27#issuecomment-318953631)
- [Battery](https://github.com/the-eric-kwok/HP-Pavillion-bc015tx-Hackintosh/blob/682a675d778ad03faae3984913871c7b3648410b/SSDT/SSDT-BatteryFix-bc015tx.dsl)
- [Unlock CFG Lock](https://zhuanlan.zhihu.com/p/121655468)

## See also

- http://bbs.pcbeta.com/forum.php?mod=viewthread&tid=1824403
- http://bbs.pcbeta.com/forum.php?mod=viewthread&tid=1856395
- http://bbs.pcbeta.com/forum.php?mod=viewthread&tid=1858446

## License

- Original content (such as [`SSDT-BATT`](Source/SSDT-BATT.dsl)): [MIT](https://opensource.org/licenses/MIT)
- Third-paty components (Bootloader, Kext, etc.) : Refer to the source of each component
