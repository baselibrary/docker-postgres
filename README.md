# baselibrary/postgres [![Docker Repository on Quay.io](https://quay.io/repository/baselibrary/postgres/status "Docker Repository on Quay.io")](https://quay.io/repository/baselibrary/postgres)

## Installation and Usage

    docker pull quay.io/baselibrary/postgres:${VERSION:-latest}

## Available Versions (Tags)

* `latest`: postgres 9.4
* `9.0`: postgres 9.0
* `9.1`: postgres 9.1
* `9.2`: postgres 9.2
* `9.3`: postgres 9.3
* `9.4`: postgres 9.4

## Deployment

To push the Docker image to Quay, run the following command:

    make release

## Continuous Integration

Images are built and pushed to Docker Hub on every deploy. Because Quay currently only supports build triggers where the Docker tag name exactly matches a GitHub branch/tag name, we must run the following script to synchronize all our remote branches after a merge to master:

    make sync-branches
