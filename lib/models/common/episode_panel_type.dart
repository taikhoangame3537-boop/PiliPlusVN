enum EpisodeType {
  part('Phần'),
  season('Bộ sưu tập'),
  pgc('Các tập'),
  ;

  final String title;
  const EpisodeType(this.title);
}
