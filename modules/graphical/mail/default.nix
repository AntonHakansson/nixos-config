{ config, lib, pkgs, ... }:

let
  passwordScript = pkgs.writeShellScript "get_mail_password" ''
    ${pkgs.pass}/bin/pass show "$@" | ${pkgs.coreutils}/bin/head -n1 | ${pkgs.coreutils}/bin/tr -d "\n"'';
  notifyScript = name:
    pkgs.writeShellScript "notify_${name}_mail" ''
      unseen_count=$(${pkgs.mblaze}/bin/mlist -N $(${pkgs.mblaze}/bin/mdirs ~/mail) | ${pkgs.coreutils}/bin/wc -l)
      ${pkgs.libnotify}/bin/notify-send -t 5000 "New ${name} mail arrived ($unseen_count)"
    '';
in
{
  options.hakanssn.graphical.mail.enable = lib.mkEnableOption "mail";

  config = lib.mkIf config.hakanssn.graphical.mail.enable {
    hakanssn.core.zfs.homeDataLinks = [ "mail" ];

    home-manager.users.hakanssn = { ... }: {
      accounts.email = {
        maildirBasePath = "mail";
        accounts = {
          personal = {
            primary = true;
            address = "anton@hakanssn.com";
            realName = "Anton Håkansson";
            userName = "anton@hakanssn.com";
            passwordCommand = "${passwordScript} mail/personal";

            imap = {
              host = "mail.hakanssn.com";
              port = 993;
              tls.enable = true;
            };
            mbsync = {
              enable = true;
              create = "both";
              expunge = "both";
              remove = "both";
              flatten = ".";
            };
            msmtp.enable = true;
            smtp = {
              host = "mail.hakanssn.com";
              port = 587;
              tls = {
                enable = true;
                useStartTls = true;
              };
            };
            notmuch.enable = true;
          };
          gmail = {
            address = "anton.hakansson98@gmail.com";
            userName = "anton.hakansson98@gmail.com";
            realName = "Anton Håkansson";
            passwordCommand = "${passwordScript} mail/mbsync_gmail";
            imap.host = "imap.gmail.com";
            smtp.host = "smtp.gmail.com";
            mbsync = {
              enable = true;
              create = "both";
              expunge = "both";
              patterns = [ "*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail" "[Gmail]/Trash" "[Gmail]/Archive" "[Gmail]/Drafts" ];
              extraConfig = {
                channel = {
                  Sync = "All";
                };
                account = {
                  Timeout = 120;
                  PipelineDepth = 1;
                };
              };
            };
            msmtp.enable = true;
            notmuch.enable = true;
            mujmap.enable = true; # gmail for notmuch
          };
        };
      };
      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        mu.enable = true;
        notmuch.enable = {
          enable = true;
          hooks = {
            preNew = "mbsync --all";
          };
        };
      };
      services = {
        imapnotify.enable = true;
        mbsync.enable = true;
      };
    };
  };
}
