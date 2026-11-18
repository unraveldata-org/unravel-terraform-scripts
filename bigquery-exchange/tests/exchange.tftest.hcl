mock_provider "google" {}

variables {
  project_id       = "publisher-project"
  data_exchange_id = "unravel_private_exchange"
  primary_contact  = "owner@example.com"
  listings = [
    {
      listing_id        = "cold_tables"
      source_dataset_id = "unravel_shared"
    },
    {
      listing_id        = "other_inventory"
      source_dataset_id = "other_shared"
    }
  ]
  subscriber_members = [
    "user:analyst@example.com",
    "serviceAccount:reader@subscriber-project.iam.gserviceaccount.com"
  ]
}

run "private_dataset_sharing" {
  command = apply

  assert {
    condition = (
      google_bigquery_analytics_hub_data_exchange.exchange.discovery_type == "DISCOVERY_TYPE_PRIVATE" &&
      length(google_bigquery_analytics_hub_data_exchange.exchange.sharing_environment_config) == 0
    )
    error_message = "The exchange must be private and must not be a data clean room."
  }

  assert {
    condition = (
      length(google_bigquery_analytics_hub_listing.dataset) == 2 &&
      google_bigquery_analytics_hub_listing.dataset["cold_tables"].bigquery_dataset[0].dataset == "projects/publisher-project/datasets/unravel_shared" &&
      length(google_bigquery_analytics_hub_listing.dataset["cold_tables"].bigquery_dataset[0].selected_resources) == 0 &&
      google_bigquery_analytics_hub_listing.dataset["other_inventory"].bigquery_dataset[0].dataset == "projects/publisher-project/datasets/other_shared"
    )
    error_message = "Each listing must reference its entire source dataset."
  }

  assert {
    condition = alltrue([
      for listing in google_bigquery_analytics_hub_listing.dataset :
      listing.discovery_type == "DISCOVERY_TYPE_PRIVATE" &&
      listing.log_linked_dataset_query_user_email &&
      length(listing.restricted_export_config) == 0
    ])
    error_message = "Listings must remain private, log subscriber identities, and not restrict data exports."
  }

  assert {
    condition = (
      length(google_bigquery_analytics_hub_data_exchange_iam_member.subscriber) == 2 &&
      google_bigquery_analytics_hub_data_exchange_iam_member.subscriber["user:analyst@example.com"].member == "user:analyst@example.com" &&
      google_bigquery_analytics_hub_data_exchange_iam_member.subscriber["serviceAccount:reader@subscriber-project.iam.gserviceaccount.com"].member == "serviceAccount:reader@subscriber-project.iam.gserviceaccount.com" &&
      alltrue([
        for grant in google_bigquery_analytics_hub_data_exchange_iam_member.subscriber :
        grant.role == "roles/analyticshub.subscriber" &&
        grant.data_exchange_id == "unravel_private_exchange"
      ])
    )
    error_message = "Grant exchange subscription permissions to the exact user and service-account members."
  }
}

run "append_dataset_listing" {
  command = plan

  variables {
    listings = [
      {
        listing_id        = "cold_tables"
        source_dataset_id = "unravel_shared"
      },
      {
        listing_id        = "other_inventory"
        source_dataset_id = "other_shared"
      },
      {
        listing_id        = "new_inventory"
        source_dataset_id = "new_shared"
      }
    ]
  }

  assert {
    condition = (
      length(google_bigquery_analytics_hub_listing.dataset) == 3 &&
      output.listing_names["cold_tables"] == run.private_dataset_sharing.listing_names["cold_tables"] &&
      output.listing_names["other_inventory"] == run.private_dataset_sharing.listing_names["other_inventory"]
    )
    error_message = "Appending a dataset listing must preserve existing listing resources."
  }
}

run "reject_public_access" {
  command = plan

  variables {
    subscriber_members = ["allUsers"]
  }

  expect_failures = [var.subscriber_members]
}

run "reject_authenticated_public_access" {
  command = plan

  variables {
    subscriber_members = ["allAuthenticatedUsers"]
  }

  expect_failures = [var.subscriber_members]
}

run "reject_untyped_members" {
  command = plan

  variables {
    subscriber_members = ["reader@example.com"]
  }

  expect_failures = [var.subscriber_members]
}

run "reject_group_members" {
  command = plan

  variables {
    subscriber_members = ["group:readers@example.com"]
  }

  expect_failures = [var.subscriber_members]
}

run "reject_invalid_service_account" {
  command = plan

  variables {
    subscriber_members = ["serviceAccount:reader@example.com"]
  }

  expect_failures = [var.subscriber_members]
}

run "reject_duplicate_listing_ids" {
  command = plan

  variables {
    listings = [
      {
        listing_id        = "duplicate"
        source_dataset_id = "first_dataset"
      },
      {
        listing_id        = "duplicate"
        source_dataset_id = "second_dataset"
      }
    ]
  }

  expect_failures = [var.listings]
}

run "remove_managed_subscribers" {
  command = plan

  variables {
    subscriber_members = []
  }

  assert {
    condition     = length(google_bigquery_analytics_hub_data_exchange_iam_member.subscriber) == 0
    error_message = "An empty subscriber set must leave no managed subscriber grants."
  }
}
