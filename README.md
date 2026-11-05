# tv-play

Videos und Bilder vom Linux-Rechner per **AirPlay** auf ein **Apple TV** streamen –
im Terminal oder per Rechtsklick in Dolphin („Auf Apple TV abspielen“).

```bash
tv-play urlaub.mp4            # Video abspielen
tv-play film1.mkv film2.mp4   # mehrere Videos nacheinander
tv-play ~/Bilder/Urlaub/*.jpg # Bilder als Diashow (6 s pro Bild)
```

- MP4/MOV mit H.264/HEVC startet sofort, andere Formate (MKV, AVI, …) wandelt `ffmpeg` vorher um.
- Getestet mit Apple TV 4K (3. Gen.), tvOS 27.

## Installation

### Arch Linux / CachyOS / Manjaro (pacman-Paketquelle)

Einmalig die Paketquelle in `/etc/pacman.conf` eintragen (am Ende der Datei):

```ini
[tv-play]
SigLevel = Optional TrustAll
Server = https://github.com/joshlukas/tv-play/releases/download/repo
```

Danach wie jedes andere Paket installieren und aktualisieren – auch über grafische Paketmanager:

```bash
sudo pacman -Sy tv-play
```

### Andere Linux-Distributionen

Benötigt Python ≥ 3.11, git, ffmpeg und avahi. Installiert nur für den aktuellen Benutzer nach `~/.local`:

```bash
git clone https://github.com/joshlukas/tv-play.git
cd tv-play
./install.sh
```

Entfernen: `./install.sh --uninstall`

## Einrichtung

1. **Koppeln** (einmalig): `tv-play --pair` – am Fernseher erscheint ein 4-stelliger Code.
   Bei mehreren Apple TVs wird gefragt, welches; die Wahl wird gespeichert
   (`~/.config/tv-play/config.json`), ein anderes Gerät geht jederzeit mit `-d NAME`.
2. **Firewall:** Das Apple TV holt das Video vom Rechner ab (Port 8099). Mit ufw z. B.:
   ```bash
   sudo ufw allow from 192.168.0.0/16 to any port 8099 proto tcp
   ```
3. Am Apple TV unter *Einstellungen → AirPlay und HomeKit → Zugriff erlauben*
   sollte „Alle im selben Netzwerk“ oder „Jeder“ gewählt sein.

## Einstellungen (Umgebungsvariablen)

| Variable | Standard | Bedeutung |
|---|---|---|
| `TV_PLAY_DEVICE` | gekoppeltes Gerät | Name des Apple TV |
| `TV_PLAY_PORT` | `8099` | Port, über den das Apple TV die Datei abholt |
| `TV_PLAY_SLIDE_SECONDS` | `6` | Anzeigedauer pro Bild in der Diashow |

## Bekannte Einschränkungen

- tv-play nutzt [pyatv](https://github.com/postlund/pyatv). Die offizielle Version 0.18.0 kann auf
  tvOS 26/27 keine Videos starten ([Issue #2906](https://github.com/postlund/pyatv/issues/2906)).
  Bis zu einem offiziellen Update wird ein Korrektur-Stand
  ([robkochman/pyatv@8144c77](https://github.com/robkochman/pyatv/commit/8144c77c6cecbed4f9ba2adb5a350ad86a8f6604))
  mitgeliefert, zusammen mit `srptools` 1.0.1 (Version 2.0 ist inkompatibel).
- Verlässt man das Video am Fernseher, merkt tv-play das unter Umständen erst spät – dann Strg+C drücken.
- `tv-play --stop` pausiert auf manchen tvOS-Versionen nur.
- Keine Bildschirmspiegelung, nur Dateien.

## Paketquelle aktualisieren (für Maintainer)

```bash
scripts/publish-arch-repo.sh   # baut das Paket und lädt es ins Release „repo“ hoch
```

Nach einem Python-Update von Arch (z. B. 3.14 → 3.15) `pkgrel` erhöhen und neu veröffentlichen,
da `miniaudio` als kompiliertes Modul beiliegt.

## Lizenz

MIT – siehe [LICENSE](LICENSE). Mitgelieferte Bibliotheken (pyatv, srptools, miniaudio, tinytag)
stehen ebenfalls unter MIT-Lizenz.
