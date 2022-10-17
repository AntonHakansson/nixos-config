rec {
  hakanssn-project = {
    path = ./hakanssn-project;
    description =
      "A flake-utils, devshell ready template to quickstart a new project";
  };
  c-project = {
    path = ./c;
    description =
      "A Makefile c/c++ template";
  };
  default = hakanssn-project;
}
