enum DATA_GROUP_TYPE {
  COM,
  DG1,
  DG2,
  DG3,
  DG10,
  DG11,
  DG12,
  DG13,
  DG14,
  DG15,
  SOD
};

class BaseDataGroup {
public:
  DATA_GROUP_TYPE type;
  BaseDataGroup();
  ~BaseDataGroup();
}; // namespace cpp_eid_sdkclass BaseDataGroup
