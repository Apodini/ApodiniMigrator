<!--

This source file is part of the Apodini open source project

SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>

SPDX-License-Identifier: MIT

-->

# Apodini Migrator

<p align="center">
  <img width="200" src="https://github.com/Apodini/ApodiniMigrator/blob/develop/Resources/logo.png">
</p>

[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/Apodini/ApodiniMigrator/blob/develop/LICENSES)
[![swift-version](https://img.shields.io/badge/Swift-5.5-orange.svg)](https://github.com/apple/swift)
[![Build](https://github.com/Apodini/ApodiniMigrator/actions/workflows/build.yml/badge.svg)](https://github.com/Apodini/ApodiniMigrator/actions/workflows/build.yml)
[![codecov](https://codecov.io/gh/Apodini/ApodiniMigrator/branch/develop/graph/badge.svg?token=5MMKMPO5NR)](https://codecov.io/gh/Apodini/ApodiniMigrator)

`ApodiniMigrator` is a Swift package that performs several automated tasks, to migrate client applications after a Web Service publishes a new version that contains breaking changes. The tasks include automated generation of an intermediary client library that contains all required components to establish a client-server communication. Furthermore, `ApodiniMigrator` is able to automatically generate a machine-readable migration guide in either `json` or `yaml` format, that describes the changes between two subsequent Web API versions, and includes auxiliary migrating actions. By means of the migration guide, `ApodiniMigrator` can automatically migrate the intermediary client library, ensuring therefore the compatibility with the new Web API version. It is part of [**Apodini**](https://github.com/Apodini/Apodini), a composable framework to build Web Services in using Swift.

## Requirements

This library requires at least Swift 5.5 and macOS 12. Furthermore, it makes use of an automatically generated `Document`, that describes the interface of an Apodini Web Service. See [Documentation](https://github.com/Apodini/Apodini) in *Apodini* project, on how to integrate and configure `ApodiniMigrator` in your Web Service to generate the `Document` or a migration guide between two versions.

## Installation/Setup/Integration

`ApodiniMigrator` offers a Command-line interface program to execute its functionalities. After cloning the project, one can run the following commands on the root of the project to install `migrator` CLI

```console
ApodiniMigrator $ swift build --configuration release
ApodiniMigrator $ cp -f .build/release/migrator /usr/local/bin/migrator
ApodiniMigrator $ cp -f .build/release/protoc-gen-grpc-migrator /usr/local/bin/protoc-gen-grpc-migrator
```

## Usage
After installing `migrator` CLI, `migrator --help` command gives an overview of its functionalities:

```console
$ migrator --help
OVERVIEW: Automatically generate migration guides and migrate client libraries.

USAGE: migrator <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  compare                 Compare API documents and automatically generate a migration guide between two versions.
  migrate                 Migrate a client library using the base API document and a migration guide.
  generate                Generate a client library from an API document.

  See 'migrator help <subcommand>' for detailed help.
```
### Compare

`compare` subcommand automatically generates a machine-readable migration guide in either `json` or `yaml` format after comparing documents of two different versions. Below its required arguments:

```console
$ migrator compare --help
OVERVIEW: Compare API documents and automatically generate a migration guide between two versions.

USAGE: migrator compare --old-document-path <old-document-path> --new-document-path <new-document-path> --migration-guide-path <migration-guide-path> [--format <format>]

OPTIONS:
  -o, --old-document-path <old-document-path>
                          Path to API document of the old version, e.g. /path/to/api_v1.0.0.json 
  -n, --new-document-path <new-document-path>
                          Path to API document of the new version, e.g. /path/to/api_v1.2.0.yaml 
  -m, --migration-guide-path <migration-guide-path>
                          Path to a directory where the migration guide should be persisted, e.g. /path/to/directory 
  -f, --format <format>   Output format of the migration guide, either JSON or YAML. JSON by default (default: json)
  -h, --help              Show help information.
```

### Generate
`generate` subcommand can automatically generate an intermediary client library in the Swift programming language for supported WebAPI types.
The library includes all the models and API calling methods of an API Web Service and can be added as a dependency in an existing iOS or macOS using Swift Package Manager.

```console
OVERVIEW: Generate a client library from an API document.

USAGE: migrator generate <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  rest                    Generate a REST client library from an API document.
  grpc                    Generate a gRPC client library from an API document.

  See 'migrator help generate <subcommand>' for detailed help.
```

Subcommand for generating a RESTful client library:

```console
$ migrator generate --help
OVERVIEW: Generate a REST client library from an API document.

USAGE: migrator generate rest --package-name <package-name> --target-directory <target-directory> --document-path <document-path>

OPTIONS:
  -n, --package-name <package-name>
                          Name of the package 
  -t, --target-directory <target-directory>
                          Output path of the package (without package name) 
  -d, --document-path <document-path>
                          Path where the base api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json 
  -h, --help              Show help information.
```

Subcommand for generating a gRPC client library:

```console
OVERVIEW: Generate a gRPC client library from an API document.

USAGE: migrator generate grpc --package-name <package-name> --target-directory <target-directory> --document-path <document-path> --proto-path <proto-path> [--protoc-gen-dump-request-path <protoc-gen-dump-request-path>] [--protoc-grpc-plugin-path <protoc-grpc-plugin-path>]

OPTIONS:
  -n, --package-name <package-name>
                          Name of the package 
  -t, --target-directory <target-directory>
                          Output path of the package (without package name) 
  -d, --document-path <document-path>
                          Path where the base api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json 
  -p, --proto-path <proto-path>
                          Path where the grpc proto file is located, e.g. /path/to/MyWebService.proto 
  --protoc-gen-dump-request-path <protoc-gen-dump-request-path>
                          Specify the path to which you want to dump the protoc plugin request binary. For Debugging purposes! 
  --protoc-grpc-plugin-path <protoc-grpc-plugin-path>
                          Manually specify the path to the `protoc-gen-grpc-migrator` protoco plugin. 
  -h, --help              Show help information.
```

### Migrate

`migrate` subcommand performs the automated migration of the intermediary client library generated in the previous step.
It makes use of the machine-readable migration guide and the `Document` that initially generated the library:

```console
OVERVIEW: Migrate a client library using the base API document and a migration guide.

USAGE: migrator migrate <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  rest                    Migrate a gRPC client library from an API document and a migration guide.
  grpc                    Migrate a gRPC client library from proto files, an API document and a migration guide.

  See 'migrator help migrate <subcommand>' for detailed help.
```

Subcommand for migrating a RESTful client library:

```console
$ migrator migrate --help
OVERVIEW: Migrate a gRPC client library from an API document and a migration guide.

USAGE: migrator migrate rest --package-name <package-name> --target-directory <target-directory> --document-path <document-path> --migration-guide-path <migration-guide-path>

OPTIONS:
  -n, --package-name <package-name>
                          Name of the package 
  -t, --target-directory <target-directory>
                          Output path of the package (without package name) 
  -d, --document-path <document-path>
                          Path where the base api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json 
  -m, --migration-guide-path <migration-guide-path>
                          Path where the migration guide is located, e.g. /path/to/migration_guide.json 
  -h, --help              Show help information.
```

Subcommand for generating a gRPC client library:

```console
OVERVIEW: Migrate a gRPC client library from proto files, an API document and a migration guide.

USAGE: migrator migrate grpc --package-name <package-name> --target-directory <target-directory> --document-path <document-path> --migration-guide-path <migration-guide-path> --proto-path <proto-path> [--protoc-gen-dump-request-path <protoc-gen-dump-request-path>] [--protoc-grpc-plugin-path <protoc-grpc-plugin-path>]

OPTIONS:
  -n, --package-name <package-name>
                          Name of the package 
  -t, --target-directory <target-directory>
                          Output path of the package (without package name) 
  -d, --document-path <document-path>
                          Path where the base api_vX.Y.Z file is located, e.g. /path/to/api_v1.0.0.json 
  -m, --migration-guide-path <migration-guide-path>
                          Path where the migration guide is located, e.g. /path/to/migration_guide.json 
  -p, --proto-path <proto-path>
                          Path where the grpc proto file is located, e.g. /path/to/MyWebService.proto 
  --protoc-gen-dump-request-path <protoc-gen-dump-request-path>
                          Specify the path to which you want to dump the protoc plugin request binary. For Debugging purposes! 
  --protoc-grpc-plugin-path <protoc-grpc-plugin-path>
                          Manually specify the path to the `protoc-gen-grpc-migrator` protoco plugin. 
  -h, --help              Show help information.
```

## ApodiniMigratorExample

[ApodiniMigratorExample](https://github.com/Apodini/ApodiniMigratorExample) includes two different versions of an Apodini Web Service using `ApodiniMigrator` configuration. The corresponding documents of those versions can be found in the [ExampleDocuments](https://github.com/Apodini/ApodiniMigrator/tree/develop/Resources/ExampleDocuments) of this repository. In order to test out the functionalities of `migrator` CLI, a preconfigured Ruby script in the root of this repository can be used (see [migrator](https://github.com/Apodini/ApodiniMigrator/blob/develop/migrator))

In order to generate the intermediary client library for the initial version run the script with `generate` argument:

```console
$ ./migrator generate
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Starting generation of package QONECTIQ
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Starting library generation at: ~
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Creating directory Sources at: ~/QONECTIQ
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Creating directory QONECTIQ at: ~/QONECTIQ/Sources
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Creating directory Endpoints at: ~/QONECTIQ/Sources/QONECTIQ
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Handling library composite EndpointsMigrator at: ~/QONECTIQ/Sources/QONECTIQ/Endpoints
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Rendering file Event+Endpoint.swift at: ~/QONECTIQ/Sources/QONECTIQ/Endpoints
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Rendering file HomeFeed+Endpoint.swift at: ~/QONECTIQ/Sources/QONECTIQ/Endpoints
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : ...
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Package QONECTIQ was generated successfully. You can open the package via QONECTIQ/Package.swift

```
Each endpoint of the library can be accessed via the caseless enumeration `API` as follows:

```swift
API.getEventWithID(id: UUID())
    .sink { completion in
        if case let .failure(error) = completion {
            print("Failed to get the event with error: \(error)")
        }
    } receiveValue: { event in
        print("Received event \(event.title)")
    }
```

Migration guide can be generated via:

```console
$ ./migrator compare
info org.apodini.migrator : Starting generation of the migration guide...
info org.apodini.migrator : Migration guide was generated successfully at /path/to/ApodiniMigrator/Resources/ExampleDocuments/migration_guide.json.
```

Once the migration guide has been generated, use `migrate` argument to migrate the initial library:

```console
$ ./migrator migrate
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Starting migration of package QONECTIQ
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Starting library generation at: ~
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Creating directory Sources at: ~/QONECTIQ
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Creating directory QONECTIQ at: ~/QONECTIQ/Sources
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Creating directory Endpoints at: ~/QONECTIQ/Sources/QONECTIQ
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Handling library composite EndpointsMigrator at: ~/QONECTIQ/Sources/QONECTIQ/Endpoints
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Rendering file Event+Endpoint.swift at: ~/QONECTIQ/Sources/QONECTIQ/Endpoints
2022-02-09T00:24:50+0100 info org.apodini.migrator.rest : Rendering file HomeFeed+Endpoint.swift at: ~/QONECTIQ/Sources/QONECTIQ/Endpoints
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : ...
2022-02-08T23:08:31+0100 info org.apodini.migrator.rest : Package QONECTIQ was migrated successfully. You can open the package via QONECTIQ/Package.swift
```

## Contributing
Contributions to the projects are welcome. Please make sure to read the [contribution guidelines](https://github.com/Apodini/.github/blob/release/CONTRIBUTING.md) first.

## License
This project is licensed under the MIT License. See [License](https://github.com/Apodini/ApodiniMigrator/blob/develop/LICENSES) for more information.
