let
  gattsu =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVJ0Kj6QE5p5rpBhz6vkmQrO6PwVZBYHi/U6v1e+lGT";
  rickert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkzbrVWajTv4IFAD8+R0TnOlH0gFJQ6puxUDehsr4a5";
  falconia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPg1kg4VtmA1EIHHeEAksC8MWM7rnFKuhnh/PsI/cQks";
  hosts = [ gattsu rickert falconia ];

  hakanssn = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKS0sE3JxoiD1RQNnOWT1giYGI4NFKk0491GMh73mwt"
    # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHO6/JVINeragZOgo2xSNuMuIUED44XohdX5wlEKQvxnVYi9okTzrit+1YWAnRafOsyEhndEgRequLqWXVJVUMGRWVAxVwKb/nQ608Y86eHyV0vGcz+T8BpsEjUDCHTjKYJrhQcyeUWRWk1HYRluB1CgdfbEbRdnCdJoGgokA4qCNZmqDNbAST5+VQMMP8yNKt45uYmbq5dFWVABKTNjf3BdyXHet1vKdCQfcy2BRQJciMIaaPuDiJBGWKZavwBMPD3/woqvPEXEpdlWL1d9LNm7t/cQpp0eVSFJC7Rca4sNo8suJDiJ2RxYHT5ZvU+Tm/meFvsUWARDsoHmZRWdA8h/ynOWUFdGy9B724UpUVXQ6YnFR6BFpv3oRiTpnaQRTVUwBTizDJFWssSsnad4uWWkUezsH+RrgihaqyhEawuapD8KkhuGueOSMol+4juddEBcMZs9UVfU5o2wTupgNxh/lNK6Y5HPPuerUAbxcOZ8D/Dtg5HAS1xeBHSJLDT8yMl4PqFJ3NRggP7SBMLe+wXa75DXH7JyuiIJRbbM2+cFmULAJ6nkFUKTDgLH8dnVx9d1Tkr5UQ/+31v1r/i5HgeYSKyPjMWCGwdI9mZUKnz41gUp9x9iaH7BGSop8oMi12lvUUg8k1jF3kZNWDE7Nwe5SnBtwOzx0ngEPbFHnYDw== anton.hakansson98@gmail.com" # This is an old key
  ];
  users = hakanssn;
in {
  "secrets/passwords/users/hakanssn.age".publicKeys = hosts ++ users;
  "secrets/passwords/users/root.age".publicKeys = hosts ++ users;

  "secrets/authorized_keys/hakanssn.age".publicKeys = hosts ++ users;
  "secrets/authorized_keys/root.age".publicKeys = hosts ++ users;
}
