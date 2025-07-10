import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart generate_feature.dart <feature_name>');
    exit(1);
  }

  String featureName = args[0].toLowerCase();
  String featureNameCapitalized = _capitalize(featureName);

  // Create directory structure
  String basePath = 'lib/features/$featureName';

  // Create directories
  Directory('$basePath/data/datasources').createSync(recursive: true);
  Directory('$basePath/data/repositories').createSync(recursive: true);
  Directory('$basePath/presentation/cubit').createSync(recursive: true);
  Directory('$basePath/presentation/pages').createSync(recursive: true);

  // Generate files
  _generateRemoteDataSource(basePath, featureName, featureNameCapitalized);
  _generateRepository(basePath, featureName, featureNameCapitalized);
  _generateCubit(basePath, featureName, featureNameCapitalized);
  _generateStates(basePath, featureName, featureNameCapitalized);

  print('✅ Feature "$featureName" generated successfully!');
  print('📁 Files created:');
  print('   - $basePath/data/datasources/${featureName}_remote_data_source.dart');
  print('   - $basePath/data/repositories/${featureName}_repo.dart');
  print('   - $basePath/presentation/cubit/${featureName}_cubit.dart');
  print('   - $basePath/presentation/cubit/${featureName}_state.dart');
}

String _capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1);
}

void _generateRemoteDataSource(String basePath, String featureName, String featureNameCapitalized) {
  String content = '''
import '../../../core/network/dio_client.dart';

abstract class ${featureNameCapitalized}RemoteDataSource {
  // Add your remote data source methods here
}

class ${featureNameCapitalized}RemoteDataSourceImpl implements ${featureNameCapitalized}RemoteDataSource {
  final DioClient dioClient;

  ${featureNameCapitalized}RemoteDataSourceImpl(this.dioClient);

  @override
  // Implement your methods here
}
''';

  File('$basePath/data/datasources/${featureName}_remote_data_source.dart').writeAsStringSync(content);
}

void _generateRepository(String basePath, String featureName, String featureNameCapitalized) {
  String content = '''
import '../../../core/preferences/must_invest_preferences.dart';
import '../datasources/${featureName}_remote_data_source.dart';

abstract class ${featureNameCapitalized}Repo {
  // Add your repository methods here
}

class ${featureNameCapitalized}RepoImpl implements ${featureNameCapitalized}Repo {
  final ${featureNameCapitalized}RemoteDataSource _remoteDataSource;
  final MustInvestPreferences _localDataSource;

  ${featureNameCapitalized}RepoImpl(this._remoteDataSource, this._localDataSource);

  @override
  // Implement your methods here
}
''';

  File('$basePath/data/repositories/${featureName}_repo.dart').writeAsStringSync(content);
}

void _generateCubit(String basePath, String featureName, String featureNameCapitalized) {
  String content = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/${featureName}_repo.dart';
import '${featureName}_state.dart';

class ${featureNameCapitalized}Cubit extends Cubit<${featureNameCapitalized}State> {
  final ${featureNameCapitalized}Repo _repository;

  ${featureNameCapitalized}Cubit(this._repository) : super(${featureNameCapitalized}Initial());

  // Add your cubit methods here
}
''';

  File('$basePath/presentation/cubit/${featureName}_cubit.dart').writeAsStringSync(content);
}

void _generateStates(String basePath, String featureName, String featureNameCapitalized) {
  String content = '''
import 'package:equatable/equatable.dart';

abstract class ${featureNameCapitalized}State extends Equatable {
  const ${featureNameCapitalized}State();

  @override
  List<Object> get props => [];
}

class ${featureNameCapitalized}Initial extends ${featureNameCapitalized}State {}

class ${featureNameCapitalized}Loading extends ${featureNameCapitalized}State {}

class ${featureNameCapitalized}Success extends ${featureNameCapitalized}State {
  final dynamic data;

  const ${featureNameCapitalized}Success(this.data);

  @override
  List<Object> get props => [data];
}

class ${featureNameCapitalized}Error extends ${featureNameCapitalized}State {
  final String message;

  const ${featureNameCapitalized}Error(this.message);

  @override
  List<Object> get props => [message];
}
''';

  File('$basePath/presentation/cubit/${featureName}_state.dart').writeAsStringSync(content);
}
