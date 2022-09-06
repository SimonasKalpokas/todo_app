// could implement DateTime
class DateTimeWrapper {
  DateTime dateTime;

  DateTimeWrapper(this.dateTime);

  void add(Duration duration) {
    dateTime = dateTime.add(duration);
  }

  void set(DateTime dateTime) {
    this.dateTime = dateTime;
  }
}
