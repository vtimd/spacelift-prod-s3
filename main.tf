resource "aws_s3_bucket" "this" {
  bucket = "spacelift-prod-bucket-3"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [time_sleep.slow]
}

# ---------------------------------------------------------------------------
# Run Observability demo scenarios. Each one is off unless failure_mode
# selects it, so "none" is a clean, healthy run.
# ---------------------------------------------------------------------------

# slow: apply succeeds, but one span eats ~90s. Shows a bottleneck.
resource "time_sleep" "slow" {
  count           = var.failure_mode == "slow" ? 1 : 0
  create_duration = "90s"
}

# http_timeout: plan-phase failure. A data source calls a non-routable IP,
# retries twice, then fails with a request timeout (~30s total).
data "http" "health_check" {
  count              = var.failure_mode == "http_timeout" ? 1 : 0
  url                = "https://10.255.255.1/health"
  request_timeout_ms = 8000

  retry {
    attempts     = 2
    min_delay_ms = 1000
  }
}

# provider_timeout: apply-phase failure. The AWS provider tries to create a
# bucket through the blackholed endpoint and hangs until it times out.
resource "aws_s3_bucket" "unreachable" {
  count    = var.failure_mode == "provider_timeout" ? 1 : 0
  provider = aws.blackhole
  bucket   = "spacelift-observability-demo-timeout"
}

# api_error: fast apply-phase failure. "test" is owned by another AWS account,
# so CreateBucket returns BucketAlreadyExists.
resource "aws_s3_bucket" "collision" {
  count  = var.failure_mode == "api_error" ? 1 : 0
  bucket = "test"
}
