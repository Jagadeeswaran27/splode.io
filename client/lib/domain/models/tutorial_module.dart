/// Defines the training/tutorial modules available in Splode in sequential progression order.
enum TutorialModule {
  basics(
    id: 'basics',
    moduleNumber: '01',
    category: 'Foundation',
    title: 'The Basics',
    description:
        'Place orbs, reach critical mass, and trigger explosive bursts.',
    stepCount: 4,
    bpReward: 10,
  ),
  capturing(
    id: 'capturing',
    moduleNumber: '02',
    category: 'Tactics',
    title: 'Capturing',
    description:
        'Explode into adjacent enemy cells to convert and command them.',
    stepCount: 7,
    bpReward: 10,
  ),
  chainReactions(
    id: 'chain_reactions',
    moduleNumber: '03',
    category: 'Mastery',
    title: 'Chain Reactions',
    description:
        'Trigger multi-wave domino cascades like S-Curves and Whirlpools.',
    stepCount: 7,
    bpReward: 15,
  ),
  edgesAndCorners(
    id: 'edges_and_corners',
    moduleNumber: '04',
    category: 'Strategy',
    title: 'Edges and Corners',
    description:
        'Fortify fast 2-orb corners and flank through outer edges.',
    stepCount: 6,
    bpReward: 15,
  );

  final String id;
  final String moduleNumber;
  final String category;
  final String title;
  final String description;
  final int stepCount;
  final int bpReward;

  const TutorialModule({
    required this.id,
    required this.moduleNumber,
    required this.category,
    required this.title,
    required this.description,
    required this.stepCount,
    required this.bpReward,
  });

  /// Total BP available across all tutorial modules.
  static int get totalBounty =>
      TutorialModule.values.fold(0, (sum, m) => sum + m.bpReward);

  /// Resolves a [TutorialModule] by its string [id], or `null` if [id] is not recognized.
  static TutorialModule? tryFromId(String? id) {
    if (id == null) return null;
    for (final module in TutorialModule.values) {
      if (module.id == id) return module;
    }
    return null;
  }

  /// Resolves a [TutorialModule] by its string [id], defaulting to [TutorialModule.basics].
  static TutorialModule fromId(String? id) {
    return tryFromId(id) ?? TutorialModule.basics;
  }

  /// Returns the next module in the sequence, or `null` if this is the final module.
  TutorialModule? get nextModule {
    final index = TutorialModule.values.indexOf(this);
    if (index >= 0 && index < TutorialModule.values.length - 1) {
      return TutorialModule.values[index + 1];
    }
    return null;
  }

  /// Returns the previous module in the sequence, or `null` if this is the first module.
  TutorialModule? get previousModule {
    final index = TutorialModule.values.indexOf(this);
    if (index > 0) {
      return TutorialModule.values[index - 1];
    }
    return null;
  }
}

