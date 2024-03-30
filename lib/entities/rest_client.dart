abstract interface class RestClient {
  const RestClient();

  Future<String> getImageFromOpenAiAsFuture(String barcode);
}
