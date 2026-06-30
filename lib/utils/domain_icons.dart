import 'package:ciaraos/models/enums/domain.dart';
import 'package:flutter/material.dart';

/// Domain icon mapping — shared with onboarding and Today screen.
IconData domainIcon(Domain domain) {
  return switch (domain) {
    Domain.engineering => Icons.terminal,
    Domain.security => Icons.security,
    Domain.opportunities => Icons.trending_up,
    Domain.builder => Icons.construction,
    Domain.other => Icons.more_horiz,
  };
}

String domainLabel(Domain domain) {
  return switch (domain) {
    Domain.engineering => 'ENGINEERING',
    Domain.security => 'SECURITY',
    Domain.opportunities => 'OPPORTUNITIES',
    Domain.builder => 'BUILDER',
    Domain.other => 'OTHER',
  };
}

String domainShortLabel(Domain domain) {
  return switch (domain) {
    Domain.engineering => 'ENG',
    Domain.security => 'SEC',
    Domain.opportunities => 'OPP',
    Domain.builder => 'BLD',
    Domain.other => 'OTH',
  };
}
