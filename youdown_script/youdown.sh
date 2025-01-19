#!/bin/bash

# Überprüfen, ob yt-dlp installiert ist
if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp konnte nicht gefunden werden. Bitte installieren Sie es zuerst."
    exit
fi

# Pfad zu ffmpeg
FFMPEG_PATH="/c/ffmpeg-7.1-full_build/bin/ffmpeg.exe"

# Funktion zum Herunterladen von MP4
download_mp4() {
    yt-dlp -f mp4 --ffmpeg-location "$FFMPEG_PATH" "$1" --newline | while IFS= read -r line; do
        if [[ $line =~ \[download\]\ +([0-9]+\.[0-9]+)% ]]; then
            progress=${BASH_REMATCH[1]}
            progress=${progress%.*}  # Entferne den Dezimalteil
            draw_progress_bar "$progress"
        fi
    done
    echo -e "\nDownload abgeschlossen."
}

# Funktion zum Herunterladen von MP3
download_mp3() {
    yt-dlp --extract-audio --audio-format mp3 --ffmpeg-location "$FFMPEG_PATH" "$1" --newline | while IFS= read -r line; do
        if [[ $line =~ \[download\]\ +([0-9]+\.[0-9]+)% ]]; then
            progress=${BASH_REMATCH[1]}
            progress=${progress%.*}  # Entferne den Dezimalteil
            draw_progress_bar "$progress"
        fi
    done
    echo -e "\nDownload abgeschlossen."
}

# Funktion zum Zeichnen der Fortschrittsleiste
draw_progress_bar() {
    local progress=$1
    local width=50
    local filled=$((progress * width / 100))
    local empty=$((width - filled))
    printf "\r["
    printf "%0.s#" $(seq 1 $filled)
    printf "%0.s " $(seq 1 $empty)
    printf "] %s%%" "$progress"
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
        echo "Download von MP4 gestartet..."
        download_mp4 "$1"
        ;;
    mp3)
        echo "Download von MP3 gestartet..."
        download_mp3 "$1"
        ;;
    *)
        echo "Ungültiges Format angegeben. Bitte wählen Sie entweder 'mp4' oder 'mp3'."
        exit 1
        ;;
esac

echo "Download abgeschlossen."