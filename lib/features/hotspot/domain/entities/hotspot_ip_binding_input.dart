class HotspotIpBindingInput {
  const HotspotIpBindingInput({
    this.address,
    this.macAddress,
    this.server,
    this.type = 'bypassed',
    this.comment,
  });

  final String? address;
  final String? macAddress;
  final String? server;
  final String type;
  final String? comment;

  Map<String, String> toRouterOsAttributes() {
    return {
      if (address != null && address!.isNotEmpty) 'address': address!,
      if (macAddress != null && macAddress!.isNotEmpty)
        'mac-address': macAddress!,
      if (server != null && server!.isNotEmpty) 'server': server!,
      'type': type,
      if (comment != null && comment!.isNotEmpty) 'comment': comment!,
    };
  }
}
