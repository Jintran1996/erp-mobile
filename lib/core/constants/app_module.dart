enum AppModule {
  account('account'),
  expense('expense'),
  finance('finance'),
  core('core'),
  proposal('proposal');

  const AppModule(this.value);

  final String value;
}
