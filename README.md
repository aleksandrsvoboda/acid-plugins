# Acid plugins

Free VST3 instruments for Ableton Live (and other DAWs), each also a standalone app on Windows and Linux.

| Plugin | What it is | Mac | Windows | Linux |
|---|---|---|---|---|
| **AcidSampler** 1.0 | Sampler that detects a sample's pitch and plays it in tune on every note. Also loops with crossfade, time stretch, granulizer and LFOs. | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acidsampler-1.0/AcidSampler-macos.zip) | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acidsampler-1.0/AcidSampler-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acidsampler-1.0/AcidSampler-linux-x64.tar.gz) |
| **SacedOne** 1.1 | Mono synth with three engines (analog, 4-operator FM, granular), a multimode ladder filter, a 16-step sequencer and 24 Electro / Techno / Minimal presets. | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/sacedone-1.1/SacedOne-macos.zip) | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/sacedone-1.1/SacedOne-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/sacedone-1.1/SacedOne-linux-x64.tar.gz) |
| **Acid303** 2.0 | TB-303 style bass synth and acid workstation, with a sequencer. | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acid303-2.0/Acid303-macos.zip) | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acid303-2.0/Acid303-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acid303-2.0/Acid303-linux-x64.tar.gz) |
| **AcidKit** 1.0 | TR-808 / TR-909 drum machine. | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acidkit-1.0/AcidKit-macos.zip) | [zip](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acidkit-1.0/AcidKit-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/acid-plugins/releases/download/acidkit-1.0/AcidKit-linux-x64.tar.gz) |

## Mac: install them all with one command

Open **Terminal** (Cmd+Space, type Terminal), paste this line and press Enter. It asks for your Mac password once, and nothing shows while you type it:

```
curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/acid-plugins/main/install-mac.sh | bash
```

It downloads the plugins, puts them in `/Library/Audio/Plug-Ins/VST3` and removes macOS's "downloaded from the internet" block. That block is why macOS calls hand-installed plugins "damaged", and the "Open Anyway" button doesn't fix it for plugins. Run the same line again to update.

Then in **Ableton Live**: Settings > Plug-Ins, turn on *Use VST3 Plug-In System Folders*, **hold Option and click Rescan**. The plugins are under **Plug-Ins > VST3 > Acid303** and **Saced**.

## Windows

Unzip and copy the `.vst3` folder to `C:\Program Files\Common Files\VST3`, then Rescan in Live. Or run the `.exe` on its own. Windows may say "Windows protected your PC": click **More info > Run anyway**.
