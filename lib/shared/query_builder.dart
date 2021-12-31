import 'package:cloud_firestore/cloud_firestore.dart';

typedef QueryBuilder<T> = Query<T> Function(Query<T> query);
