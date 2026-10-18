import 'package:equatable/equatable.dart';

class Cell extends Equatable {
  final String? ownerId;
  final int orbCount;

  const Cell({this.ownerId, this.orbCount = 0});

  Cell copyWith({String? Function()? ownerId, int? orbCount}) {
    return Cell(
      ownerId: ownerId != null ? ownerId() : this.ownerId,
      orbCount: orbCount ?? this.orbCount,
    );
  }

  @override
  List<Object?> get props => [ownerId, orbCount];

  Map<String, dynamic> toJson() => {'ownerId': ownerId, 'orbCount': orbCount};

  factory Cell.fromJson(Map<String, dynamic> json) => Cell(
    ownerId: json['ownerId'] as String?,
    orbCount: json['orbCount'] as int? ?? 0,
  );
}
