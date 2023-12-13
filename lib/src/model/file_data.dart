class FileData {
  final String fileName;
  final bool isSuccessful;
  final int percentage;

  FileData({
    required this.fileName,
    required this.isSuccessful,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'isSuccessful': isSuccessful,
      'percentage': percentage,
    };
  }

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      fileName: json['fileName'],
      isSuccessful: json['isSuccessful'],
      percentage: json['percentage'],
    );
  }
}
