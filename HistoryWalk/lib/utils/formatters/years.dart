import 'package:historywalk/features/routes/models/time_period.dart';

String formatYear(int year) {
  if (year < 0) return "${year.abs()} BCE";
  return "$year CE";
}
String formatPeriod(TimePeriod p) {
  return "${formatYear(p.startYear)} – ${formatYear(p.endYear)}";
}