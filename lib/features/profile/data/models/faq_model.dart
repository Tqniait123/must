class FAQModel {
  final int id;
  final String question;
  final String answer;

  FAQModel({required this.id, required this.question, required this.answer});

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(id: json['id'] as int, question: json['question'] as String, answer: json['answer'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer};
  }
}
