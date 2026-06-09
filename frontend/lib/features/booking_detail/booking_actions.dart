/// Mögliche Nutzeraktionen auf einer Buchung. Die Verfügbarkeit wird
/// client-seitig vorgefiltert; der Backend-State-Machine bleibt maßgeblich.
enum BookingAction {
  accept,
  reject,
  pay,
  acceptTerms,
  handover,
  transit,
  delivered,
  confirm,
  cancel,
}

extension BookingActionPath on BookingAction {
  /// Endpunkt-Suffix: `POST /bookings/:id/<path>`
  String get path => switch (this) {
    BookingAction.accept => 'accept',
    BookingAction.reject => 'reject',
    BookingAction.pay => 'escrow',
    BookingAction.acceptTerms => 'accept-terms',
    BookingAction.handover => 'handover',
    BookingAction.transit => 'transit',
    BookingAction.delivered => 'delivered',
    BookingAction.confirm => 'confirm',
    BookingAction.cancel => 'cancel',
  };
}

/// Welche Aktionen darf der aktuelle Nutzer im gegebenen Status auslösen?
List<BookingAction> availableBookingActions({
  required String status,
  required bool isSender,
  required bool isTraveler,
  required bool termsAccepted,
}) {
  switch (status) {
    case 'REQUESTED':
      if (isTraveler) return const [BookingAction.accept, BookingAction.reject];
      if (isSender) return const [BookingAction.cancel];
      return const [];
    case 'ACCEPTED':
      if (isSender) return const [BookingAction.pay, BookingAction.cancel];
      if (isTraveler) return const [BookingAction.cancel];
      return const [];
    case 'PAID':
      if (!termsAccepted) {
        return isTraveler ? const [BookingAction.acceptTerms] : const [];
      }
      return const [BookingAction.handover]; // Sender oder Traveler
    case 'HANDED_OVER':
      return isTraveler ? const [BookingAction.transit] : const [];
    case 'IN_TRANSIT':
      return isTraveler ? const [BookingAction.delivered] : const [];
    case 'DELIVERED':
      return isSender ? const [BookingAction.confirm] : const [];
    default:
      return const [];
  }
}
