const environment = require('./environment')
const config = require('@rails/webpacker/package/config');

module.exports = environment.toWebpackConfig()
