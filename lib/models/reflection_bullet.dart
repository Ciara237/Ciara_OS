/// Rich-text segment for system reflection bullets.
class ReflectionSegment {
  const ReflectionSegment(
    this.text, {
    this.bold = false,
    this.italic = false,
  });

  final String text;
  final bool bold;
  final bool italic;
}

class ReflectionBullet {
  const ReflectionBullet(this.segments);

  final List<ReflectionSegment> segments;
}
