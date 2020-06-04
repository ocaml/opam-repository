#include <snappy.h>
#include <iostream>
using namespace std;

int main() {
  string input = "Hello World, Hello World, Hello World!";
  string compressed;
  snappy::Compress(input.data(), input.size(), &compressed);
  cout << input.size() << " => " << compressed.size() << endl;
  string output;
  snappy::Uncompress(compressed.data(), compressed.size(), &output);
  cout << output << endl;
  return 0;
}
