{ config, lib, pkgs, ... }:

{
  config = let
    passwordScript = pkgs.writeShellScript "get_mail_password"
      ''${pkgs.pass}/bin/pass show "$@" | head -n1 | tr -d "\n"'';
    notifyScript = name:
      pkgs.writeShellScript "notify_${name}_mail" ''
        unseen_count=$(${pkgs.mblaze}/bin/mlist -N ~/mail/*/Inbox | wc -l)
        ${pkgs.libnotify}/bin/notify-send -t 5000 "New ${name} mail arrived ($unseen_count)"
      '';
  in {
    asdf.core.zfs.homeDataLinks = [ "mail" ];
    asdf.core.zfs.homeCacheLinks = [ ".cache/mu" ];

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
            imapnotify = {
              enable = true;
              boxes = [ "Inbox" ];
              onNotify = "${pkgs.isync}/bin/mbsync personal:Inbox";
              onNotifyPost = "mu index && ${notifyScript "personal"}";
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
            mu.enable = true;
          };
        };
      };
      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        mu.enable = true;
      };
      services = {
        imapnotify.enable = true;
        mbsync.enable = true;
      };
    };
  };
}
