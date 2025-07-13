class PrivacyPolicyModel {
  final String content;

  PrivacyPolicyModel({required this.content});

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(content: json['content'] as String? ?? '<p>Terms & Conditions Content</p>');
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }

  PrivacyPolicyModel copyWith({String? content}) {
    return PrivacyPolicyModel(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrivacyPolicyModel && other.content == content;
  }

  @override
  int get hashCode => content.hashCode;
}
