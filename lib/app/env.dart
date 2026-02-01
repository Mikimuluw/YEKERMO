enum Environment { dev, stage, prod }

class AppEnv {
  static Environment get current {
    const String raw = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (raw) {
      case 'prod':
        return Environment.prod;
      case 'stage':
        return Environment.stage;
      default:
        return Environment.dev;
    }
  }

  static String get apiBaseUrl {
    switch (current) {
      case Environment.prod:
        return 'https://api.prod';
      case Environment.stage:
        return 'https://stage.api.local';
      case Environment.dev:
        return 'https://dev.api.local';
    }
  }
}
