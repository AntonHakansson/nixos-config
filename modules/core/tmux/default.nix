{ pkgs, ... }:

let
  base = home: {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      baseIndex = 1; # starting index for windows and panes
      shortcut = "c"; # C-c
      clock24 = true;
      extraConfig = ''
        set  -g mouse on
        bind C-c send-prefix
        bind r source-file ${home}/.config/tmux/tmux.conf \; display-message "  Config reloaded..".

        set -g @open-editor 'C-e'

        ### Keybindings
        bind c new-window -c "#{pane_current_path}"
        bind v split-window -h -c "#{pane_current_path}"
        bind s split-window -v -c "#{pane_current_path}"

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind o resize-pane -Z
        bind S choose-session
        bind W choose-window
        bind / choose-session
        bind . choose-window

        is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?x?)(diff)?$"'
        bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
        bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
        bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
        bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
        bind -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
        bind C-w last-pane
        bind C-n next-window
        bind C-p previous-window

        ### Copy mode
        bind Enter copy-mode # enter copy mode
        bind b list-buffers  # list paster buffers
        bind B choose-buffer # choose which buffer to paste from
        bind p paste-buffer  # paste from the top paste buffer

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi Escape send-keys -X cancel
        bind -T copy-mode-vi C-g send-keys -X cancel
        bind -T copy-mode-vi H send-keys -X start-of-line
        bind -T copy-mode-vi L send-keys -X end-of-line
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/clipcopy"
      '';
    };
  };
in
{
  home-manager.users.hakanssn = { ... }: base "/home/hakanssn";
  home-manager.users.root = { ... }: base "/root";
}
