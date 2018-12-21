![ApiCore](https://github.com/LiveUI/ApiCore/raw/master/Other/logo.png)

##

[![Slack](https://img.shields.io/badge/join-slack-745EAF.svg?style=flat)](http://bit.ly/2B0dEyt)
[![Jenkins](https://ci.liveui.io/job/LiveUI/job/ApiCore/job/master/badge/icon)](https://ci.liveui.io/job/LiveUI/job/ApiCore/)
[![Platforms](https://img.shields.io/badge/platforms-macOS%2010.13%20|%20Ubuntu%2016.04%20LTS-ff0000.svg?style=flat)](https://github.com/LiveUI/ApiCore)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Swift 4](https://img.shields.io/badge/swift-4.1-orange.svg?style=flat)](http://swift.org)
[![Vapor 3](https://img.shields.io/badge/vapor-3.0-blue.svg?style=flat)](https://vapor.codes)


Base for API's that require user & team management including forgotten passwords, etc. This library should contain all the basic endpoints necessary to make your own SaaS platform similar to a github's own user management.

> ***Warning!**: This system is only designed to work with **PostgreSQL** at the moment!*

## Available endpoints

#### Install (available in DEBUG mode only!)
* `[GET] /install` - install base data (admin user, team, etc. Can be also run after `uninstall` to restore all tables)
* `[GET] /uninstall` - delete all tables (reversed migration)
* `[GET] /database` - show content of the fluent table

#### Authentication
* `[GET] /auth` - header based authentication (basic HTTP)
* `[POST] /auth` - POST based authentication
* `[GET] /token` - header based JWT token refresh
* `[POST] /token` - POST based JWT token refresh
* `[GET] /logout` - logout and delete ALL active tokens for the user
* `[POST] /logout` - Logout and delete ALL active tokens for the user (POST)
* `[POST] /auth/password-check` - Check password validity (is the password strong enough)
* `[POST] /auth/start-recovery` - Start password recovery
* `[GET] /auth/input-recovery` - HTML (templatable) based new password input
* `[POST] /auth/finish-recovery` - Finish recovery (from HTML or redirect)

#### Server
* `[GET] /info` - get server url, name and urls for server icons
* `[POST] /server/image` - post a new server icon (will be used on default recovery html and as a favicon web based endpoints
* `[GET] /server/image/{icon_size}` - get icon of a specific size (16, 64, 128, 192, 256 or 512px)
* `[GET] /server/image` - 512px large icon
* `[DELETE] /server/image` - delete server icon, default one will be used instead
* `[GET] /server/favicon` - 16x16 px favicon (PNG format)
* `[GET] /server/security` - Shows an array of security concerns ready to be displayed in user dialogs
* `[GET] /server/commit` - Shows the content of a file `./Resources/commit.txt` which can be edited during an automated deployment

#### Users
* `[GET] /users` - get list of connected users within your teams (searchable)
* `[GET] /users/global` - search users globally, personal info omitted, email MD5 added for Gravatar 
* `[POST] /users` - register new user
* `[GET] /users/verify` - verify registered email (registration email/link is send to the user)
* `[POST] /users/disable` - disable or enable a user (admin team members only)  
* `[POST] /users/invite` - Invite a user to join the system  
* `[GET] /users/input-invite` - HTML (templatable) based new user input
* `[POST] /users/finish-invitation` - Processes data received from the above form  

#### Teams
* `[GET] /teams` - list all available teams
* `[GET] /teams/{team_id}` - details on a specific team
* `[POST] /teams` - create team
* `[GET] /teams/check` - check if team identifier/name is available
* `[PUT] /teams/{team_id}` - modify existing team
* `[GET] /teams/{team_id}/users` - users linked to a specific team
* `[POST] /teams/{team_id}/link` - link a user to a specific team
* `[POST] /teams/{team_id}/unlink` - un-link a user from a specific team
* `[DELETE] /teams/{team_id}` - delete a team

#### Misc
* `[GET] /errors` - print out db archived error logs
* `[GET] /flush` - flush system logs (often useful when running apps in docker)
* `[GET] /ping` - find out if the server is alive
* `[GET] /teapot` - find out if the server is a teapot


## Install

Just add following line package to your `Package.swift` file.

```swift
.package(url: "https://github.com/LiveUI/ApiCore.git", .branch("master"))
```

## Configuration

There is a few ways to configure `ApiCore`. The easiest is through the Environmental variables.

```
CONFIG_PATH            // Path to a configuration file (default one is included `config.default.json`)
APICORE.JWT_SECRET     // Secret passphrase to sign JWT tokens (mandatory in production)
```

Configuration file looks like this
```json
{
	"general": {
		"single_team": false
	},
	"auth": {
		"allow_registrations": true,
		"allow_invitations": true,
		"registration_domains": []
	},
	"server": {
		"name": "Booster!",
		"url": "http://localhost:8080",
		"max_upload": 50
	},
	"jwt_secret": "secret",
	"database": {
		"host": "localhost",
		"port": 5432,
		"user": "boost",
		"password": "aaaaaa",
		"database": "boost",
		"logging": false
	},
	"mail": {
		"email": "admin@apicore",
		"mailgun": {
			"domain": "sandbox-domain.mailgun.org",
			"key": "secret-key"
		}
    },
    "storage": {
        "local": {
	        "root": "/tmp/Boost"
        },
        "s3": {
	        "enabled": false,
			"bucket": "my-boost-appstore",
			"access_key": "my-access-key",
			"secret_key": "my-secret-key",
			"region": "us-east-1",
			"security_token": null
        }
    }
}
```

Each value can be set through a corresponding environmental variable in a number of formats
```
1) apicore.jwt_secret
2) APICORE.JWT_SECRET
3) apicore_jwt_secret
4) APICORE_JWT_SECRET
```


### Integrationg ApiCore into a Vapor 3 app

To use `ApiCore` in an app, your configure.swift file could look something like this:

```swift
import Foundation
import Vapor
import DbCore
import MailCore
import ApiCore


public func configure(_ config: inout Config, _ env: inout Vapor.Environment, _ services: inout Services) throws {
    print("Starting ApiCore by LiveUI")
    sleep(10)
    Env.print()
    
    // Register routes
    let router = EngineRouter.default()
    try ApiCoreBase.boot(router: router)
    services.register(router, as: Router.self)
    
    // Go!
    try ApiCoreBase.configure(&config, &env, &services)
}
```

and `main.swift` somehow like that:

```swift
import ApiCoreApp
import Service
import Vapor

do {
    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()
    
    // Setup ApiCore configure
    try ApiCoreApp.configure(&config, &env, &services)
    
    let app = try Application(
        config: config,
        environment: env,
        services: services
    )
    
    try app.run()
} catch {
    print("Top-level failure: \(error)")
}
```

## Usage

TBD

## Support

Join our [Slack](http://bit.ly/2B0dEyt), channel <b>#help-boost</b> to ... well, get help :) 

## Boost AppStore

Core package for <b>[Boost](http://www.boostappstore.com)</b>, a completely open source enterprise AppStore written in Swift!
- Website: http://www.boostappstore.com
- Github: https://github.com/LiveUI/Boost

## Other core packages

* [BoostCore](https://github.com/LiveUI/BoostCore/) - AppStore core module
* [MailCore](https://github.com/LiveUI/MailCore/) - Mailing wrapper for multiple mailing services like MailGun, SendGrig or SMTP (coming)
* [DBCore](https://github.com/LiveUI/DbCore/) - Set of tools for work with PostgreSQL database
* [VaporTestTools](https://github.com/LiveUI/VaporTestTools) - Test tools and helpers for Vapor 3

## Code contributions

We love PR’s, we can’t get enough of them ... so if you have an interesting improvement, bug-fix or a new feature please don’t hesitate to get in touch. If you are not sure about something before you start the development you can always contact our dev and product team through our Slack.

## Author

Ondrej Rafaj (@rafiki270 on [Github](https://github.com/rafiki270), [Twitter](https://twitter.com/rafiki270), [LiveUI Slack](http://bit.ly/2B0dEyt) and [Vapor Slack](https://vapor.team/))

## License

ApiCore is distributed under an Apache 2 license and can be shared or used freely within the bounds of the license itself.
Most third party components used (like Vapor framework and all its components) in this software are MIT licensed.
List of all used software is listed in the repository. All components are available in the dependencies folder.

See the LICENSE file for more info.

