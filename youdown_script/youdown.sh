#!/bin/bash

# Überprüfen, ob yt-dlp installiert ist
if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp konnte nicht gefunden werden. Bitte installieren Sie es zuerst."
    exit
fi

# Funktion zum Herunterladen von MP4
download_mp4() {
    yt-dlp -f mp4 "$1"
}

# Funktion zum Herunterladen von MP3
download_mp3() {
    yt-dlp --extract-audio --audio-format mp3 "$1"
}

# Überprüfen, ob eine URL angegeben wurde
if [ -z "$1" ]; then
    echo "Bitte geben Sie eine YouTube-URL an."
    exit 1
fi

# Überprüfen, ob ein Format angegeben wurde
if [ -z "$2" ]; then
    echo "Bitte geben Sie das gewünschte Format an (mp4 oder mp3)."
    exit 1
fi

# Herunterladen basierend auf dem angegebenen Format
case "$2" in
    mp4)
        download_mp4 "$1"
        ;;
    mp3)
        download_mp3 "$1"
        ;;
    *)
        echo "Ungültiges Format. Bitte wählen Sie entweder 'mp4' oder 'mp3'."
        exit 1
        ;;
esac