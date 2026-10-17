import 'package:flutter/material.dart';

class AiChatMessage {
  final String id;
  final String sender; // 'user' or 'cfo'
  final String text;
  final DateTime timestamp;
  final List<String>? actionButtons;
  final Map<String, dynamic>? metadata;

  AiChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.actionButtons,
    this.metadata,
  });
}

class AutopilotRule {
  final String id;
  final String name;
  final String description;
  final String trigger;
  final String action;
  final bool isActive;
  final String priority; // P1-P6

  AutopilotRule({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.action,
    required this.isActive,
    required this.priority,
  });
}

class FinancialHealthScoreComponent {
  final String category;
  final double score; // 0 - 100
  final String status;
  final IconData icon;
  final Color color;

  FinancialHealthScoreComponent({
    required this.category,
    required this.score,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class DigitalTwinState {
  final double totalAssets;
  final double totalLiabilities;
  final double monthlyInflow;
  final double monthlyOutflow;
  final double emergencyRunwayMonths;
  final double financialIndependenceRatio;
  final double netWorth;

  DigitalTwinState({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.monthlyInflow,
    required this.monthlyOutflow,
    required this.emergencyRunwayMonths,
    required this.financialIndependenceRatio,
    required this.netWorth,
  });
}
