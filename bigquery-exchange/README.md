# Private BigQuery Analytics Hub Data Exchange

Publish existing BigQuery datasets through a standard, private Analytics Hub
exchange for named users and service accounts. Unlike
[`bigquery-analytics`](../bigquery-analytics/README.md), this is not a Data Clean
Room and shares one entire dataset per listing, not selected individual tables.
The existing clean-room configuration is unchanged.

## Resources and access

- Creates a private exchange and private dataset listings.
- Grants `roles/analyticshub.subscriber` on the exchange to each
  `subscriber_members` identity. Each identity can subscribe to all its listings.
- Allows data exports (no `restricted_export_config` restrictions) and enables
  subscriber query-user email logging. Once enabled, email logging
  cannot be disabled on the existing exchange.
- Does not create source datasets, tables, data-refresh jobs, subscriptions, or
  subscriber-side linked datasets.

Use a **dedicated sharing dataset** containing only approved data. All supported
objects in that dataset, including future tables, are shared. For the cold-table
inventory, create and populate `unravel_cold_tables_1y` in that dataset before
publishing it. Do not list a production dataset containing unrelated tables.

Private discovery and these IAM grants do not override permissions inherited
from the project or organization. Review existing IAM before publishing.
Subscriber-project administrators also control who can query linked datasets;
an allowlisted subscription identity is not an exclusive end-user query allowlist.

## Prerequisites

- Terraform >= 1.3 and the stable HashiCorp Google provider 7.x.
- BigQuery and Analytics Hub APIs enabled in the publisher and subscriber
  projects. API enablement is managed outside this configuration.
- Existing publisher datasets in the exchange's BigQuery location.
- Application Default Credentials for the publisher identity running Terraform.
  Grant Analytics Hub Admin (`roles/analyticshub.admin`) on the publisher project
  and the source-dataset permissions required to publish, such as BigQuery Data
  Owner (`roles/bigquery.dataOwner`) on each shared dataset. With user project
  overrides, the caller also needs `serviceusage.services.use` on the quota
  project (for example, Service Usage Consumer).
- Organization sharing policies and any VPC Service Controls rules must permit
  the intended cross-project/organization subscription.

## Publisher setup

From `bigquery-exchange/`:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the project, location, exchange ID, contact, dataset listings, and subscriber
identities. Use complete IAM member strings, not bare email addresses:

```hcl
subscriber_members = [
  "user:analyst@example.com",
  "serviceAccount:unravel-reader@unravel-project.iam.gserviceaccount.com"
]
```

Only users and service accounts are accepted; public principals and groups are
rejected. No service-account keys need to be supplied to grant access.

```bash
terraform init
terraform plan
terraform apply
terraform output listing_names
```

Use **separate Terraform state** from `bigquery-analytics/`. Use a new exchange
ID rather than attempting to convert an existing clean room. Preserve the state
and dependency lock file for subsequent runs; configure a suitable remote
backend for team use.

## Subscriber setup

Subscription is a separate operation performed as an approved user or service
account, not by this publisher Terraform configuration.

1. Enable the required APIs in the destination project. Grant the subscribing
   identity permissions to create datasets and jobs there, for example BigQuery
   User (`roles/bigquery.user`). The exchange subscriber role is already granted
   by publisher Terraform.
2. As an approved user, open **BigQuery > Sharing (Analytics Hub)**, find the
   private listing, and choose **Subscribe**. Select the destination project
   and a new linked dataset name. Use the source location for this basic setup.
3. For a service account, authenticate as or impersonate that account and use
   the [listing subscribe API](https://cloud.google.com/bigquery/docs/analytics-hub-view-subscribe-listings#subscribe-listings).
   Impersonation additionally requires permission to impersonate that account.
   The request creates the linked dataset; do not pre-create it.
4. Grant intended query identities BigQuery Data Viewer
   (`roles/bigquery.dataViewer`) on the linked dataset and BigQuery Job User
   (`roles/bigquery.jobUser`) on the query project, or equivalent permissions.
5. Query the shared inventory, using the destination linked dataset name:

   ```sql
   SELECT project_id, dataset_name, table_name, last_read, last_write
   FROM `subscriber-project.linked_dataset.unravel_cold_tables_1y`
   LIMIT 10;
   ```

The linked dataset is read-only and references publisher data without copying it.
The listing does not restrict exports or copies; normal BigQuery IAM and
organization policies still apply. Subscribers can retain exported copies even
after a subscription is revoked.

## Updates and revocation

- **New rows or tables in a shared dataset:** visible through the existing
  linked dataset without a new listing subscription, subject to propagation.
- **Another dataset:** append a new listing with a unique, stable `listing_id`,
  retaining existing entries, then run `terraform plan` and `terraform apply`.
  Subscribers subscribe to the new listing separately.
- **Another identity:** append its fully prefixed member and apply. Additive IAM
  member resources preserve unrelated IAM grants.
- **Remove an identity:** remove its member and apply to remove the managed
  subscription permission. Use `subscriber_members = []` to remove all managed
  subscriber grants. This does **not** revoke an existing subscription; revoke
  that subscription separately using
  [subscription management](https://cloud.google.com/bigquery/docs/analytics-hub-manage-subscriptions).
  Check other and inherited access paths as well.
- **Remove or rename a listing:** removing its entry plans deletion; changing
  its ID plans replacement. Review subscriber impact before applying.

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

With Terraform >= 1.7, run `terraform test` for mock-provider checks of private
dataset sharing, mixed user/service-account grants, appending listings, and
invalid input. These checks do not deploy resources. In a test GCP environment,
verify that both approved identity types can subscribe/query and an unrelated
identity without inherited access cannot. Confirm only the dedicated dataset
is exposed and exercise the actual Unravel query and export paths.

## References

- [Terraform data exchange resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_analytics_hub_data_exchange)
- [Manage private exchanges](https://cloud.google.com/bigquery/docs/analytics-hub-manage-exchanges)
- [Subscribe to listings](https://cloud.google.com/bigquery/docs/analytics-hub-view-subscribe-listings)
