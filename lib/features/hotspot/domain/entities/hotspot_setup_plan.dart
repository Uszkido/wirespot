class HotspotSetupPlan {
  const HotspotSetupPlan({required this.steps});

  final List<HotspotSetupStep> steps;

  bool get isEmpty => steps.isEmpty;

  List<String> toLines() {
    return [
      for (final step in steps) ...[
        step.title,
        for (final attribute in step.attributes.entries)
          '  ${attribute.key}: ${attribute.value}',
      ],
    ];
  }
}

class HotspotSetupStep {
  const HotspotSetupStep({
    required this.title,
    required this.command,
    required this.attributes,
  });

  final String title;
  final String command;
  final Map<String, String> attributes;
}
