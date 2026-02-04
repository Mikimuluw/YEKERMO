/// Gate: personalization allowed only when reorder count is provably high enough.
bool canPersonalizeReorder(int count) => count >= 2;

/// Small score bump for reorder-based ranking. Only apply when canPersonalizeReorder(count).
int reorderScore(int count) => canPersonalizeReorder(count) ? 1 : 0;
