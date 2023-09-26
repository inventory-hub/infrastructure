locals {
  default_queues = toset([
    "invitation-messages",
    "alert-messages"
  ])
}
