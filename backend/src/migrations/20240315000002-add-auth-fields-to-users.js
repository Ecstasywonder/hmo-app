module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('Users', 'emailVerified', {
      type: Sequelize.BOOLEAN,
      defaultValue: false
    });
    await queryInterface.addColumn('Users', 'verificationToken', {
      type: Sequelize.STRING,
      allowNull: true
    });
    await queryInterface.addColumn('Users', 'resetPasswordToken', {
      type: Sequelize.STRING,
      allowNull: true
    });
    await queryInterface.addColumn('Users', 'resetPasswordExpires', {
      type: Sequelize.DATE,
      allowNull: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('Users', 'emailVerified');
    await queryInterface.removeColumn('Users', 'verificationToken');
    await queryInterface.removeColumn('Users', 'resetPasswordToken');
    await queryInterface.removeColumn('Users', 'resetPasswordExpires');
  }
}; 