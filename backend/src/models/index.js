const sequelize = require('../config/database');
const User = require('./user.model')(sequelize);
const Plan = require('./plan.model')(sequelize);

// Initialize models
const models = {
  User,
  Plan
};

// Set up associations if any
Object.keys(models).forEach(modelName => {
  if (models[modelName].associate) {
    models[modelName].associate(models);
  }
});

module.exports = {
  sequelize,
  ...models
}; 