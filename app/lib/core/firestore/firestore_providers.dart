import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_providers.g.dart';

/// The one Firestore instance. Repositories take it as a constructor argument
/// so tests can hand them a `FakeFirebaseFirestore`.
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;
