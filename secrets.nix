let
  gattsu =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVJ0Kj6QE5p5rpBhz6vkmQrO6PwVZBYHi/U6v1e+lGT";
  rickert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkzbrVWajTv4IFAD8+R0TnOlH0gFJQ6puxUDehsr4a5";
  falconia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg1kg4VtmA1EIHHeEAksC8MWM7rnFKuhnh/PsI/cQks";
  hosts = [ gattsu rickert falconia ];

  hakanssn = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKS0sE3JxoiD1RQNnOWT1giYGI4NFKk0491GMh73mwt"
  ];
  users = hakanssn;
in
{
  "secrets/passwords/users/hakanssn.age".publicKeys = hosts ++ users;
  "secrets/passwords/users/root.age".publicKeys = hosts ++ users;

  "secrets/authorized_keys/hakanssn.age".publicKeys = hosts ++ users;
  "secrets/authorized_keys/root.age".publicKeys = hosts ++ users;

  "secrets/passwords/network.age".publicKeys = hosts ++ users;

  "secrets/passwords/services/mail/anton_at_hakanssn.com.age".publicKeys = [ falconia ] ++ users;
  "secrets/passwords/services/mail/webmaster_at_hakanssn.com.age".publicKeys = [ falconia ] ++ users;
  "secrets/passwords/services/mail/postbot_at_hakanssn.com.age".publicKeys = [ falconia ] ++ users;
  "secrets/passwords/services/mail/ssmtp-webmaster-pass.age".publicKeys = hosts ++ users;

  "secrets/passwords/services/nextcloud-admin.age".publicKeys = [ falconia ] ++ users;

  "secrets/passwords/services/syncthing-basic-auth.age".publicKeys = [ falconia ] ++ users;

  "secrets/passwords/services/github-notification-token.age".publicKeys = hosts ++ users;
}
