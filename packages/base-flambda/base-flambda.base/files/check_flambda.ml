#use "topfind";;
#require "compiler-libs.bytecomp";;
if Config.flambda then
  exit 0
else begin
  output_string stderr
    ("The current OCaml switch does not support Flambda, so this package cannot be installed.\n" ^
     "Try switching to a configuration with Flambda support, e.g.\n" ^
     "   opam switch 4.04.0+flambda\n");
  exit 1
end
