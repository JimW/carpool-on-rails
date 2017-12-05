const environment = require('./environment')
const config = require('@rails/webpacker/package/config');

config.webpacker.check_yarn_integrity = false

module.exports = environment.toWebpackConfig()
