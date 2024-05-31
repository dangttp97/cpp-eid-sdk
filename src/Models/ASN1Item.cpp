#include "ASN1Item.h"
#include <string>

namespace cpp_eid_sdk {

ASN1Item::ASN1Item(string line) { this->line = line; }

void ASN1Item::add_child(ASN1Item *child) {
  child->parent = this;
  this->children.push_back(child);
}

ASN1Item *ASN1Item::get_child(int idx) {
  if (idx < this->children.size()) {
    return this->children[idx];
  }

  return nullptr;
}

int ASN1Item::num_of_child() { return this->children.size(); }

} // namespace cpp_eid_sdk