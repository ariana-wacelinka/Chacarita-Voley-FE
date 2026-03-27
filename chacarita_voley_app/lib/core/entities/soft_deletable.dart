mixin SoftDeletable {
  bool get isDeleted;

  SoftDeletable copyWithIsDeleted(bool value);
}
