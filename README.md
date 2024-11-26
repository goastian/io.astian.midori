# Midori Flatpak

This is a Flatpak manifest for Midori that downloads the official binaries from
GitHub (https://github.com/goastian/midori-desktop/releases).

## Requirements

    To build, you will need org.freedesktop.Sdk//24.08.
    To play MP3/MP4 files and other multimedia formats, install the Flatpak extension:
    org.freedesktop.Platform.ffmpeg.
  
## Create the midori-flatpak folder with this exact name:
sudo mkdir /home/usuario/midori-flatpak

# Copy the files 
Copy the files build.flatpak.sh, io.astian.midori.appdata.xml, io.astian.midori.desktop, io.astian.midori.json
 to the created folder (midori-flatpak).

## How to Build
Navigate to the midori-flatpak folder.
Run the following command:

```bash
$ sudo ./build.flatpak.sh

```
# Flatpak Midori
Once the build is complete, a file with the .flatpak extension will be created, called midori.flatpak.

## How to Run
$ sudo flatpak install /ruta/a/mi_midori.flatpak 

Once installed, you should be able to see the desktop file in your GNOME or KDE environment.
You can also run it directly from the terminal with the following command:

```
$ flatpak run io.astian.midori
```
