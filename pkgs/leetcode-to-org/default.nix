{ python3Packages, }:

python3Packages.buildPythonApplication {
  pname = "leetcode-to-org";
  version = "git";
  src = ./.;
  propagatedBuildInputs = with python3Packages; [ requests lxml pypandoc ];
}
