rec {
  hakanssn-project = {
    path = ./hakanssn-project;
    description =
      "A flake-utils, devshell ready template to quickstart a new project";
  };
  bare = {
    path = ./bare;
    description = "A minimal flakes project";
  };
  c-project = {
    path = ./c;
    description =
      "A Makefile c/c++ template";
  };
  zig = {
    path = ./zig;
    description =
      "A zig template";
  };
  default = hakanssn-project;
}
