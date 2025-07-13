class TermsAndConditionsModel {
  final String content;

  TermsAndConditionsModel({required this.content});

  factory TermsAndConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsModel(content: json['content'] as String? ?? '<p>Terms & Conditions Content</p>');
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }

  TermsAndConditionsModel copyWith({String? content}) {
    return TermsAndConditionsModel(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TermsAndConditionsModel && other.content == content;
  }

  @override
  int get hashCode => content.hashCode;
}
