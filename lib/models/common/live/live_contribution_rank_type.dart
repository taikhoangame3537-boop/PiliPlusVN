// ignore_for_file: constant_identifier_names

enum LiveContributionRankType {
  online_rank('Bảng trực tuyến', 'contribution_rank'),
  daily_rank('Bảng ngày', 'today_rank'),
  weekly_rank('Bảng tuần', 'current_week_rank'),
  monthly_rank('Bảng tháng', 'current_month_rank'),
  ;

  final String title;
  final String sw1tch;
  const LiveContributionRankType(this.title, this.sw1tch);
}
