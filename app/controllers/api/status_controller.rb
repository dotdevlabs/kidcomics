module Api
  class StatusController < BaseController
    def show
      render json: {
        data: {
          type: "status",
          id: "current",
          attributes: {
            version: ENV["BUILD_VERSION"].presence,
            sha: ENV["COMMIT_SHA"].presence,
            db_version: latest_migration_version
          }
        }
      }, content_type: "application/vnd.api+json"
    end

    private

    def latest_migration_version
      ApplicationRecord.connection.select_value(
        "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
      )
    end
  end
end
