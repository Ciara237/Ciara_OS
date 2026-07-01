import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/enums/opportunity_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pipeline status colors — shared by pipeline list cards and detail screen.
abstract final class OpportunityStatusColors {
  static const Color researching = Color(0xFFF59E0B);
  static const Color applying = Color(0xFF3B82F6);
  static const Color submitted = Color(0xFF8B5CF6);
  static const Color interviewing = Color(0xFF10B981);
  static const Color offer = Color(0xFF22C55E);
  static const Color rejected = Color(0xFF64748B);
  static const Color closed = Color(0xFF44474C);
}

const opportunityDocsCompleteColor = Color(0xFF10B981);
const opportunityDocsPartialColor = Color(0xFFF59E0B);

const activeOpportunityPipeline = [
  OpportunityStatus.researching,
  OpportunityStatus.applying,
  OpportunityStatus.submitted,
  OpportunityStatus.interviewing,
  OpportunityStatus.offer,
];

Color opportunityStatusColor(OpportunityStatus status) {
  return switch (status) {
    OpportunityStatus.researching => OpportunityStatusColors.researching,
    OpportunityStatus.applying => OpportunityStatusColors.applying,
    OpportunityStatus.submitted => OpportunityStatusColors.submitted,
    OpportunityStatus.interviewing => OpportunityStatusColors.interviewing,
    OpportunityStatus.offer => OpportunityStatusColors.offer,
    OpportunityStatus.rejected => OpportunityStatusColors.rejected,
    OpportunityStatus.closed => OpportunityStatusColors.closed,
  };
}

String opportunityTypeTagLabel(OpportunityType type) {
  return switch (type) {
    OpportunityType.job => 'JOB',
    OpportunityType.internship => 'INTERNSHIP',
    OpportunityType.fellowship => 'FELLOWSHIP',
    OpportunityType.program => 'PROGRAM',
    OpportunityType.masters => 'MASTERS',
  };
}

String opportunityStatusStepLabel(OpportunityStatus status) {
  return switch (status) {
    OpportunityStatus.researching => 'Researching',
    OpportunityStatus.applying => 'Applying',
    OpportunityStatus.submitted => 'Submitted',
    OpportunityStatus.interviewing => 'Interviewing',
    OpportunityStatus.offer => 'Offer',
    OpportunityStatus.rejected => 'Rejected',
    OpportunityStatus.closed => 'Closed',
  };
}

OpportunityStatus? nextOpportunityStatus(OpportunityStatus status) {
  final index = activeOpportunityPipeline.indexOf(status);
  if (index == -1 || index >= activeOpportunityPipeline.length - 1) {
    return null;
  }
  return activeOpportunityPipeline[index + 1];
}

enum OpportunityDeadlineUrgency { none, quiet, urgent, dueToday, overdue }

class OpportunityDeadlineDisplay {
  const OpportunityDeadlineDisplay({
    required this.urgency,
    this.overline,
    this.headline,
    this.quietDate,
  });

  final OpportunityDeadlineUrgency urgency;
  final String? overline;
  final String? headline;
  final String? quietDate;
}

OpportunityDeadlineDisplay deadlineDisplayFor(DateTime? deadline) {
  if (deadline == null) {
    return const OpportunityDeadlineDisplay(urgency: OpportunityDeadlineUrgency.none);
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(deadline.year, deadline.month, deadline.day);
  final daysUntil = due.difference(today).inDays;

  if (daysUntil < 0) {
    return const OpportunityDeadlineDisplay(
      urgency: OpportunityDeadlineUrgency.overdue,
      overline: 'URGENT',
      headline: 'OVERDUE',
    );
  }
  if (daysUntil == 0) {
    return const OpportunityDeadlineDisplay(
      urgency: OpportunityDeadlineUrgency.dueToday,
      overline: 'URGENT',
      headline: 'DUE TODAY',
    );
  }
  if (daysUntil <= 14) {
    return OpportunityDeadlineDisplay(
      urgency: OpportunityDeadlineUrgency.urgent,
      overline: 'URGENT',
      headline: 'DUE IN $daysUntil DAYS',
    );
  }

  return OpportunityDeadlineDisplay(
    urgency: OpportunityDeadlineUrgency.quiet,
    quietDate: DateFormat('MMM d, yyyy').format(deadline).toUpperCase(),
  );
}

String relativeTimeLabel(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) {
    return 'just now';
  }
  if (diff.inHours < 1) {
    final minutes = diff.inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 1) {
    final hours = diff.inHours;
    return '$hours hour${hours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    final days = diff.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }
  return DateFormat('MMM d, yyyy').format(dateTime);
}
