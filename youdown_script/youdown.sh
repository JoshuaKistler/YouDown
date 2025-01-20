#!/bin/bash

# Überprüfen, ob yt-dlp installiert ist
if ! command -v yt-dlp &> /dev/null
then
    echo "yt-dlp konnte nicht gefunden werden. Bitte installieren Sie es zuerst."
    exit 1
fi

# Pfad zu ffmpeg
FFMPEG_PATH="/c/ffmpeg-7.1-full_build/bin/ffmpeg.exe"

# Funktion zum Herunterladen von MP4
download_mp4() {
    local url=$1
    local format=$2
    local title=$(yt-dlp --get-title "$url")
    local date=$(date +%Y-%m-%d)
    local filename="${title}_${date}.mp4"
    yt-dlp -f "$format" --ffmpeg-location "$FFMPEG_PATH" -o "$filename" "$url" --newline | while IFS= read -r line; do
        if [[ $line =~ \[download\]\ +([0-9]+\.[0-9]+)% ]]; then
            progress=${BASH_REMATCH[1]}
            progress=${progress%.*}  # Entferne den Dezimalteil
            draw_progress_bar "$progress"
        fi
    done
    echo -e "\nDownload abgeschlossen. Datei gespeichert als $filename"
}

# Funktion zum Herunterladen von MP3
download_mp3() {
    local url=$1
    local format=$2
    local title=$(yt-dlp --get-title "$url")
    local date=$(date +%Y-%m-%d)
    local filename="${title}_${date}.mp3"
    yt-dlp -f "$format" --extract-audio --audio-format mp3 --ffmpeg-location "$FFMPEG_PATH" -o "$filename" "$url" --newline | while IFS= read -r line; do
        if [[ $line =~ \[download\]\ +([0-9]+\.[0-9]+)% ]]; then
            progress=${BASH_REMATCH[1]}
            progress=${progress%.*}  # Entferne den Dezimalteil
            draw_progress_bar "$progress"
        fi
    done
    echo -e "\nDownload abgeschlossen. Datei gespeichert als $filename"
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

# URL und Format speichern
URL=$1
FORMAT=$2

# Verfügbare Formate auflisten
echo "Verfügbare Formate für $URL:"
yt-dlp -F "$URL"

# Benutzer zur Auswahl eines Formats auffordern
read -p "Bitte geben Sie die gewünschte Format-ID ein: " FORMAT_ID

# Herunterladen basierend auf dem angegebenen Format
case "$FORMAT" in
    mp4)
        echo "Download von MP4 gestartet..."
        download_mp4 "$URL" "$FORMAT_ID"
        ;;
    mp3)
        echo "Download von MP3 gestartet..."
        download_mp3 "$URL" "$FORMAT_ID"
        ;;
    *)
        echo "Ungültiges Format angegeben. Bitte wählen Sie entweder 'mp4' oder 'mp3'."
        exit 1
        ;;
esac

echo "Download abgeschlossen."