const double EPOCHC = 1825029.5;
const double EPOCHG = 1721425.5;
const List<int> HAVE_30_DAYS = [4, 6, 9, 11];
const int INTERCALATION_CYCLE_YEARS = 400;
const int LEAP_SUPPRESSION_YEARS = 100;
const int LEAP_CYCLE_YEARS = 4;
const int YEAR_DAYS = 365;

double toJd(int year, int month, int day) {
  return day + (month - 1) * 30 + (year - 1) * 365 + (year ~/ 4) + EPOCHC - 1;
}

List<int> fromJd(double jdc) {
  double cdc = (jdc.floor() + 0.5 - EPOCHC);
  int year = ((cdc - ((cdc + 366).floor() ~/ 1461)) ~/ 365) + 1;

  double yday = jdc - toJd(year, 1, 1);

  int month = (yday ~/ 30) + 1;
  int day = (yday - (month - 1) * 30 + 1).toInt();

  return [year, month, day];
}

double gregToJd(int year, int month, int day) {
  legalDate(year, month, day);

  int leapAdj;
  if (month <= 2) {
    leapAdj = 0;
  } else if (isLeap(year)) {
    leapAdj = -1;
  } else {
    leapAdj = -2;
  }

  return EPOCHG -
      1 +
      (YEAR_DAYS * (year - 1)) +
      ((year - 1) ~/ LEAP_CYCLE_YEARS) +
      (-((year - 1) ~/ LEAP_SUPPRESSION_YEARS)) +
      ((year - 1) ~/ INTERCALATION_CYCLE_YEARS) +
      (((367 * month - 362) / 12).floor() + leapAdj + day);
}

bool isLeap(int year) {
  return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}

void legalDate(int year, int month, int day) {
  int daysInMonth;
  if (month == 2) {
    daysInMonth = isLeap(year) ? 29 : 28;
  } else if (HAVE_30_DAYS.contains(month)) {
    daysInMonth = 30;
  } else {
    daysInMonth = 31;
  }

  if (day <= 0 || day > daysInMonth) {
    throw ArgumentError("Month $month doesn't have a day $day");
  }
}

List<int> getCopticDate() {
  DateTime now = DateTime.now();
  double jdc = gregToJd(now.year, now.month, now.day);
  return fromJd(jdc);
}

void main() {
  List<int> copticDate = getCopticDate();
  print(
    "Coptic Date: Year ${copticDate[0]}, Month ${copticDate[1]}, Day ${copticDate[2]}",
  );
}
