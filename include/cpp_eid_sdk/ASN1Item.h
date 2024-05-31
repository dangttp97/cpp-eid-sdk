#include <openssl/asn1.h>
#include <string>
#include <vector>

using namespace std;

namespace cpp_eid_sdk {
class ASN1Item {
private:
  vector<ASN1Item *> children;

public:
  int position;
  int depth;
  int headerLength;
  int length;
  string itemType;
  string type;
  string value;
  string line;
  ASN1Item *parent;

  ASN1Item(string line);

  void add_child(ASN1Item *child);
  ASN1Item *get_child(int idx);
  int num_of_child();
};
} // namespace cpp_eid_sdk