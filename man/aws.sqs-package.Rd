% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aws.sqs-package.R
\docType{package}
\name{aws.sqs-package}
\alias{aws.sqs-package}
\alias{aws.sqs}
\title{AWS SQS Client Package}
\description{
A simple client package for the Amazon Web Services (AWS) Simple Queue
Service (SQS) REST API.
}
\examples{
\dontrun{
  # list current queues
  list_queues()
  
  # create a queue
  queue <- create_queue("ExampleQueue")
  get_queue_url("ExampleQueue")
  
  # send message to queue
  send_msg("ExampleQueue", "This is a test message")
  # receive a message
  (m <- receive_msg("ExampleQueue", timeout = 0))
  
  # delete a message from queue
  delete_msg("ExampleQueue", m$ReceiptHandle[1])
  
  # delete queue
  delete_queue("ExampleQueue")
  
}
}
\author{
Thomas J. Leeper <thosjleeper@gmail.com>
}
\keyword{package}
