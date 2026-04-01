abstract interface class DeepLinkSource {
  const DeepLinkSource();

  Stream<Uri> get uriLinkStream;

  Future<Uri?> getInitialLink();
}
