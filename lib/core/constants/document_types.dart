enum DocumentType {
  userAvatar('user-avatar'),

  invoice('invoice'),
  expensePayment('expense-payment'),
  outgoingPayment('outgoing-payment'),
  incomingPayment('incoming-payment'),
  outgoingAttachment('outgoing-attachment'),
  advancePayment('advance-payment'),
  advanceSettlement('advance-settlement'),
  paymentAttachment('payment-attachment'),
  budgetPlan('budget-plan'),
  budgetPlanAdjustment('budget-plan-adjustment'),

  proposalRequest('proposal-request'),
  proposalAttachment('proposal-attachment'),
  commentAttachment('comment-attachment');

  const DocumentType(this.value);

  final String value;

  static DocumentType? fromValue(String value) {
    for (final type in DocumentType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}
