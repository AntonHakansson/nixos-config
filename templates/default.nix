rec {
  hakanssn-project = {
    path = ./hakanssn-project;
    description =
      "A flake-utils, devshell ready template to quickstart a new project";
  };
  default = hakanssn-project;
}
