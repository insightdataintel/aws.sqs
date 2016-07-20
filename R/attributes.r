#' @rdname attributes
#' @aliases get_queue_attrs set_queue_attrs
#' @title Queue Attributes
#' @description Get and set queue attributes
#' @details Get or set the attributes for a queue.
#' @param queue A character string containing a queue URL, or the name of the queue.
#' @param attributes For \code{get_queue_attrs}, a vector of attribute names to return. For \code{set_queue_attrs}, a named character vector or named list of attributes and their values (as character strings). Allowed attributes are: \dQuote{Policy}, \dQuote{VisibilityTimeout}, \dQuote{MaximumMessageSize}, \dQuote{MessageRetentionPeriod}, \dQuote{ApproximateNumberOfMessages}, \dQuote{ApproximateNumberOfMessagesNotVisible}, \dQuote{CreatedTimestamp}, \dQuote{LastModifiedTimestamp}, \dQuote{QueueArn}, \dQuote{ApproximateNumberOfMessagesDelayed}, \dQuote{DelaySeconds}, \dQuote{ReceiveMessageWaitTimeSeconds}, \dQuote{RedrivePolicy}.
#' @param query A list specifying additional query arguments to be passed to the \code{query} argument of \code{\link{sqsHTTP}}.
#' @param ... Additional arguments passed to \code{\link{sqsHTTP}}.
#' @return For \code{get_queue_attrs}, a data.frame list of queue attributes. Otherwise, a data structure of class \dQuote{aws_error} containing any error message(s) from AWS and information about the request attempt.
#' 
#' For \code{set_queue_attrs}, a logical \code{TRUE} if operation was successful. Otherwise, a data structure of class \dQuote{aws_error} containing any error message(s) from AWS and information about the request attempt.
#' @author Thomas J. Leeper
#' @seealso \code{link{create_queue}}
#' @references
#' \href{http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ReceiveMessage.html}{ReceiveMessage}
#' @export
get_queue_attrs <- function(queue, attributes = "All", query = NULL, ...) {
    queue <- .urlFromName(queue)
    query_args <- c(query, list(Action = "GetQueueAttributes"))
    a <- as.list(attributes)
    names(a) <- paste0("AttributeName.",1:length(a))
    query_args <- c(query_args, a)
    out <- sqsHTTP(queue, query = query_args, ...)
    if (inherits(out, "aws-error") || inherits(out, "unknown")) {
        return(out)
    }
    structure(out[["GetQueueAttributesResponse"]][["GetQueueAttributesResult"]][["Attributes"]],
              RequestId = out$GetQueueAttributesResponse$ResponseMetadata$RequestId)
}

#' @rdname attributes
#' @importFrom stats setNames
#' @export
set_queue_attrs <- function(queue, attributes, query = NULL, ...) {
    queue <- .urlFromName(queue)
    query_args <- c(query, list(Action = "SetQueueAttributes"))
    a <- length(attributes)
    query_args <- c(query_args, 
                    setNames(names(attributes), 
                             paste0("Attribute.Name.", seq_along(attributes))),
                    setNames(unname(unlist(attributes)),
                             paste0("Attribute.Value.", seq_along(attributes))) )
    out <- sqsHTTP(url = queue, query = query_args, ...)
    if (inherits(out, "aws-error") || inherits(out, "unknown")) {
        return(out)
    }
    structure(TRUE,
              RequestId = out$SetQueueAttributesResponse$ResponseMetadata$RequestId)
}

#' @title Get a queue URL
#' @aliases get_queue_url
#' @description Retrieves the URL for an SQS queue by its name.
#' @param name A character string containing the name of the queue.
#' @param owner A character string containing the AWS Account ID that created the queue.
#' @param query A list specifying additional query arguments to be passed to the \code{query} argument of \code{\link{sqsHTTP}}.
#' @param ... Additional arguments passed to \code{\link{sqsHTTP}}.
#' @return If successful, a character string containing an SQS Queue URL. Otherwise, a data structure of class \dQuote{aws_error} containing any error message(s) from AWS and information about the request attempt.
#' @author Thomas J. Leeper
#' @seealso \code{link{create_queue}} \code{link{delete_queue}} \code{\link{get_queue_attrs}} \code{\link{set_queue_attrs}}
#' @references
#' \href{http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_GetQueueUrl.html}{GetQueueURL}
#' @export
get_queue_url <- function(name, owner = NULL, query = NULL, ...) {
    query_args <- c(query, list(Action = "GetQueueUrl", QueueName = name))
    if (!is.null(owner)) {
        query_args$QueueOwnerAWSAccountId <- owner
    }
    out <- sqsHTTP(query = query_args, ...)
    if (inherits(out, "aws-error") || inherits(out, "unknown")) {
        return(out)
    }
    structure(out$GetQueueUrlResponse$GetQueueUrlResult$QueueUrl,
              RequestId = out$GetQueueUrlResponse$ResponseMetadata$RequestId)
}

.urlFromName <- function(queue) {
    p <- parse_url(queue)
    if (is.null(p$scheme)) {
        out <- get_queue_url(queue)
        if(!length(out))
            stop("Queue URL not found")
    } else {
        out <- queue
    }
    return(out)
}
