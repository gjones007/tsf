# TinySoundFont wrapper for Vlang

TinySoundFont is a SoundFont2 synthesizer library in a single C/C++ file.  This repo is a V module which allows TinySoundFont to be used in V.

## Install

```sh
git clone https://github.com/gjones007/tsf.git ~/.vmodules/tsf
```

## Examples

SDL is needed for several of the examples.

```bash
v install sdl
```

This only needs to be done once.  Then run the example.

```sh
cd ~/.vmodules/tsf/examples
v run example1.v
```

You can add vorbis support with

```sh
# fetch latest STB Vorbis
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_vorbis.c
cd ~/.vmodules/tsf/examples
v -d vorbis run example4.v
```

Unless otherwise specified, everything in this repo is MIT License.
