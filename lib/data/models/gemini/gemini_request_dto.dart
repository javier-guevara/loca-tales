import 'package:json_annotation/json_annotation.dart';

part 'gemini_request_dto.g.dart';

@JsonSerializable()
class GeminiRequestDto {
  final String prompt;
  final String? systemInstruction;
  final GenerationConfig? generationConfig;

  GeminiRequestDto({
    required this.prompt,
    this.systemInstruction,
    this.generationConfig,
  });

  factory GeminiRequestDto.fromJson(Map<String, dynamic> json) =>
      _$GeminiRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiRequestDtoToJson(this);
}

@JsonSerializable()
class GenerationConfig {
  final double temperature;
  final int maxOutputTokens;
  final String? responseMimeType;

  GenerationConfig({
    required this.temperature,
    required this.maxOutputTokens,
    this.responseMimeType,
  });

  factory GenerationConfig.fromJson(Map<String, dynamic> json) =>
      _$GenerationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GenerationConfigToJson(this);
}

