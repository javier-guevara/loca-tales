import 'package:json_annotation/json_annotation.dart';

part 'gemini_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class GeminiResponseDto {
  final List<Candidate>? candidates;
  final UsageMetadata? usageMetadata;

  GeminiResponseDto({
    this.candidates,
    this.usageMetadata,
  });

  factory GeminiResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GeminiResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class Candidate {
  final Content? content;
  final String? finishReason;

  Candidate({
    this.content,
    this.finishReason,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      _$CandidateFromJson(json);
}

@JsonSerializable(createToJson: false)
class Content {
  final List<Part>? parts;
  final String? role;

  Content({
    this.parts,
    this.role,
  });

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
}

@JsonSerializable(createToJson: false)
class Part {
  final String? text;

  Part({
    this.text,
  });

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);
}

@JsonSerializable(createToJson: false)
class UsageMetadata {
  final int? promptTokenCount;
  final int? candidatesTokenCount;
  final int? totalTokenCount;

  UsageMetadata({
    this.promptTokenCount,
    this.candidatesTokenCount,
    this.totalTokenCount,
  });

  factory UsageMetadata.fromJson(Map<String, dynamic> json) =>
      _$UsageMetadataFromJson(json);
}

