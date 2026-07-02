import 'package:ciaraos/models/executive_brief.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final executiveBriefProvider =
    StateNotifierProvider<ExecutiveBriefNotifier, AsyncValue<ExecutiveBrief?>>(
  (ref) {
    return ExecutiveBriefNotifier(ref.read(aiServiceProvider));
  },
);

class ExecutiveBriefNotifier
    extends StateNotifier<AsyncValue<ExecutiveBrief?>> {
  ExecutiveBriefNotifier(this._aiService)
      : super(const AsyncValue.data(null));

  final AiService _aiService;

  Future<void> fetchBrief(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    final brief = await _aiService.fetchBrief(payload);
    state = AsyncValue.data(brief);
  }

  void clear() => state = const AsyncValue.data(null);
}
