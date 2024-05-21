{ writeShellApplication, libnotify, yt-dlp, wl-clipboard }:

writeShellApplication {
  name = "yt-dlp-from-clipboard";

  runtimeInputs = [ libnotify yt-dlp wl-clipboard ];

  text = ''
    link=$(wl-paste)
    title=$(yt-dlp "$link" -O "%(title)s")
    mkdir -p ~/mpv/
    notify-send "Starting download" "'$title'" -t 5000
    yt-dlp "$link" -o "%(epoch>%Y%m%dT%H%M%S)s--%(title)s.%(ext)s" --restrict-filenames -P ~/mpv \
           --embed-metadata --embed-subs \
           || (notify-send "Download failed." "'$title'"; exit 1)
    notify-send "Download complete" "'$title'" -t 10000
  '';
}
