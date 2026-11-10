# Sacid plugins

Free VST3 instruments and effects for Ableton Live and other DAWs. Each one is also a standalone app on Windows and Linux.

| Plugin | What it is | Mac | Windows | Linux |
|---|---|---|---|---|
| **SacidOne** 1.2 | Mono synth with three engines (analog, 4-operator FM, granular), a multimode ladder filter, a 16-step sequencer and 24 Electro / Techno / Minimal presets. | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidone-1.2/SacidOne-macos.zip) | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidone-1.2/SacidOne-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidone-1.2/SacidOne-linux-x64.tar.gz) |
| **SacidSampler** 1.1 | Sampler that detects a sample's pitch and plays it in tune on every note, with crossfade loops, time stretch, a granulizer and LFOs. | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidsampler-1.1/SacidSampler-macos.zip) | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidsampler-1.1/SacidSampler-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidsampler-1.1/SacidSampler-linux-x64.tar.gz) |
| **SacidKit** 1.1 | TR-808 / TR-909 style drum machine. Shape each drum, play the kit or drag drums into Live as samples. | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidkit-1.1/SacidKit-macos.zip) | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidkit-1.1/SacidKit-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidkit-1.1/SacidKit-linux-x64.tar.gz) |
| **Sacid303** 2.1 | TB-303 style bass synth and acid workstation, with a 16-pattern sequencer. | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacid303-2.1/Sacid303-macos.zip) | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacid303-2.1/Sacid303-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacid303-2.1/Sacid303-linux-x64.tar.gz) |
| **SacidHalo** 1.0 | *Effect*: a harmonic exciter (even or odd harmonics, filtered) feeding a reverb with attack, decay, size, diffusion and width. | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidhalo-1.0/SacidHalo-macos.zip) | [zip](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidhalo-1.0/SacidHalo-win64.zip) | [tar.gz](https://github.com/aleksandrsvoboda/sacid-plugins/releases/download/sacidhalo-1.0/SacidHalo-linux-x64.tar.gz) |

## Install with one command

Each command lists the five plugins, marks the ones you already have, and asks which to install:

```
  1) SacidOne      mono synth: analog / FM / granular + step sequencer   [installed]
  2) SacidSampler  pitch-tracking sampler
  3) SacidKit      808 / 909 drum machine
  4) Sacid303      303 bass synth + sequencer
  5) SacidHalo     harmonic exciter + reverb (effect)

Which ones? Numbers like "1 3 5", Enter = all, q = quit:
```

Type the numbers you want, or press Enter for all of them. Plugins you already have are updated to the newest version, so run the same command again later to update.

### Mac

Open **Terminal** (Cmd+Space, type Terminal), paste this line and press Enter. It asks for your Mac password once, and nothing shows on screen while you type it:

```
curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-mac.sh | bash
```

The plugins aren't notarised by Apple. The installer removes the "downloaded from the internet" block, which is why hand-installed copies get called "damaged". The "Open Anyway" button doesn't work for plugins.

### Windows

Open **PowerShell** (Start menu, type PowerShell), paste this line and press Enter. Allow the administrator prompt:

```
irm https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-windows.ps1 | iex
```

The plugins go into `C:\Program Files\Common Files\VST3`. The standalone apps go into the Start menu under **Sacid**.

### Linux

Open a terminal and run the command below. No root is needed:

```
curl -fsSL https://raw.githubusercontent.com/aleksandrsvoboda/sacid-plugins/main/install-linux.sh | bash
```

The plugins go into `~/.vst3` and the standalone apps into `~/.local/bin`.

### Then, in Ableton Live

1. Open **Settings > Plug-Ins**.
2. Turn on *Use VST3 Plug-In System Folders*.
3. Click **Rescan**. On a Mac, hold **Option** while you click it.

The plugins are under **Plug-Ins > VST3 > Sacid**. SacidHalo is an audio effect, and the other four are instruments.
