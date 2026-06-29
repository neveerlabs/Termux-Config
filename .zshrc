HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt NO_NOTIFY

autoload -Uz compinit
compinit

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555"
ZSH_AUTOSUGGEST_STRATEGY=(history)

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[default]='fg=white'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[path]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=magenta'

typeset -A ZSH_HIGHLIGHT_PATTERNS
ZSH_HIGHLIGHT_PATTERNS=('--help' 'fg=cyan,bold' '--version' 'fg=cyan,bold' '--updates' 'fg=cyan,bold' '--update' 'fg=cyan,bold' '--changelog' 'fg=cyan,bold' '--location' 'fg=cyan,bold' '--schedule' 'fg=cyan,bold')

source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' history-search yes
zstyle ':autocomplete:*' insert-unambiguous no
zstyle ':autocomplete:*' list-lines 16
zstyle ':autocomplete:*' autosuggest no
zstyle ':autocomplete:*' recent-dirs-insert always
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
bindkey -M autocomplete '^[[C' _accept_suggestion_or_forward_char
bindkey -M autocomplete '^F' autosuggest-accept

alias ls='ls --color=auto'
export LS_COLORS='di=36:fi=37:ln=36:ex=32:or=31:mi=31:pi=35:so=33:bd=33;1:cd=33;1:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:*.tar=01;33:*.tgz=01;33:*.arc=01;33:*.arj=01;33:*.taz=01;33:*.lha=01;33:*.lz4=01;33:*.lzh=01;33:*.lzma=01;33:*.tlz=01;33:*.txz=01;33:*.tzo=01;33:*.t7z=01;33:*.zip=01;33:*.z=01;33:*.dz=01;33:*.gz=01;33:*.lrz=01;33:*.lz=01;33:*.lzo=01;33:*.xz=01;33:*.zst=01;33:*.tzst=01;33:*.bz2=01;33:*.bz=01;33:*.tbz=01;33:*.tbz2=01;33:*.tz=01;33:*.deb=01;33:*.rpm=01;33:*.jar=01;33:*.war=01;33:*.ear=01;33:*.sar=01;33:*.rar=01;33:*.alz=01;33:*.ace=01;33:*.zoo=01;33:*.cpio=01;33:*.7z=01;33:*.rz=01;33:*.cab=01;33:*.wim=01;33:*.swm=01;33:*.dwm=01;33:*.esd=01;33:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

TERMUX_CONFIG_VERSION="v4.0.0"

[ -f ~/.zsh_config ] && source ~/.zsh_config
if [ -z "$USER_NAME" ]; then
    USER_NAME="user"
fi
if [ -z "$ENABLE_MYSQL" ]; then
    ENABLE_MYSQL="yes"
fi
if [ -z "$UPDATE_CHECK" ]; then
    UPDATE_CHECK="yes"
fi

if [[ "$ENABLE_MYSQL" == "yes" ]]; then
    if command -v mysqld >/dev/null 2>&1 || command -v mariadbd >/dev/null 2>&1; then
        if ! pgrep -x "mysqld" > /dev/null && ! pgrep -x "mariadbd" > /dev/null; then
            termux-wake-lock 2>/dev/null
            mysqld --log-error=/dev/null --general-log=0 --slow-query-log=0 --pid-file=$PREFIX/var/lib/mysql/$(hostname).pid &>/dev/null &!
        fi
    fi
fi

if [[ -z "$_TERMUX_WELCOME_SHOWN" ]]; then
    printf 'Welcome to Termux!\n\n'
    export _TERMUX_WELCOME_SHOWN=1
fi

TERMUX_CONFIG_DIR="$HOME/Termux-Config"
_update_check_done=0

_download_with_progress() {
    local url="$1"
    local dest="$2"
    local filename=$(basename "$dest")
    printf 'Updating %s ... ' "$filename"
    if curl -# -L -o "$dest" "$url" 2>&1; then
        printf 'Done\n'
        return 0
    else
        printf 'Failed\n'
        return 1
    fi
}

_get_remote_version() {
    if ! command -v curl >/dev/null 2>&1; then
        return 1
    fi
    local remote_zshrc
    remote_zshrc=$(curl -fsSL --max-time 10 "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/.zshrc" 2>/dev/null)
    if [[ -z "$remote_zshrc" ]]; then
        return 1
    fi
    local ver
    ver=$(echo "$remote_zshrc" | grep -o 'TERMUX_CONFIG_VERSION="[^"]*"' | head -1 | grep -o '"[^"]*"' | tr -d '"')
    if [[ -z "$ver" ]]; then
        return 1
    fi
    echo "$ver"
    return 0
}

_version_parse() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import sys; v=sys.argv[1].lstrip('v'); print('.'.join(str(int(x)) for x in v.split('.')))" "$1" 2>/dev/null || echo "0.0.0"
    else
        local v="${1#v}"
        echo "$v" | awk -F. '{ printf "%d.%d.%d", $1+0, $2+0, $3+0 }' 2>/dev/null || echo "0.0.0"
    fi
}

_version_greater_equal() {
    local v1=$(_version_parse "$1")
    local v2=$(_version_parse "$2")
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import sys
v1 = tuple(map(int, sys.argv[1].split('.')))
v2 = tuple(map(int, sys.argv[2].split('.')))
sys.exit(0 if v1 >= v2 else 1)
" "$v1" "$v2" 2>/dev/null
        return $?
    else
        local IFS=.
        local a1=(${=v1})
        local a2=(${=v2})
        for i in 1 2 3; do
            local x=${a1[$i]:-0}
            local y=${a2[$i]:-0}
            if (( x > y )); then
                return 0
            elif (( x < y )); then
                return 1
            fi
        done
        return 0
    fi
}

_show_changelog_since() {
    local since_version="$1"
    local changelog_file="$TERMUX_CONFIG_DIR/Changelog.json"
    local changelog_json
    if command -v curl >/dev/null 2>&1; then
        changelog_json=$(curl -fsSL --max-time 10 "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/Changelog.json" 2>/dev/null)
        if [[ -n "$changelog_json" ]]; then
            printf '%s\n' "$changelog_json" > "$changelog_file"
        fi
    fi
    if [[ -z "$changelog_json" ]]; then
        if [[ -f "$changelog_file" ]]; then
            changelog_json=$(cat "$changelog_file")
        else
            printf 'Changelog not available.\n'
            return 1
        fi
    fi
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json, sys
entries = json.loads(sys.stdin.read())
since = sys.argv[1]
def parse(v):
    return tuple(map(int, v.lstrip('v').split('.')))
target = parse(since)
latest = None
for e in entries:
    if parse(e['version']) > target:
        latest = e
        break
if latest:
    print(f\"Version {latest['version']}:\n{latest['changes']}\")
else:
    print('No recent changes.')
" "$since_version" <<< "$changelog_json" 2>/dev/null || printf 'Failed to parse changelog.\n'
    else
        printf 'Python3 required to display changelog.\n'
    fi
}

_show_full_changelog() {
    local changelog_file="$TERMUX_CONFIG_DIR/Changelog.json"
    local changelog_json
    if command -v curl >/dev/null 2>&1; then
        changelog_json=$(curl -fsSL --max-time 10 "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/Changelog.json" 2>/dev/null)
        if [[ -n "$changelog_json" ]]; then
            printf '%s\n' "$changelog_json" > "$changelog_file"
        fi
    fi
    if [[ -z "$changelog_json" ]]; then
        if [[ -f "$changelog_file" ]]; then
            changelog_json=$(cat "$changelog_file")
        else
            printf 'Changelog not available.\n'
            return 1
        fi
    fi
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json, sys
try:
    entries = json.loads(sys.stdin.read())
except:
    print('Failed to parse changelog.')
    sys.exit(1)
for i, e in enumerate(entries):
    print(f\"Version {e['version']}:\")
    print(e['changes'])
    if i < len(entries) - 1:
        print('\n' + '─' * 40 + '\n')
" <<< "$changelog_json" 2>/dev/null || printf 'Failed to parse changelog.\n'
    else
        printf 'Python3 required to display full changelog.\n'
    fi
}

_update_plugins() {
    local plugins=(
        "$HOME/.zsh/zsh-autosuggestions"
        "$HOME/.zsh/zsh-syntax-highlighting"
        "$HOME/.zsh/zsh-autocomplete"
    )
    for plugin in "${plugins[@]}"; do
        if [[ -d "$plugin/.git" ]]; then
            git -C "$plugin" pull --ff-only 2>/dev/null
        fi
    done
}

_perform_update() {
    local base_url="https://raw.githubusercontent.com/neveerlabs/Termux-Config/main"
    local update_failed=0
    mkdir -p "$TERMUX_CONFIG_DIR"
    _download_with_progress "$base_url/.zshrc" "$HOME/.zshrc.tmp" || update_failed=1
    if [[ $update_failed -eq 0 ]]; then
        mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
        cp "$HOME/.zshrc" "$TERMUX_CONFIG_DIR/.zshrc"
    fi
    _download_with_progress "$base_url/Changelog.json" "$TERMUX_CONFIG_DIR/Changelog.json" || true
    _download_with_progress "$base_url/README.md" "$TERMUX_CONFIG_DIR/README.md" || true
    _download_with_progress "$base_url/config.sh" "$TERMUX_CONFIG_DIR/config.sh" || true
    _update_plugins
    if [[ $update_failed -eq 0 ]]; then
        printf '\nUpdate complete. Restart Termux to apply changes.\n'
    else
        printf '\nUpdate finished with errors. Some files may not have been updated.\n'
    fi
}

_scan_updates_output() {
    if ! command -v curl >/dev/null 2>&1; then
        printf 'curl is required.\n'
        return 1
    fi
    local remote_version
    remote_version=$(_get_remote_version)
    if [[ -z "$remote_version" ]]; then
        printf 'Unable to check remote version. Check your internet connection.\n'
        return 1
    fi
    printf 'Local version:  %s\n' "$TERMUX_CONFIG_VERSION"
    printf 'Remote version: %s\n' "$remote_version"
    if [[ "$TERMUX_CONFIG_VERSION" != "$remote_version" ]]; then
        if _version_greater_equal "$remote_version" "$TERMUX_CONFIG_VERSION"; then
            printf '\nUpdate available.\n\n'
            _show_changelog_since "$TERMUX_CONFIG_VERSION"
        else
            printf '\nLocal version is newer than remote. You may have a pre-release.\n'
        fi
    else
        printf 'Already up to date.\n'
    fi
    return 0
}

_check_for_updates() {
    if [[ $_update_check_done -eq 1 ]]; then
        return
    fi
    _update_check_done=1
    if [[ "$UPDATE_CHECK" != "yes" ]]; then
        return
    fi
    if [[ ! -d "$TERMUX_CONFIG_DIR" ]]; then
        mkdir -p "$TERMUX_CONFIG_DIR"
    fi
    if ! command -v curl >/dev/null 2>&1; then
        return
    fi
    local remote_version
    remote_version=$(_get_remote_version)
    if [[ -z "$remote_version" ]]; then
        return
    fi
    if [[ "$TERMUX_CONFIG_VERSION" != "$remote_version" ]]; then
        if _version_greater_equal "$remote_version" "$TERMUX_CONFIG_VERSION"; then
            printf '\n'
            printf '╔══════════════════════════════════════════╗\n'
            printf '║  Update available!                      ║\n'
            printf '╠══════════════════════════════════════════╣\n'
            printf '║  Current version: %-23s║\n' "$TERMUX_CONFIG_VERSION"
            printf '║  New version:     %-23s║\n' "$remote_version"
            printf '╚══════════════════════════════════════════╝\n'
            printf '\n'
            _show_changelog_since "$TERMUX_CONFIG_VERSION"
            printf 'Do you want to update? (y/n): '
            read -rk1 ans
            printf '\n'
            if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
                _perform_update
            fi
        fi
    fi
}

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes false
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f'

_last_exit_code=0
_first_prompt=1
precmd() {
    _last_exit_code=$?
    if (( _first_prompt )); then
        printf '\033[2J\033[H'
        _first_prompt=0
        _check_for_updates
        (_auto_update_schedule &)
    fi
    vcs_info
    printf '\e[2 q'
    printf '\e]12;white\a'

    local env_part=""
    if [[ -n $VIRTUAL_ENV ]]; then
        env_part="%F{green}($(basename $VIRTUAL_ENV))%f│"
    fi

    local display_path
    if [[ $PWD == $HOME ]]; then
        display_path="~"
    elif [[ $PWD == $HOME/* ]]; then
        display_path="~/${PWD#$HOME/}"
    else
        display_path="$PWD"
    fi

    if (( ${#display_path} > 30 )); then
        if [[ $PWD == $HOME || $PWD == $HOME/* ]]; then
            display_path="~/⋯/${PWD##*/}"
        else
            display_path="/⋯/${PWD##*/}"
        fi
    fi

    local green="%F{green}"
    local cyan="%F{cyan}"
    local white="%F{white}"
    local reset="%f"

    PROMPT="${green}┌───${reset}${env_part}${green}(${reset}${cyan}${USER_NAME}㉿termux${reset}${green})-[${reset}${white}${display_path}${reset}${green}]${vcs_info_msg_0_}${reset}
${green}└──${white}\$${reset} "
}

zshaddhistory() {
    [[ $_last_exit_code -eq 0 ]] && return 0 || return 1
}

function _accept_suggestion_or_forward_char() {
    if [[ -n $POSTDISPLAY ]] && [[ $CURSOR -eq ${#BUFFER} ]]; then
        zle autosuggest-accept
    else
        zle forward-char
    fi
}
zle -N _accept_suggestion_or_forward_char
bindkey '^[[C' _accept_suggestion_or_forward_char
bindkey '^F' autosuggest-accept
bindkey '^[[1;3C' forward-word

command_not_found_handler() {
    case "$1" in
        --help)
            printf '%s\n' "Available custom commands:"
            printf '%s\n' "  --help          Show this help message"
            printf '%s\n' "  --version       Show script version"
            printf '%s\n' "  --updates [scan|install]   Check for updates (default: scan)"
            printf '%s\n' "  --update        Update configuration files"
            printf '%s\n' "  --reconfig      Re-run setup script"
            printf '%s\n' "  --changelog     Show full changelog"
            printf '%s\n' "  --location      Show current location data"
            printf '%s\n' "  --schedule      Show prayer times schedule"
            return 0
            ;;
        --version)
            printf '%s\n' "$TERMUX_CONFIG_VERSION"
            return 0
            ;;
        --updates)
            if [[ -z "$2" || "$2" == "scan" ]]; then
                _scan_updates_output
            elif [[ "$2" == "install" ]]; then
                _perform_update
            else
                printf 'Usage: --updates [scan|install]\n'
                return 1
            fi
            return 0
            ;;
        --update)
            _perform_update
            return 0
            ;;
        --reconfig)
            if [[ -f "$TERMUX_CONFIG_DIR/config.sh" ]]; then
                bash "$TERMUX_CONFIG_DIR/config.sh"
            else
                printf 'Config script not found. Run --update to fetch it.\n'
                return 1
            fi
            return 0
            ;;
        --changelog)
            _show_full_changelog
            return 0
            ;;
        --location)
            if [[ -f "$HOME/.termux/location.json" ]]; then
                cat "$HOME/.termux/location.json" | node -e "
                    const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
                    console.log('╔══════════════════════════════════════╗');
                    console.log('║        CURRENT LOCATION DATA        ║');
                    console.log('╠══════════════════════════════════════╣');
                    console.log('║ Coordinates : ' + d.latitude + ', ' + d.longitude);
                    console.log('║ Accuracy    : ' + d.accuracy + ' m');
                    if (d.address) {
                        if (d.address.road) console.log('║ Street      : ' + (d.address.house_number||'') + ' ' + d.address.road);
                        if (d.address.village || d.address.suburb) console.log('║ Village     : ' + (d.address.village || d.address.suburb));
                        if (d.address.county || d.address.district) console.log('║ District    : ' + (d.address.county || d.address.district));
                        if (d.address.city) console.log('║ City        : ' + d.address.city);
                        if (d.address.state) console.log('║ Province    : ' + d.address.state);
                        if (d.address.country) console.log('║ Country     : ' + d.address.country);
                        if (d.address.postcode) console.log('║ Postal Code : ' + d.address.postcode);
                    }
                    console.log('╚══════════════════════════════════════╝');
                " 2>/dev/null || printf 'Failed to display location.\n'
            else
                printf 'Location data not available. Please wait for automatic fetch or run schedule update.\n'
            fi
            return 0
            ;;
        --schedule)
            if [[ -f "$HOME/.termux/schedule.json" ]]; then
                cat "$HOME/.termux/schedule.json" | node -e "
                    const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
                    console.log('╔══════════════════════════════════════════════════╗');
                    console.log('║              PRAYER TIMES SCHEDULE              ║');
                    console.log('╠══════════════════════════════════════════════════╣');
                    console.log('║ Date        : ' + d.date);
                    console.log('║ Generated   : ' + d.generated_at);
                    if (d.location) {
                        const loc = d.location;
                        console.log('║ Coordinates : ' + loc.latitude + ', ' + loc.longitude);
                        if (loc.address) {
                            const addr = loc.address;
                            if (addr.road) console.log('║ Street      : ' + (addr.house_number||'') + ' ' + addr.road);
                            if (addr.village || addr.suburb) console.log('║ Village     : ' + (addr.village || addr.suburb));
                            if (addr.county || addr.district) console.log('║ District    : ' + (addr.county || addr.district));
                            if (addr.city) console.log('║ City        : ' + addr.city);
                        }
                    }
                    console.log('╠══════════════════════════════════════════════════╣');
                    const t = d.times;
                    console.log('║  Fajr    : ' + t.fajr);
                    console.log('║  Dhuhr   : ' + t.dhuhr);
                    console.log('║  Asr     : ' + t.asr);
                    console.log('║  Maghrib : ' + t.maghrib);
                    console.log('║  Isha    : ' + t.isha);
                    console.log('╚══════════════════════════════════════════════════╝');
                " 2>/dev/null || printf 'Failed to display schedule.\n'
            else
                printf 'Schedule not available yet. It will be generated automatically.\n'
            fi
            return 0
            ;;
        *)
            printf 'zsh: command not found: %s\n' "$1"
            return 127
            ;;
    esac
}

# --------------- Location & Schedule Functions ---------------

LOCATION_FILE="$HOME/.termux/location.json"
SCHEDULE_FILE="$HOME/.termux/schedule.json"
TEMP_DIR="$HOME/.termux/tmp"
mkdir -p "$TEMP_DIR"

_find_praytimes() {
    if [[ -f "$HOME/PrayTimes.js" ]]; then
        echo "$HOME/PrayTimes.js"
    elif [[ -f "$HOME/.termux/praytimes/PrayTimes.js" ]]; then
        echo "$HOME/.termux/praytimes/PrayTimes.js"
    else
        echo ""
    fi
}

_notify() {
    local title="$1"
    local message="$2"
    if command -v termux-notification >/dev/null 2>&1; then
        termux-notification --title "$title" --content "$message" --sound --priority high 2>/dev/null || true
    elif command -v termux-tts-speak >/dev/null 2>&1; then
        termux-tts-speak "$message" 2>/dev/null || true
    else
        printf '\a'
    fi
}

_fetch_location() {
    local THRESHOLD=10
    local MAX_TRIES=5
    local SLEEP_INTERVAL=1
    local lat="" lon="" acc=999
    local best_lat="" best_lon="" best_acc=999
    local address_json=""

    mkdir -p "$HOME/.termux"

    for ((i=1; i<=MAX_TRIES; i++)); do
        location_json=$(termux-location 2>/dev/null) || true
        if [[ -z "$location_json" ]]; then
            sleep "$SLEEP_INTERVAL"
            continue
        fi
        parsed=$(node -e "
            const d = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
            if (d.error) { console.log('ERROR:' + d.error); process.exit(1); }
            console.log(d.latitude + ',' + d.longitude + ',' + (d.accuracy || 999));
        " <<< "$location_json") || continue
        IFS=',' read -r lat lon acc <<< "$parsed"
        if (( $(echo "$acc < $best_acc" | bc -l) )); then
            best_lat="$lat"
            best_lon="$lon"
            best_acc="$acc"
        fi
        if (( $(echo "$acc < $THRESHOLD" | bc -l) )); then
            break
        fi
        sleep "$SLEEP_INTERVAL"
    done

    if [[ -z "$best_lat" ]]; then
        _notify "Gagal mendapatkan lokasi!" "Tidak dapat mengambil lokasi anda! Pastikan GPS anda aktif dan terkoneksi ke internet."
        return 1
    fi

    lat="$best_lat"
    lon="$best_lon"
    acc="$best_acc"

    address_json=$(curl -sS --max-time 10 "https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&addressdetails=1&accept-language=id" 2>/dev/null || echo '{}')

    local kelurahan="" kecamatan="" kota=""
    kelurahan=$(echo "$address_json" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); const a=d.address||{}; process.stdout.write(a.village||a.suburb||a.neighbourhood||a.hamlet||'')" 2>/dev/null)
    kecamatan=$(echo "$address_json" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); const a=d.address||{}; process.stdout.write(a.county||a.city_district||a.district||'')" 2>/dev/null)
    kota=$(echo "$address_json" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); const a=d.address||{}; process.stdout.write(a.city||a.town||a.municipality||'')" 2>/dev/null)

    node -e "
        const addr = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
        const loc = {
            latitude: $lat,
            longitude: $lon,
            accuracy: $acc,
            timestamp: new Date().toISOString(),
            address: addr.address || {}
        };
        require('fs').writeFileSync('$LOCATION_FILE', JSON.stringify(loc, null, 2));
    " <<< "$address_json"

    _notify "Berhasil mendapatkan lokasi" "Lokasi anda saat ini: ${kelurahan}, ${kecamatan} ${kota} dengan accuracy ${acc}m! Tabel akan segera disesuaikan."
    return 0
}

_generate_schedule() {
    local PRAYTIMES_JS=$(_find_praytimes)
    if [[ -z "$PRAYTIMES_JS" ]]; then
        _notify "Terjadi kesalahan!" "Error: PrayTimes.js tidak ditemukan."
        return 1
    fi

    if [[ ! -f "$LOCATION_FILE" ]]; then
        _notify "Terjadi kesalahan!" "Error: location.json not found."
        return 1
    fi

    mkdir -p "$HOME/.termux"

    local lat lon
    lat=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$LOCATION_FILE','utf8')).latitude)")
    lon=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$LOCATION_FILE','utf8')).longitude)")

    local offset_hours=$(date +%z | sed 's/^+//; s/^-//; s/^0*//' | awk '{print $1/100}')
    [[ $(date +%z) == -* ]] && offset_hours="-$offset_hours"

    local year=$(date +%Y) month=$(date +%m) day=$(date +%d)

    local temp_pt="$TEMP_DIR/praytimes_$$.js"
    cat "$PRAYTIMES_JS" > "$temp_pt"
    echo '; module.exports = PrayTime;' >> "$temp_pt"

    local times_json
    times_json=$(node -e "
        const PrayTime = require('$temp_pt');
        const pt = new PrayTime('MWL');
        pt.location([$lat, $lon]);
        pt.utcOffset($offset_hours);
        pt.format('24h');
        const t = pt.times([$year, $month, $day]);
        console.log(JSON.stringify({ fajr: t.fajr, dhuhr: t.dhuhr, asr: t.asr, maghrib: t.maghrib, isha: t.isha }));
    ") || {
        rm -f "$temp_pt"
        _notify "Terjadi kesalahan!" "Error: Failed to calculate prayer times."
        return 1
    }

    rm -f "$temp_pt"

    node -e "
        const loc = JSON.parse(require('fs').readFileSync('$LOCATION_FILE','utf8'));
        const times = JSON.parse('$times_json');
        const sched = {
            date: '$year-$month-$day',
            generated_at: new Date().toISOString(),
            location: loc,
            times: times
        };
        require('fs').writeFileSync('$SCHEDULE_FILE', JSON.stringify(sched, null, 2));
    "

    local kelurahan="" kecamatan="" kota=""
    kelurahan=$(node -e "const a=JSON.parse(require('fs').readFileSync('$LOCATION_FILE','utf8')).address||{}; process.stdout.write(a.village||a.suburb||a.neighbourhood||a.hamlet||'')" 2>/dev/null)
    kecamatan=$(node -e "const a=JSON.parse(require('fs').readFileSync('$LOCATION_FILE','utf8')).address||{}; process.stdout.write(a.county||a.city_district||a.district||'')" 2>/dev/null)
    kota=$(node -e "const a=JSON.parse(require('fs').readFileSync('$LOCATION_FILE','utf8')).address||{}; process.stdout.write(a.city||a.town||a.municipality||'')" 2>/dev/null)

    _notify "Jadwal sholat berhasil dibuat!" "Jadwal adzan untuk ${kelurahan}, ${kecamatan} ${kota} berhasil dibuat!"
    return 0
}

_auto_update_schedule() {
    if ! command -v termux-location >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        return 1
    fi

    local PRAYTIMES_JS=$(_find_praytimes)
    if [[ -z "$PRAYTIMES_JS" ]]; then
        return 1
    fi

    local today=$(date +%Y-%m-%d)
    local need_update=1

    if [[ -f "$SCHEDULE_FILE" ]]; then
        local saved_date=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$SCHEDULE_FILE','utf8')).date)" 2>/dev/null)
        if [[ "$saved_date" == "$today" ]]; then
            need_update=0
        fi
    fi

    if (( need_update )); then
        _fetch_location && _generate_schedule
    fi
}