// var getTransformer = require('ts-transform-graphql-tag').getTransformer

module.exports = {
  test: /\.(ts|tsx)?(\.erb)?$/,
  use: [{
    loader: 'ts-loader',
    // options: {
    //   // ... other loader's options
    //   getCustomTransformers: () => ({ before: [getTransformer()] })
    // }
  }]
}

// https://stackoverflow.com/questions/43002099/rules-vs-loaders-in-webpack-whats-the-difference
// Rules will wipe out loaders so becareful..., loaders may become depricated
