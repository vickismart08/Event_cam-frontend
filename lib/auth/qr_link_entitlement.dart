import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-user flags in Firestore `users/{uid}` (merge writes).
///
/// Firestore rules must allow authenticated users to read/write their own doc, e.g.:
/// `match /users/{userId} { allow read, write: if request.auth.uid == userId; }`
class QrLinkEntitlement {
  const QrLinkEntitlement({
    required this.freeTrialConsumed,
    required this.paymentConfirmed,
  });

  final bool freeTrialConsumed;
  final bool paymentConfirmed;

  /// After the one free clean QR, show a watermark until [paymentConfirmed].
  bool get shouldWatermark =>
      freeTrialConsumed && !paymentConfirmed;
}

class QrLinkEntitlementService {
  QrLinkEntitlementService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<QrLinkEntitlement> fetch(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    final d = snap.data();
    if (d == null) {
      return const QrLinkEntitlement(freeTrialConsumed: false, paymentConfirmed: false);
    }
    return QrLinkEntitlement(
      freeTrialConsumed: d['qrLinkFreeTrialConsumed'] == true,
      paymentConfirmed: d['qrLinkPaymentConfirmed'] == true,
    );
  }

  /// Call once after the user sees their **one free** clean QR (first generation only).
  static Future<void> markFreeTrialConsumed(String uid) async {
    await _db.collection('users').doc(uid).set(
      {
        'qrLinkFreeTrialConsumed': true,
        'qrLinkUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// When payment is confirmed (webhook / manual / future in-app purchase), set this to true.
  static Future<void> setPaymentConfirmed(String uid, {required bool value}) async {
    await _db.collection('users').doc(uid).set(
      {
        'qrLinkPaymentConfirmed': value,
        'qrLinkUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
