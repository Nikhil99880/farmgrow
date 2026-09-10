enum ProcessStageStatus { completed, active, pending }

class ProcessStage {
  final String titleEn;
  final String titleHi;
  final ProcessStageStatus status;
  final String? subtitle;

  const ProcessStage({
    required this.titleEn,
    required this.titleHi,
    required this.status,
    this.subtitle,
  });
}

class QueueStatusModel {
  final String tokenId;
  final String currentStageEn;
  final String currentStageHi;
  final int vehiclesAhead;
  final int estimatedWaitMinutes;
  final int assignedGate;
  final String vehicleNumber;
  final List<ProcessStage> stages;

  const QueueStatusModel({
    required this.tokenId,
    required this.currentStageEn,
    required this.currentStageHi,
    required this.vehiclesAhead,
    required this.estimatedWaitMinutes,
    required this.assignedGate,
    required this.vehicleNumber,
    required this.stages,
  });
}
