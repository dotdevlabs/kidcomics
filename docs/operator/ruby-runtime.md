# Ruby runtime

GitHub Actions reads `.ruby-version` and selects the latest available Ruby 3.4 patch release. The application image uses the official `ruby:3.4-slim` base tag. Both selectors follow new Ruby 3.4 patch releases automatically as they become available through their respective channels.

For manual builds, use `--pull` so Docker checks the registry for an updated base image. To check the Ruby version in the finished image without starting Rails, run the second command below.

```sh
docker build --pull -t kidcomics .
docker run --rm --entrypoint ruby kidcomics -v
```

In GitHub Actions, the `test` job's `Run tests` step prints the runner's Ruby version before running the Rails tests. It then builds the application image with `--pull` and prints the Ruby version from that image. Check both version lines when verifying a Ruby patch update.
