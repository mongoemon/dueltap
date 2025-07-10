// PvEService: Handles AI battles, campaign
import 'ai_csv_loader.dart';

class PvEService {
  List<AIConfig>? _aiConfigs;

  Future<void> loadAIConfigs() async {
    _aiConfigs = await AIConfig.loadAll();
  }

  AIConfig? getAIConfig(String character) {
    if (_aiConfigs == null) return null;
    for (final a in _aiConfigs!) {
      if (a.character == character) {
        return a;
      }
    }
    return null;
  }

  Future<void> startCampaignBattle(String opponentName) async {
    // Example: Use AIConfig for opponent
    final ai = getAIConfig(opponentName);
    if (ai != null) {
      // Use ai.aggression, ai.skillUsageFreq, ai.targetPriority in AI logic
      // e.g., decide action based on aggression/skillUsageFreq
      // TODO: Implement AI battle logic using these parameters
    }
  }

  Future<void> syncProgress() async {
    // TODO: Implement offline/online sync
  }
}
