enum Karma {
  comment(1),
  textPost(2),
  imagePost(3),
  linkPost(3),
  awardPost(4),
  deletePost(-1);

  final int karma;
  const Karma(this.karma);
}
