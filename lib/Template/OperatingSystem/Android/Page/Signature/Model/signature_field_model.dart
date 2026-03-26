import '../../../../../Utils/Constant/enum.dart';

class SignatureFieldModel {
  final String fieldId;
  final SignatureFieldType type;
  final int page;
  final double x;
  final double y;
  final double width;
  final double height;
  final bool isRequired;
  final String? value;

  SignatureFieldModel({
    required this.fieldId,
    required this.type,
    required this.page,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.isRequired = true,
    this.value,
  });

  factory SignatureFieldModel.fromMap(Map<String, dynamic> data) {
    return SignatureFieldModel(
      fieldId: data['fieldId'] ?? '',
      type: SignatureFieldType.values.firstWhere(
        (t) => t.name == (data['type'] ?? 'signature'),
        orElse: () => SignatureFieldType.signature,
      ),
      page: data['page'] ?? 0,
      x: (data['x'] ?? 0).toDouble(),
      y: (data['y'] ?? 0).toDouble(),
      width: (data['width'] ?? 24).toDouble(),
      height: (data['height'] ?? 24).toDouble(),
      isRequired: data['isRequired'] ?? true,
      value: data['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldId': fieldId,
      'type': type.name,
      'page': page,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'isRequired': isRequired,
      'value': value,
    };
  }

  SignatureFieldModel copyWith({
    SignatureFieldType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    bool? isRequired,
    String? value,
  }) {
    return SignatureFieldModel(
      fieldId: fieldId,
      type: type ?? this.type,
      page: page,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      isRequired: isRequired ?? this.isRequired,
      value: value ?? this.value,
    );
  }
}
