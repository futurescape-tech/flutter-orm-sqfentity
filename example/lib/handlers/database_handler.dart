
import 'package:sqfentity_example/model/model.dart';

class DatabaseHandler {

  DatabaseHandler._() : database = MyDbModel();

  late final MyDbModel database;
  static final DatabaseHandler instance = DatabaseHandler._();
}