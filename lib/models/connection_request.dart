enum RequestStatus { pending, accepted, rejected, expired }

class ConnectionRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String intentId;
  final String message;
  final DateTime timestamp;
  final RequestStatus status;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.intentId,
    required this.message,
    required this.timestamp,
    this.status = RequestStatus.pending,
  });
}
