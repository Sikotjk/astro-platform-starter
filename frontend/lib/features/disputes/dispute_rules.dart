/// Mindestlänge der Begründung (spiegelt die Backend-Validierung).
const kDisputeReasonMinLength = 5;

/// Darf der aktuelle Nutzer im gegebenen Status einen Streitfall eröffnen?
///
/// Spiegelt die State Machine des Backends:
/// - HANDED_OVER / IN_TRANSIT: Sender oder Traveler
/// - DELIVERED: nur Sender
bool canOpenDispute({
  required String status,
  required bool isSender,
  required bool isTraveler,
}) {
  switch (status) {
    case 'HANDED_OVER':
    case 'IN_TRANSIT':
      return isSender || isTraveler;
    case 'DELIVERED':
      return isSender;
    default:
      return false;
  }
}
